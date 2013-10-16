function [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)
% Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
% Furthermore, update Results file.
% Calling syntax: [StopFlag, JobInfo [,JobParam] [,JobState]] = obj.DetermineStopFlag(JobParam, JobState, JobInfo [,JobName] [,Username] [,FiguresDir])

[RemainingTrials RemainingFrameErrors RemainingMI] =  obj.UpdateRemainingMetrics( JobParam, JobState );

% Determine the position of active SNR points based on the number of remaining trials and frame errors.
ActiveSNRPoints = obj.FindActiveSnrPoints( RemainingTrials, RemainingFrameErrors, RemainingMI, JobParam.sim_type, JobParam.exit_param );

switch JobParam.sim_type
    case {'coded', 'uncoded'}
        % Determine if we can discard some SNR points whose BER or FER WILL be less than JobParam.minBER/minFER.
        LastInactivePoint = FindLastInactivePoint( ActiveSNRPoints );
        
        StopFlagT = ComputeStopFlagT( LastInactivePoint, ActiveSNRPoints, JobParam, JobState );
        
        if StopFlagT == 1
            ActiveSNRPoints = PrintSnrDiscardMsg( ActiveSNRPoints, LastInactivePoint, ...
                JobName, Username, JobParam.SNR(LastInactivePoint), obj.JobManagerParam.LogFileName );
        end
end

JobParam = SetMaxTrials( JobParam, JobState, ActiveSNRPoints );

StopFlag = TestIfAllSnrsDone( ActiveSNRPoints ); % If all done, enter stage 2.

if StopFlag == 1
    PrintJobStopMsg( JobParam.sim_type, JobName, Username, obj.JobManagerParam.LogFileName );
    
    switch JobParam.sim_type,
        case {'exit'}
            if strcmp( JobParam.exit_param.exit_phase, 'detector' )
                JobState.exit_state.det_complete = 1;
            end
    end
    
    
end

[JobParam, JobInfo] = SaveJobProgress( obj, ActiveSNRPoints, RemainingTrials, JobParam, JobState, JobInfo, JobName, Username );

obj.PlotResults( JobParam, JobState, FiguresDir, JobName, obj.JobManagerParam.TempJMDir );

varargout{1} = JobParam;
varargout{2}= JobState;
end


function LastInactivePoint = FindLastInactivePoint( ActiveSNRPoints )
LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
end


function StopFlagT = ComputeStopFlagT( LastInactivePoint, ActiveSNRPoints, JobParam, JobState )
if( ~isempty(JobParam.minFER) && strcmpi(JobParam.sim_type, 'coded') )
    MinFerCond = JobState.FER(end,LastInactivePoint) < JobParam.minFER;
else
    MinFerCond = false;
end

StopFlagT = ~isempty(LastInactivePoint) && ( LastInactivePoint ~= length(ActiveSNRPoints) ) && ...
    ... % Changed on February 24, 2012. When SNR point is inactive, its BER or FER CAN be ZERO.
    ... ( ( (JobState.BER(end, LastInactivePoint) ~=0) && (JobState.BER(end, LastInactivePoint) < JobParam.minBER) ) || ...
    ... ( (JobState.FER(end, LastInactivePoint) ~=0) && (JobState.FER(end, LastInactivePoint) < JobParam.minFER) ) );
    (JobState.BER(end,LastInactivePoint) < JobParam.minBER || MinFerCond);
end


function ActiveSNRPoints = PrintSnrDiscardMsg( ActiveSNRPoints, LastInactivePoint, JobName, Username, LastSNR, LogFileName )

ActiveSNRPoints(LastInactivePoint:end) = 0;
if( nargin>=3 && ~isempty(JobName) && ~isempty(Username) && ~isempty(LastSNR) && ~isempty(LogFileName) )
    Msg = sprintf( ['\n\nRunning job %s for user %s is STOPPED for SOME SNR points above %.2f dB because their BER or' ...
        'FER is below the required mimimum BER or FER.\n\n'], JobName(1:end-4), Username,  LastSNR);
    PrintOut(Msg, 0, LogFileName);
end
end


function JobParam = SetMaxTrials( JobParam, JobState, ActiveSNRPoints )
JobParam.max_trials(ActiveSNRPoints==0) = JobState.trials(end,ActiveSNRPoints==0);
end


function StopFlag = TestIfAllSnrsDone( ActiveSNRPoints )
StopFlag = ( sum(ActiveSNRPoints) == 0 );
end


function PrintJobStopMsg( SimType, JobName, Username, LogFileName )

if( nargin >= 2 && ~isempty(JobName) && ~isempty(Username) && ~isempty(LogFileName) )
    switch SimType
        case {'uncoded', 'coded'}
            StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
                'frame errors are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
        case{'exit'}
            StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials ',...
                'are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
        otherwise
            StopMsg =  '';
    end
    PrintOut(StopMsg, 0, LogFileName);
end
end


function [JobParam, JobInfo] = SaveJobProgress( obj, ActiveSNRPoints, RemainingTrials, JobParam, JobState, JobInfo, JobName, Username )
% Determine and echo progress of running JobName.

RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
CompletedTJob = sum( JobState.trials(end,:) );
% RemainingFEJob = sum( (ActiveSNRPoints==1) .* RemainingFrameErrors );
% CompletedFEJob = sum( JobState.frame_errors(end,:) );

if( nargin >= 7 && ~isempty(JobName) && ~isempty(Username) )
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
% if( nargin >= 7 && ~isempty(JobName) && ~isempty(JobRunningDir) )
    % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
    % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
    
    % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
    % obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
% end

Results = struct( 'CompletedTrials', CompletedTJob, 'RemainingTrials', RemainingTJob );
% if strcmpi(JobParam.sim_type, 'uncoded')
%     Results = struct( 'SNR', num2str(JobParam.SNR), ...
%         'Trials', num2str(JobState.trials), ...
%         'BER', num2str(JobState.BER), ...
%         'SER', num2str(JobState.SER), ...
%         'Progress', msgStatus );
% elseif strcmpi(JobParam.sim_type, 'coded')
%     Results = struct( 'SNR', num2str(JobParam.SNR), ...
%         'Trials', num2str(JobState.trials), ...
%         'BER', num2str(JobState.BER), ...
%         'FER', num2str(JobState.FER), ...
%         'Progress', msgStatus );
%%% ******************************************************************** %%%
%%% The RESULTS structure should be formatted properly for other simulation types.
%%% ******************************************************************** %%%
% end

JobInfo = obj.UpdateJobInfo( JobInfo, 'Results', Results );
end
