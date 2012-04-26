classdef CodedModJobManager < JobManager

    methods
        function obj = CodedModJobManager(cfgRoot)
            % Coded-Modulation Simulation Job Manager.
            % Calling syntax: obj = CodedModJobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'CodedMod';
            % CFG_Filename = 'CodedModJobManager_cfg.txt';
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            obj@JobManager(cfgRoot);
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
            TaskInputParam.MaxTrials = JobParam.MaxTrials - JobState.Trials;
            TaskInputParam.MaxTrials(TaskInputParam.MaxTrials<0) = 0;
            
            TaskInputParam.MaxTrials = ceil(TaskInputParam.MaxTrials/NumNewTasks);
        end


        function JobState = UpdateJobState(obj, JobStateIn, TaskState)
            % Update the Global JobState.
            JobState = JobStateIn;
            JobState.Trials      = JobState.Trials      + TaskState.Trials;
            JobState.BitErrors   = JobState.BitErrors   + TaskState.BitErrors;
            JobState.FrameErrors = JobState.FrameErrors + TaskState.FrameErrors;

            Trials = repmat(JobState.Trials,[size(JobState.BitErrors,1) 1]);
            JobState.BER         = JobState.BitErrors   ./ ( Trials * TaskState.NumCodewords * TaskState.DataLength );
            JobState.FER         = JobState.FrameErrors ./ ( Trials * TaskState.NumCodewords );
        end


        function [StopFlag, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobName, Username, JobRunningDir)
            % Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
            % Furthermore, update Results file.
            % Calling syntax: [StopFlag [,JobParam]] = obj.DetermineStopFlag(JobParam, JobState [,JobName] [,Username] [,JobRunningDir])

            % First check to see if minimum number of trials or frame errors has been reached.
            RemainingTrials = JobParam.MaxTrials - JobState.Trials;
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
                if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                    msg = sprintf( ['\n\nRunning job %s for user %s is STOPPED for SOME SNR points above %.2f dB because their BER or' ...
                        'FER is below the required mimimum BER or FER.\n\n'], JobName(1:end-4), Username, JobParam.SNR(LastInactivePoint) );
                    obj.PrintOut(msg, 0);
                end
            end

            JobParam.MaxTrials(ActiveSNRPoints==0) = JobState.Trials(ActiveSNRPoints==0);

            % Set the stopping flag.
            StopFlag = ( sum(ActiveSNRPoints) == 0 );

            if StopFlag == 1
                if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                    StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
                        'frame errors are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
                    obj.PrintOut(StopMsg, 0);
                end
            end
            
            % Determine and echo progress of running JobName.
            RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
            CompletedTJob = sum( JobState.Trials );
            % RemainingFEJob = sum( (ActiveSNRPoints==1) .* RemainingFrameErrors );
            % CompletedFEJob = sum( JobState.FrameErrors(end,:) );
            if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                MsgStr = sprintf( ' for JOB %s USER %s', JobName(1:end-4), Username );
            else
                MsgStr = ' ';
            end
            msgStatus = sprintf( ['PROGRESS UPDATE', MsgStr, ':\r\nTotal Trials Completed=%d\r\nTotal Trials Remaining=%d\r\nPercentage of Trials Completed=%2.4f'],...
                CompletedTJob, RemainingTJob, 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
            obj.PrintOut(['\n\n', msgStatus, '\n\n'], 0);
            msgResults = sprintf( 'SNR Points Completed=%.1f\t', JobParam.SNR(ActiveSNRPoints==0) );

            % Save simulation progress in STATUS file. Update Results file.
            if( nargin>=4 && ~isempty(JobName) && ~isempty(JobRunningDir) )
                msgStatusFile = sprintf( '%2.2f%% of Trials Completed', 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
                % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');

                % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n\r\n' msgStatus], 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n\r\n' msgStatus], 'w+');
            end

            varargout{1} = JobParam;
        end
    end

end