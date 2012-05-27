classdef BECJobManager < CodedModJobManager

    methods
        function obj = BECJobManager(cfgRoot)
            % Binary Erasure Channel Simulation Job Manager.
            % Calling syntax: obj = BECJobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'LDPC-BEC';
            % CFG_Filename = 'LDPC-BECJobManager_cfg.txt';
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            addpath(fullfile(filesep,'home','pcs','jm','CodedMod','src'));
            obj@CodedModJobManager(cfgRoot);
        end


        function [StopFlag, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobName, Username, JobRunningDir)
            % Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
            % Furthermore, update Results file.
            % Calling syntax: [StopFlag [,JobParam]] = obj.DetermineStopFlag(JobParam, JobState [,JobName] [,Username] [,JobRunningDir])

            % First check to see if minimum number of trials or frame errors has been reached.
            % Determine the number of remaining trials reqiured for each Epsilon point.
            RemainingTrials = JobParam.MaxTrials - JobState.Trials;
            RemainingTrials(RemainingTrials<0) = 0;             % Force to zero if negative.
            % Determine the number of remaining frame errors reqiured for each Epsilon point.
            RemainingFrameErrors = JobParam.MaxFrameErrors - JobState.FrameErrors(end,:);
            RemainingFrameErrors(RemainingFrameErrors<0) = 0;   % Force to zero if negative.

            % Determine the position of active Epsilon points based on the number of remaining trials and frame errors.
            ActiveEpsilonPoints  = ( (RemainingTrials>0) & (RemainingFrameErrors>0) );

            % JobParam.MaxTrials(ActiveEpsilonPoints==0) = JobState.Trials(ActiveEpsilonPoints==0);

            % Set the stopping flag.
            StopFlag = ( sum(ActiveEpsilonPoints) == 0 );

            if StopFlag == 1
                if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                    StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
                        'frame errors are observed for ALL Epsilon points.\n\n'], JobName(1:end-4), Username );
                    PrintOut(StopMsg, 0, obj.JobManagerParam.LogFileName);
                end
            end

            % Determine and echo progress of running JobName.
            RemainingTJob = sum( (ActiveEpsilonPoints==1) .* RemainingTrials );
            CompletedTJob = sum( JobState.Trials );
            % RemainingFEJob = sum( (ActiveEpsilonPoints==1) .* RemainingFrameErrors );
            % CompletedFEJob = sum( JobState.FrameErrors(end,:) );
            if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
                MsgStr = sprintf( ' for JOB %s USER %s', JobName(1:end-4), Username );
            else
                MsgStr = ' ';
            end
            msgStatus = sprintf( ['PROGRESS UPDATE', MsgStr, ':\r\nTotal Trials Completed=%d\r\nTotal Trials Remaining=%d\r\nPercentage of Trials Completed=%2.4f'],...
                CompletedTJob, RemainingTJob, 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
            PrintOut(['\n\n', msgStatus, '\n\n'], 0, obj.JobManagerParam.LogFileName);
            % msgResults = sprintf( 'Epsilon Points Completed=%.4f\n', JobParam.Epsilon(ActiveEpsilonPoints==0) );
            if JobParam.HStructInfo.FullRankFlag == 1
                FullRank = 'Yes';
            else
                FullRank = 'NO';
            end
            
            % Determine the largest value of Epsilon for which the BER is less than 10^-2 after JobParam.MaxIteration decoding iterations.
            EpsilonStarSim = JobParam.Epsilon( find( JobState.BER(end,:) < 1e-2, 1, 'last' ) );
            if isempty(EpsilonStarSim)
                EpsilonStarSimMsg = sprintf('The BER after MaxIteration decoding iterations in the specified range of Epsilon from %.4f to %.4f is always greater than 10^-2.',...
                    min(JobParam.Epsilon), max(JobParam.Epsilon));
            else
                EpsilonStarSimMsg = num2str(EpsilonStarSim);
            end
            msgResults = sprintf( 'DataLength (k)=%d\r\nCodewordLength (n)=%d\r\nCodeRate=%.4f\r\nFullRank=%s\r\nEpsilonStarDE=%.8f\r\nEpsilonStarSimulation=%s',...
                JobParam.HStructInfo.DataLength, JobParam.HStructInfo.CodewordLength, JobParam.HStructInfo.CodeRate, FullRank, JobParam.HStructInfo.EpsilonStarDE, EpsilonStarSimMsg );

            % Save simulation progress in STATUS file. Update Results file.
            if( nargin>=4 && ~isempty(JobName) && ~isempty(JobRunningDir) )
                msgStatusFile = sprintf( '%2.4f%% of Trials Completed.', 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
                % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');

                % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
                % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
                obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], msgResults, 'w+');
            end
            varargout{1} = JobParam;
            
            % Plot the results.
            FigH = figure;
            semilogy(JobParam.Epsilon,JobState.BER(end,:),'-sb', 'LineWidth',1.5, 'MarkerSize',3)
            hold on, grid on, box on, set(gca,'FontSize',12)
            % set(gca,'FontSize',12, 'FontName','Times', 'FontWeight','normal')
            xlim([min(JobParam.Epsilon) max(JobParam.Epsilon)])
            xlabel('Channel Erasure Probability (\epsilon_0)')
            ylabel('Channel Erasure Probability After 100 Iterations (\epsilon_{100})')
            try
                saveas( FigH, fullfile(JobRunningDir, [JobName(1:end-4) '_Fig.pdf']) );
            catch
                saveas( FigH, fullfile(obj.JobManagerParam.TempJMDir, [JobName(1:end-4) '_FigResults.pdf']) );
                obj.MoveFile( fullfile(obj.JobManagerParam.TempJMDir, [JobName(1:end-4) '_FigResults.pdf']), JobRunningDir);
            end
        end
    end

end