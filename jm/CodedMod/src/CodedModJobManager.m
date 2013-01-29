classdef CodedModJobManager < JobManager
    
    
    methods
        function obj = CodedModJobManager(cfgRoot)
            % Coded-Modulation Simulation Job Manager.
            % Calling syntax: obj = CodedModJobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'CodedMod';
            % CFG_Filename = 'CodedModJobManager_cfg';
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            obj@JobManager(cfgRoot);
        end
        
        
        function [JobParam, JobState] = PreProcessJob(obj, JobParamIn, JobStateIn, CurrentUser, JobName)
            
            CodeRoot = CurrentUser.CodeRoot;
            
            % First, set the path.
            OldPath = obj.SetCodePath(CodeRoot);
            
            JobParam = JobParamIn;
            JobState = JobStateIn;
            
            % Create channel object (Modulation is a property of channel).
            if( ~isfield(JobParam, 'ChannelObj') || isempty(JobParam.ChannelObj) )
                if( ~isfield(JobParam, 'ModulationObj') || isempty(JobParam.ModulationObj) )
                    if( ~isfield(JobParam, 'ModulationType') || isempty(JobParam.ModulationType) ), JobParam.ModulationType = 'BPSK'; end
                    if( ~isfield(JobParam, 'ModulationParam') || isempty(JobParam.ModulationParam) ), JobParam.ModulationParam = '[]'; end
                    if( strcmpi(JobParam.ModulationType,'custom') )
                        ModGenStr = ['CreateModulation' '(' JobParam.ModulationParam ')'];
                    else
                        ModGenStr = [upper(JobParam.ModulationType) '(' JobParam.ModulationParam ')'];
                    end
                    JobParam.ModulationObj = eval(ModGenStr);
                end
                SNRdB = 5;
                JobParam.ChannelObj = AWGN( JobParam.ModulationObj, 10^(SNRdB/10) );
            end
            
            % Create coded modulation object (if possible).
            if( ~isfield(JobParam, 'CodedModObj') || isempty(JobParam.CodedModObj) )
                if( ~isfield(JobParam, 'ChannelCodeObject') || isempty(JobParam.ChannelCodeObject) )
                    if( ~isfield(JobParam, 'CodeType') || isempty(JobParam.CodeType) ), JobParam.CodeType = 21; end
                    if( ~isfield(JobParam, 'DecoderType') || isempty(JobParam.DecoderType) ), JobParam.DecoderType = 0; end
                    switch JobParam.CodeType
                        case 00 % Recursive Systematic Convolutional (RSC) code.
                            % Default generator matrix for convolutional code is the constituent code of UMTS turbo code.
                            if( ~isfield(JobParam, 'Generator') || isempty(JobParam.Generator) ), JobParam.Generator = [1 0 1 1 ; 1 1 0 1]; end
                            if( ~isfield(JobParam, 'DataLength') || isempty(JobParam.DataLength) ), JobParam.DataLength = 512; end
                            JobParam.ChannelCodeObject = ConvCode(JobParam.Generator, JobParam.DataLength, 0, JobParam.DecoderType);
                        case 01 % Non-Systematic Convolutional (NSC) code.
                            % Default generator matrix for convolutional code is the constituent code of UMTS turbo code.
                            if( ~isfield(JobParam, 'Generator') || isempty(JobParam.Generator) ), JobParam.Generator = [1 0 1 1 ; 1 1 0 1]; end
                            if( ~isfield(JobParam, 'DataLength') || isempty(JobParam.DataLength) ), JobParam.DataLength = 512; end
                            JobParam.ChannelCodeObject = ConvCode(JobParam.Generator, JobParam.DataLength, 1, JobParam.DecoderType);
                        case 02 % Tail-biting NSC code.
                            % Default generator matrix for convolutional code is the constituent code of UMTS turbo code.
                            if( ~isfield(JobParam, 'Generator') || isempty(JobParam.Generator) ), JobParam.Generator = [1 0 1 1 ; 1 1 0 1]; end
                            if( ~isfield(JobParam, 'DataLength') || isempty(JobParam.DataLength) ), JobParam.DataLength = 512; end
                            if( ~isfield(JobParam, 'ConvDepth') || isempty(JobParam.ConvDepth) ), JobParam.ConvDepth = -1; end
                            JobParam.ChannelCodeObject = ConvCode(JobParam.Generator, JobParam.DataLength, 2, JobParam.DecoderType, JobParam.ConvDepth);
                        otherwise
                            JobParam.ChannelCodeObject = [];
                    end
                end
                if ~isempty(JobParam.ChannelCodeObject)
                    if( ~isfield(JobParam, 'DemodType') || isempty(JobParam.DemodType) ), JobParam.DemodType = 0; end
                    if( ~isfield(JobParam, 'ZeroRandFlag') || isempty(JobParam.ZeroRandFlag) ), JobParam.ZeroRandFlag = 0; end
                    JobParam.CodedModObj = CodedModulation(JobParam.ChannelCodeObject, JobParam.ChannelObj.ModulationObj.ModOrder, ...
                        JobParam.DemodType, JobParam.ZeroRandFlag);
                else
                    JobParam.CodedModObj = [];
                end
            end
            
            path(OldPath);
        end
        
        
        function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
            % Calculate TaskInputParam based on the number of remaining errors and trials AND the number of new tasks to be generated.
            % TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.
            % If the InputParam is the same for all tasks, TaskInputParam can be 1-by-1.
            
            % Initialize TaskInputParam structure.
            TaskInputParam = JobParam;
            
            TaskInputParam.MaxFrameErrors = JobParam.MaxFrameErrors - JobState.FrameErrors(end,:);
            TaskInputParam.MaxFrameErrors(TaskInputParam.MaxFrameErrors<0) = 0;
            TaskInputParam.MaxBitErrors = JobParam.MaxBitErrors - JobState.BitErrors(end,:);
            TaskInputParam.MaxBitErrors(TaskInputParam.MaxBitErrors<0) = 0;
            TaskInputParam.MaxTrials = JobParam.MaxTrials - JobState.Trials(end,:);
            TaskInputParam.MaxTrials(TaskInputParam.MaxTrials<0) = 0;
            
            TaskInputParam.MaxTrials = ceil(TaskInputParam.MaxTrials/NumNewTasks);
        end
        
        
        function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
            % Update the Global JobState.
            JobState = JobStateIn;
            JobState.Trials      = JobState.Trials      + TaskState.Trials;
            JobState.BitErrors   = JobState.BitErrors   + TaskState.BitErrors;
            JobState.FrameErrors = JobState.FrameErrors + TaskState.FrameErrors;
            
            Trials = repmat(JobState.Trials,[size(JobState.BitErrors,1) 1]);
            JobState.BER         = JobState.BitErrors   ./ ( Trials * TaskState.NumCodewords * TaskState.DataLength );
            JobState.FER         = JobState.FrameErrors ./ ( Trials * TaskState.NumCodewords );
        end
        
        
        function [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, JobRunningDir)
            % Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
            % Furthermore, update Results file.
            % Calling syntax: [StopFlag, JobInfo [,JobParam]] = obj.DetermineStopFlag(JobParam, JobState, JobInfo [,JobName] [,Username] [,JobRunningDir])
            
            % First check to see if minimum number of trials or frame errors has been reached.
            RemainingTrials = JobParam.MaxTrials - JobState.Trials(end,:);
            RemainingTrials(RemainingTrials<0) = 0;             % Force to zero if negative.
            RemainingFrameErrors = JobParam.MaxFrameErrors - JobState.FrameErrors(end,:);
            RemainingFrameErrors(RemainingFrameErrors<0) = 0;   % Force to zero if negative.
            
            % Determine the position of active SNR points based on the number of remaining trials and frame errors.
            ActiveSNRPoints  = ( (RemainingTrials>0) & (RemainingFrameErrors>0) );
            
            % Determine if we can discard some SNR points whose BER or FER WILL be less than JobParam.minBER/minFER.
            LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
            
            StopFlagT = ~isempty(LastInactivePoint) && ( LastInactivePoint ~= length(ActiveSNRPoints) ) && ...
                ... % Changed on February 24, 2012. When SNR point is inactive, its BER or FER CAN be ZERO.
                ... ( ( (JobState.BER(end, LastInactivePoint) ~=0) && (JobState.BER(end, LastInactivePoint) < JobParam.minBER) ) || ...
                ... ( (JobState.FER(end, LastInactivePoint) ~=0) && (JobState.FER(end, LastInactivePoint) < JobParam.minFER) ) );
                (JobState.BER(end,LastInactivePoint) < JobParam.minBER || JobState.FER(end,LastInactivePoint) < JobParam.minFER);
            
            if StopFlagT == 1
                ActiveSNRPoints(LastInactivePoint:end) = 0;
                if( nargin>=5 && ~isempty(JobName) && ~isempty(Username) )
                    Msg = sprintf( ['\n\nRunning job %s for user %s is STOPPED for SOME SNR points above %.2f dB because their BER or' ...
                        'FER is below the required mimimum BER or FER.\n\n'], JobName(1:end-4), Username, JobParam.SNR(LastInactivePoint) );
                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                end
            end
            
            JobParam.MaxTrials(ActiveSNRPoints==0) = JobState.Trials(end,ActiveSNRPoints==0);
            
            % Set the stopping flag.
            StopFlag = ( sum(ActiveSNRPoints) == 0 );
            
            if StopFlag == 1
                if( nargin>=5 && ~isempty(JobName) && ~isempty(Username) )
                    StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
                        'frame errors are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
                    PrintOut(StopMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end
            
            % Determine and echo progress of running JobName.
            RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
            CompletedTJob = sum( JobState.Trials(end,:) );
            % RemainingFEJob = sum( (ActiveSNRPoints==1) .* RemainingFrameErrors );
            % CompletedFEJob = sum( JobState.FrameErrors(end,:) );
            if( nargin>=5 && ~isempty(JobName) && ~isempty(Username) )
                MsgStr = sprintf( ' for JOB %s USER %s', JobName(1:end-4), Username );
            else
                MsgStr = ' ';
            end
            msgStatus = sprintf( ['PROGRESS UPDATE', MsgStr, ':\r\nTotal Trials Completed=%d\r\nTotal Trials Remaining=%d\r\nPercentage of Trials Completed=%2.4f'],...
                CompletedTJob, RemainingTJob, 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
            PrintOut(['\n\n', msgStatus, '\n\n'], 0, obj.JobManagerParam.LogFileName);
            msgResults = sprintf( 'SNR Points Completed=%.2f\n', JobParam.SNR(ActiveSNRPoints==0) );
            
            % Update simulation progress in STAUS field of JobInfo.
            msgStatusFile = sprintf( '%2.2f%% of Trials Completed.', 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
            JobInfo = obj.UpdateJobInfo( JobInfo, 'Status', msgStatusFile );
            % Save simulation progress in STATUS file. Update Results file.
            % if( nargin>=5 && ~isempty(JobName) && ~isempty(JobRunningDir) )
            % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
            % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
            
            % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
            % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
            % end
            
            Results = struct( 'CompletedTrials', CompletedTJob, 'RemainingTrials', RemainingTJob );
            % Results = struct( 'SNR', num2str(JobParam.SNR), ...
            %     'Trials', num2str(JobState.Trials), ...
            %     'BER', num2str(JobState.BER), ...
            %     'FER', num2str(JobState.FER), ...
            %     'Progress', msgStatus);
            
            JobInfo = obj.UpdateJobInfo( JobInfo, 'Results', Results );
            
            varargout{1} = JobParam;
            varargout{2} = JobState;
        end
        
        
        function NumProcessUnit = FindNumProcessUnits(obj, TaskState)
            NumProcessUnit = sum(TaskState.Trials(end,:));
        end
        
    end
    
end