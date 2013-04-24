classdef ee561JobManager < CodedModJobManager
    
    
    methods
        
        function obj = ee561JobManager( cfgRoot, queueCfg )
            % This is the job manager for the communication-theory course project.
            % Calling syntax: obj = ee561JobManager( [cfgRoot] [,queueCfg] )
            % Input 'cfgRoot' is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'ee561';
            % CFG_Filename = 'ee561JobManager_cfg';
            
            % (Optional) input argument 'queueCfg' stores the full path to the queue configuration file.
            
            % Both input arguments must be defined.
            % If no specific job manager configuration file is desired, the argument must be specified as '[]'.
            
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            if( nargin<2 || isempty(queueCfg) ), queueCfg = []; end
            
            obj@CodedModJobManager(cfgRoot, queueCfg, 'ee561');
        end
        
        
        function [JobParam, JobState, SuccessFlag, ErrorMsg] = PreProcessJob(obj, JobParam, JobState, CurrentUser, JobName)
            SuccessFlag = 1;
            ErrorMsg = [];
            if( ~isfield(JobParam, 'JobFileSetFlag') || isempty(JobParam.JobFileSetFlag) || JobParam.JobFileSetFlag~=1 )
                % See if there is an S matrix in the JobParam. The field could be named either 'S', 'SignalSet', or 'S_matrix'.
                if( isfield(JobParam, 'SignalSet') && ~isempty(JobParam.SignalSet) && isnumeric(JobParam.SignalSet) )
                    SignalSet = JobParam.SignalSet;
                elseif( isfield(JobParam, 'S') && ~isempty(JobParam.S) && isnumeric(JobParam.S) )
                    SignalSet = JobParam.S;
                elseif( isfield(JobParam, 'S_matrix') && ~isempty(JobParam.S_matrix) && isnumeric(JobParam.S_matrix) )
                    SignalSet = JobParam.S_matrix;
                else
                    SuccessFlag = 0;
                    Msg1 = 'Type-ONE/1 Error (Job Content Error: NO SIGNALSET): ';
                    Msg2 = sprintf('The JobParam structure should contain a NUMERIC field named either "S", "SignalSet", or "S_matrix". ');
                    Msg3 = sprintf('The Signal Set is a K-by-M matrix of real numbers. ');
                    Msg4 = sprintf('K is the dimension and M is the number of signals in the constellation.');
                    ErrorMsg = [Msg1 Msg2 Msg3 Msg4];
                    return;
                end
                
                % Determine the size of signal constellation.
                [K,M] = size( SignalSet );
                
                % Make sure there are at least as many columns as rows in signal constellation.
                if( K > M )
                    SuccessFlag = 0;
                    Msg1 = 'Type-ONE/2 Error (Job Content Error: UNACCEPTABLE SIGNALSET): ';
                    Msg2 = 'The given Signal Set in the JobParam has more rows than columns.';
                    ErrorMsg = [Msg1 Msg2];
                    return;
                end
                
                SignalProb = ones(1,M); % Signals in the signal set are equally probable.
                
                try
                    % Create the modulation object using the given signal set.
                    ModObj = CreateModulation(SignalSet, SignalProb);
                    % Determine the threshold SNRs (Es/N0 in dB) that achieve the BER or SER of 1e-5.
                    JobState.GammaPs = InversePsUB( SignalSet, 1e-5 );
                    JobState.GammaPb = InversePbUB( SignalSet, 1e-5 );
                    
                    % Determine the range of the required SNR points for simulation.
                    FirstEsN0dB = InversePbUB( SignalSet, 1 );
                    LastEsN0dB = InversePbUB( SignalSet, 1e-6 );
                catch
                    SuccessFlag = 0;
                    Msg1 = 'Type-ONE/3 Error (Job Content Error: UNABLE TO PROCESS SIGNALSET): ';
                    Msg2 = 'The given Signal Set in the JobParam cannot be processed by InversePsUB or InversePbUB functions.';
                    ErrorMsg = [Msg1 Msg2];
                    return;
                end
                
                JobParam.NormalizedSignalSet = ModObj.SignalSet;
                JobState.PAPR = ModObj.PAPR;
                
                % Create the channel object (at 0 dB (SNR=1)) using the above modulation object.
                ChannelObj = AWGN( ModObj, 10^(0/10) );
                JobParam.ChannelObj = ChannelObj; % Channel object (Modulation is a property of channel).
                
                % Deterine the SNR vector.
                SNRdBIncrement = 0.5;
                EsN0dB = SNRdBIncrement * [ floor(FirstEsN0dB/SNRdBIncrement):ceil(LastEsN0dB/SNRdBIncrement) ];
                JobParam.SNR = [10 EsN0dB]; % Add 10 to the vector just for comparison purposes.
                JobParam.SNRType = 'Es/N0 in dB';
                
                % Compute the union bound on bit- and symbol-error probability over an AWGN channel for the given signal set.
                EsN0 = 10.^(EsN0dB/10);
                JobState.PsUpperBound = PsUB( SignalSet, EsN0 );
                JobState.PbUpperBound = PbUB( SignalSet, EsN0 );
                
                % Create the uncoded-modulation object.
                if( ~isfield(JobParam, 'DemodType') || isempty(JobParam.DemodType) )
                    JobParam.DemodType = 0; % Linear approximation to log-MAP algorithm in the demodulator.
                end
                if( ~isfield(JobParam, 'ZeroRandFlag') || isempty(JobParam.ZeroRandFlag) )
                    JobParam.ZeroRandFlag = 1; % Symbols are generated randomly (rather than vectors of all zeros).
                end
                if( ~isfield(JobParam, 'BlockLength') || isempty(JobParam.BlockLength) )
                    JobParam.BlockLength = 1024; % Number of symbols per block.
                end
                
                UncodedModObj = UncodedModulation(M, JobParam.DemodType, JobParam.ZeroRandFlag, JobParam.BlockLength, SignalProb);
                JobParam.CodedModObj = UncodedModObj; % Coded modulation object.
                
                if( ~isfield(JobParam, 'MaxTrials') || isempty(JobParam.MaxTrials) )
                    JobParam.MaxTrials = 1e5 * ones(size(JobParam.SNR));
                end
                if( ~isfield(JobParam, 'MaxFrameErrors') || isempty(JobParam.MaxFrameErrors) )
                    JobParam.MaxFrameErrors = 1e3 * ones(size(JobParam.SNR));
                end
                if( ~isfield(JobParam, 'MaxBitErrors') || isempty(JobParam.MaxBitErrors) )
                    JobParam.MaxBitErrors = 4e3 * ones(size(JobParam.SNR));
                end
                % Checking time in number of Trials.
                if( ~isfield(JobParam, 'CheckPeriod') || isempty(JobParam.CheckPeriod) ), JobParam.CheckPeriod = 100; end
                if( ~isfield(JobParam, 'minBER') || isempty(JobParam.minBER) ), JobParam.minBER = 1e-6; end
                if( ~isfield(JobParam, 'minFER') || isempty(JobParam.minFER) ), JobParam.minFER = 1e-6; end
                
                JobParam.JobFileSetFlag = 1;
                
                if( ~isfield(JobState, 'Trials') ), JobState.Trials = zeros(1, length(JobParam.SNR)); end
                if( ~isfield(JobState, 'SymbolErrors') ), JobState.SymbolErrors = zeros(1, length(JobParam.SNR)); end
                if( ~isfield(JobState, 'BitErrors') ), JobState.BitErrors = zeros(1, length(JobParam.SNR)); end
                if( ~isfield(JobState, 'FrameErrors') ), JobState.FrameErrors = zeros(1, length(JobParam.SNR)); end
                if( ~isfield(JobState, 'SER') ), JobState.SER = []; end
                if( ~isfield(JobState, 'BER') ), JobState.BER = []; end
                if( ~isfield(JobState, 'FER') ), JobState.FER = []; end
            end
        end
        
        
        function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
            % Update the Global JobState.
            JobState = JobStateIn;
            JobState.Trials      = JobState.Trials      + TaskState.Trials;
            JobState.BitErrors   = JobState.BitErrors   + TaskState.BitErrors;
            JobState.FrameErrors = JobState.FrameErrors + TaskState.FrameErrors;
            
            Trials = repmat(JobState.Trials,[size(JobState.BitErrors,1) 1]);
            JobState.BER = JobState.BitErrors   ./ ( Trials * JobParam.CodedModObj.NumCodewords *...
                JobParam.CodedModObj.ChannelCodeObject.DataLength );
            JobState.FER = JobState.FrameErrors ./ ( Trials * JobParam.CodedModObj.NumCodewords );
        end
        
        
        function JobInfo = UpdateResultsInfo(obj, JobParam, JobState, JobInfo)
            RemainingTrials = JobParam.MaxTrials - JobState.Trials(end,:);
            RemainingTrials(RemainingTrials<0) = 0;             % Force to zero if negative.
            RemainingFrameErrors = JobParam.MaxFrameErrors - JobState.FrameErrors(end,:);
            RemainingFrameErrors(RemainingFrameErrors<0) = 0;   % Force to zero if negative.
            
            % Determine the position of active SNR points based on the number of remaining trials and frame errors.
            ActiveSNRPoints  = ( (RemainingTrials>0) & (RemainingFrameErrors>0) );
            
            RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
            CompletedTJob = sum( JobState.Trials(end,:) );
            
            Results = struct( 'PAPR',JobState.PAPR, 'GammaPs',JobState.GammaPs, 'GammaPb',JobState.GammaPb,...
                'CompletedTrials', CompletedTJob, 'RemainingTrials', RemainingTJob );
            % Results = struct( 'SNR', num2str(JobParam.SNR), ...
            %     'Trials', num2str(JobState.Trials), ...
            %     'BER', num2str(JobState.BER), ...
            %     'FER', num2str(JobState.FER), ...
            %     'CompletedTrials', CompletedTJob, ...
            %     'RemainingTrials', RemainingTJob );
            
            JobInfo = obj.UpdateJobInfo( JobInfo, 'Results', Results );
        end
        
        
        function PlotResults( obj, JobParam, JobState, FiguresDir, JobName, TempJMDir )
            % Plot the results.
            FigH = figure(1);
            FigurePlotMsg = sprintf( '\nThe job manager is creating figures for Job %s.\n', JobName(1:end-4) );
            PrintOut(FigurePlotMsg, obj.JobManagerParam.vqFlag, obj.JobManagerParam.LogFileName);
            
            semilogy( JobParam.SNR, JobState.PsUpperBound, '--b',...
                JobParam.SNR, JobState.SER, '.b-', ...
                JobParam.SNR, JobState.PbUpperBound, '--r', ...
                JobParam.SNR, JobState.BER, '.r-' );
            
            legend( 'SER: Union Bound', 'SER: Simulated', 'BER: Union Bound', 'BER: Simulated' );
            
            xlabel( 'E_s/N_0 (in dB)' );
            ylabel( 'Error Rate' );
            
            TitleTxt = sprintf( 'Error Rate for Job %s', JobName(1:end-4) );
            title( TitleTxt );
            
            axis( [min(JobParam.SNR) max(JobParam.SNR) 1e-6 1] );
            
            if ispc
                try
                    % print(FigH, '-dpdf', fullfile(FiguresDir, [JobName(1:end-4) '_Figure.pdf']));
                    saveas( FigH, fullfile(FiguresDir, [JobName(1:end-4) '_Figure.pdf']) );
                catch
                    % print(FigH, '-dpdf', fullfile(FiguresDir, [JobName(1:end-4) '_Figure.pdf']));
                    saveas( FigH, fullfile(TempJMDir, [JobName(1:end-4) '_Figure.pdf']) );
                    obj.MoveFile( fullfile(TempJMDir, [JobName(1:end-4) '_Figure.pdf']), FiguresDir);
                end
            else
                % util.plexport( FigH, 'eps', fullfile(FiguresDir, [JobName(1:end-4) '_Figure']) );
                util.plexport( FigH, 'pdf', fullfile(FiguresDir, [JobName(1:end-4) '_Figure']) );
            end
            
            close all
        end
        
    end
    
end