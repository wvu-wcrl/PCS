classdef CmlJobManager < JobManager
    

    methods( Static, Access = protected )
        function CmlRHome = RenameLocalCmlHome(CmlHome)
            CmlRHome = CmlHome;
            if ~ispc
                [Dummy EndPath] = strtok(CmlHome, filesep);
                CmlRHome = fullfile(filesep,'rhome',EndPath);
            end
        end
    end

    
    methods
        function obj = CmlJobManager(cfgRoot)
            % Distributed CML Simulation Job Manager.
            % Calling syntax: obj = CmlJobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'cml';
            % CFG_Filename = 'CmlJobManager_cfg';
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            obj@JobManager(cfgRoot);
        end


        function [JobParam, JobState] = PreProcessJob(obj, JobParamIn, JobStateIn, CodeRoot)
            
            % First, set the path.
            OldPath = obj.SetCodePath(CodeRoot);
            
            [JobParam, CodeParam] = InitializeCodeParam( JobParamIn, CodeRoot );
            JobParam.code_param_short = CodeParam;
            
            JobParam.cml_rhome = obj.RenameLocalCmlHome(CodeRoot);
            
            JobState = JobStateIn;
            JobState.data_bits_per_frame = CodeParam.data_bits_per_frame;
            JobState.sim_type = JobParam.sim_type;
            JobState.symbols_per_frame = CodeParam.symbols_per_frame;
            
            path(OldPath);
        end


        function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
            % Calculate TaskInputParam based on the number of remaining errors and trials AND the number of new tasks to be generated.
            % TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.
            % If the InputParam is the same for all tasks, TaskInputParam can be 1-by-1.
            
            JobParam.max_frame_errors = JobParam.max_frame_errors - JobState.frame_errors(end,:);
            JobParam.max_frame_errors(JobParam.max_frame_errors<0) = 0;
            % JobParam.MaxBitErrors = JobParam.MaxBitErrors - JobState.BitErrors(end,:);
            % JobParam.MaxBitErrors(JobParam.MaxBitErrors<0) = 0;
            JobParam.max_trials = JobParam.max_trials - JobState.trials;
            JobParam.max_trials(JobParam.max_trials<0) = 0;
            
            JobParam.max_trials = ceil(JobParam.max_trials/NumNewTasks);
            
            % Derive data_bits_per_frame to be used in BER calculation in UpdateJobState method.
%             if isempty(JobParam.code_configuration)
%                 data_bits_per_frame = JobParam.framesize;
%             else
%                 switch JobParam.code_configuration
%                     case {1} % PCCC.
%                         code_interleaver = eval( JobParam.code_interleaver );
%                         data_bits_per_frame = length( code_interleaver );
%                     case {2} % LDPC.
%                         [H_rows, H_cols, P_matrix ] = eval( JobParam.parity_check_matrix );
%                         data_bits_per_frame = length(H_cols) - length( P_matrix );
%                     case {3} % HSDPA.
%                         % Derived constants.
%                         K_crc = JobParam.framesize + 24; % add CRC bits.
%                         
%                         % See if there needs to be more than one block.
%                         number_codewords = ceil( K_crc/5114 ); % number of blocks.
%                         data_bits_per_block = ceil( K_crc/number_codewords ); % length of each block.
%                         data_bits_per_frame = number_codewords*data_bits_per_block; % includes the filler bits, if any.
%                     case {4} % UMTS Turbo code.
%                         % Code interleaver.
%                         code_interleaver = strcat( 'CreateUmtsInterleaver(', int2str(JobParam.framesize ), ')' );
%                         code_interleaver = eval( code_interleaver );
%                         data_bits_per_frame = length( code_interleaver );
%                     case {5} % Wimax CTC code.
%                         data_bits_per_frame = JobParam.framesize;
%                     case {6} % DVB-RCS turbo code.
%                         data_bits_per_frame = JobParam.framesize;
%                     otherwise % Convolutional (0) or BTC (7).
%                         data_bits_per_frame = JobParam.framesize;
%                 end
%             end
%             JobState.data_bits_per_frame = JobParam.code_param_short.data_bits_per_frame;
%             JobState.sim_type = JobParam.sim_type;
            
%             if strcmpi( JobParam.sim_type, 'coded' )
%                 data = zeros(1, data_bits_per_frame);
%                 % [s, codeword] = CmlEncode( data, JobParam, code_param );
%                 % symbols_per_frame = length( s );
%             elseif( strcmpi( JobParam.sim_type, 'uncoded' ) || strcmpi( JobParam.sim_type, 'capacity' ) )
%                 symbols_per_frame = JobParam.framesize;
%             elseif strcmpi( JobParam.sim_type, 'bloutage' )
%                 symbols_per_frame = ceil( JobParam.framesize/JobParam.rate );
%             end
%             JobState.symbols_per_frame = JobParam.code_param_short.symbols_per_frame;

            % Initialize TaskInputParam structure.
            TaskInputParam(1:NumNewTasks,1) = struct('JobParam', JobParam, 'JobState', JobState);
            
            % Randomly permute the position of SNR points for each task.
            SNR = JobParam.SNR;
            max_trials = JobParam.max_trials;
            max_frame_errors = JobParam.max_frame_errors;
            
            trials = JobState.trials;
            bit_errors = JobState.bit_errors;
            %BER = JobState.BER;
            frame_errors = JobState.frame_errors;
            %FER = JobState.FER;
            if ~strcmpi( JobState.sim_type, 'coded' )
                symbol_errors = JobState.symbol_errors;
                %SER = JobState.SER;
            end
            
            for Task=1:NumNewTasks
                RandPos = randperm( length(SNR) );
                TaskInputParam(Task).JobState.RandPos = RandPos;
                
                TaskInputParam(Task).JobParam.SNR = SNR( RandPos );
                TaskInputParam(Task).JobParam.max_trials = max_trials( RandPos );
                TaskInputParam(Task).JobParam.max_frame_errors = max_frame_errors( RandPos );
                
                TaskInputParam(Task).JobState.trials = trials( :,RandPos );
                TaskInputParam(Task).JobState.bit_errors = bit_errors( :,RandPos );
                %TaskInputParam(Task).JobState.BER = BER( :,RandPos );
                TaskInputParam(Task).JobState.frame_errors = frame_errors( :,RandPos );
                %TaskInputParam(Task).JobState.FER = FER( :,RandPos );
                if ~strcmpi( JobState.sim_type, 'coded' )
                    TaskInputParam(Task).JobState.symbol_errors = symbol_errors( :,RandPos );
                    %TaskInputParam(Task).JobState.SER = SER( :,RandPos );
                end
            end
        end


        function JobState = UpdateJobState(obj, JobStateIn, TaskState)
            % Update the Global JobState.
            JobState = JobStateIn;
            
            % Convert the randomly-permuted SNR points of the task back to the order in which the JobState is saved.
            TaskState.trials(:,TaskState.RandPos) = TaskState.trials;
            TaskState.bit_errors(:,TaskState.RandPos) = TaskState.bit_errors;
            TaskState.frame_errors(:,TaskState.RandPos) = TaskState.frame_errors;
            
            JobState.trials      = JobState.trials      + TaskState.trials;
            if ~strcmpi( JobState.sim_type, 'bloutage' )
                JobState.bit_errors   = JobState.bit_errors   + TaskState.bit_errors;
                JobState.frame_errors = JobState.frame_errors + TaskState.frame_errors;
                
                JobState.BER = JobState.bit_errors   ./ ( JobState.trials * JobState.data_bits_per_frame );
                JobState.FER = JobState.frame_errors ./ JobState.trials;
                
                % If uncoded, update symbol error rate, too.
                if ~strcmpi( JobState.sim_type, 'coded' )
                    if( JobParam.mod_order > 2 )
                        % Update symbol error counter.
                        TaskState.symbol_errors(:,TaskState.RandPos) = TaskState.symbol_errors;
                        JobState.symbol_errors = JobState.symbol_errors + TaskState.symbol_errors;
                        JobState.SER = JobState.symbol_errors / ( JobState.trials * JobState.symbols_per_frame );
                    else
                        JobState.symbol_errors = JobState.bit_errors;
                        JobState.SER = JobState.BER;
                    end
                end
                
            end
        end


        function [StopFlag, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobName, Username, JobRunningDir)
            % Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
            % Furthermore, update Results file.
            % Calling syntax: [StopFlag [,JobParam]] = obj.DetermineStopFlag(JobParam, JobState [,JobName] [,Username] [,JobRunningDir])

            % First check to see if minimum number of trials or frame errors has been reached.
            RemainingTrials = JobParam.max_trials - JobState.trials;
            RemainingTrials(RemainingTrials<0) = 0;             % Force to zero if negative.
            RemainingFrameErrors = JobParam.max_frame_errors - JobState.frame_errors(end,:);
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
                if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                    Msg = sprintf( ['\n\nRunning job %s for user %s is STOPPED for SOME SNR points above %.2f dB because their BER or' ...
                        'FER is below the required mimimum BER or FER.\n\n'], JobName(1:end-4), Username, JobParam.SNR(LastInactivePoint) );
                    PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
                end
            end

            JobParam.max_trials(ActiveSNRPoints==0) = JobState.trials(ActiveSNRPoints==0);

            % Set the stopping flag.
            StopFlag = ( sum(ActiveSNRPoints) == 0 );

            if StopFlag == 1
                if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                    StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
                        'frame errors are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
                    PrintOut(StopMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end

            % Determine and echo progress of running JobName.
            RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
            CompletedTJob = sum( JobState.trials );
            % RemainingFEJob = sum( (ActiveSNRPoints==1) .* RemainingFrameErrors );
            % CompletedFEJob = sum( JobState.frame_errors(end,:) );
            if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                MsgStr = sprintf( ' for JOB %s USER %s', JobName(1:end-4), Username );
            else
                MsgStr = ' ';
            end
            msgStatus = sprintf( ['PROGRESS UPDATE', MsgStr, ':\r\nTotal Trials Completed=%d\r\nTotal Trials Remaining=%d\r\nPercentage of Trials Completed=%2.4f'],...
                CompletedTJob, RemainingTJob, 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
            PrintOut(['\n\n', msgStatus, '\n\n'], 0, obj.JobManagerParam.LogFileName);
            msgResults = sprintf( 'SNR Points Completed=%.2f\n', JobParam.SNR(ActiveSNRPoints==0) );

            % Save simulation progress in STATUS file. Update Results file.
            if( nargin>=4 && ~isempty(JobName) && ~isempty(JobRunningDir) )
                msgStatusFile = sprintf( '%2.2f%% of Trials Completed.', 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
                % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');

                % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
            end

            varargout{1} = JobParam;
        end
    end

end