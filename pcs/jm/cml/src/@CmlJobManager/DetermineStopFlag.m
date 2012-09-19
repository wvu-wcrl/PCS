function [StopFlag, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobName, Username, JobRunningDir)
% Determine if the global stopping criteria have been reached/met. Moreover, determine and echo progress of running JobName.
% Furthermore, update Results file.
% Calling syntax: [StopFlag [,JobParam]] = obj.DetermineStopFlag(JobParam, JobState [,JobName] [,Username] [,JobRunningDir])


[RemainingTrials RemainingFrameErrors] =  CheckRemainingMetrics( JobParam, JobState );  

% Determine the position of active SNR points based on the number of remaining trials and frame errors.
ActiveSNRPoints = GetActiveSnrPoints( RemainingTrials, RemainingFrameErrors, JobParam );    

switch JobParam.sim_type,    
    case {'coded', 'uncoded'},
% Determine if we can discard some SNR points whose BER or FER WILL be less than JobParam.minBER/minFER.
LastInactivePoint = FindLastInactivePoint( ActiveSNRPoints );

StopFlagT = ComputeStopFlagT( LastInactivePoint, ActiveSNRPoints, JobParam, JobState );  

ActiveSNRPoints = PrintSnrStopMsg( StopFlagT, ActiveSNRPoints, LastInactivePoint, JobName, Username, JobParam, obj );
end
   
JobParam = SetMaxTrials( JobParam, JobState, ActiveSNRPoints ); %

StopFlag = TestIfAllSnrsDone( ActiveSNRPoints );

PrintJobStopMsg( StopFlag, JobName, Username, obj, nargin );

JobParam = SaveProgress( ActiveSNRPoints, RemainingTrials, JobState, JobName, Username, obj, JobParam,...
    nargin, JobRunningDir);

varargout{1} = JobParam;   
    

end






function [RemainingTrials RemainingFrameErrors] =  CheckRemainingMetrics( JobParam, JobState )

switch JobParam.sim_type,
    case {'uncoded', 'coded'},
% First check to see if minimum number of trials or frame errors has been reached.
RemainingTrials = JobParam.max_trials - JobState.trials(end,:);
RemainingTrials(RemainingTrials<0) = 0;             % Force to zero if negative.
RemainingFrameErrors = JobParam.max_frame_errors - JobState.frame_errors(end,:);
RemainingFrameErrors(RemainingFrameErrors<0) = 0;   % Force to zero if negative.
    
    case {'exit'},
        RemainingTrials = JobParam.max_trials - JobState.trials;
        RemainingTrials(RemainingTrials<0) = 0;
        RemainingFrameErrors = 0;  %%%% refactor - replace output args with varargout
end

end



function ActiveSNRPoints = GetActiveSnrPoints( RemainingTrials, RemainingFrameErrors, JobParam )

switch JobParam.sim_type,
    case {'uncoded', 'coded'},
        ActiveSNRPoints  = ( (RemainingTrials>0) & (RemainingFrameErrors>0) );
    case{'exit'},
        ActiveSNRPoints  = ( RemainingTrials > 0);
end
end



function LastInactivePoint = FindLastInactivePoint( ActiveSNRPoints )
LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
end




function StopFlagT = ComputeStopFlagT( LastInactivePoint, ActiveSNRPoints, JobParam, JobState )
StopFlagT = ~isempty(LastInactivePoint) && ( LastInactivePoint ~= length(ActiveSNRPoints) ) && ...
    ... % Changed on February 24, 2012. When SNR point is inactive, its BER or FER CAN be ZERO.
    ... ( ( (JobState.BER(end, LastInactivePoint) ~=0) && (JobState.BER(end, LastInactivePoint) < JobParam.minBER) ) || ...
    ... ( (JobState.FER(end, LastInactivePoint) ~=0) && (JobState.FER(end, LastInactivePoint) < JobParam.minFER) ) );
    (JobState.BER(end,LastInactivePoint) < JobParam.minBER || JobState.FER(end,LastInactivePoint) < JobParam.minFER);
end


function ActiveSNRPoints = PrintSnrStopMsg( StopFlagT, ActiveSNRPoints, LastInactivePoint, JobName, Username, JobParam, obj )

if StopFlagT == 1
    ActiveSNRPoints(LastInactivePoint:end) = 0;
    if( nargin>=4 && ~isempty(JobName) && ~isempty(Username) )
        Msg = sprintf( ['\n\nRunning job %s for user %s is STOPPED for SOME SNR points above %.2f dB because their BER or' ...
            'FER is below the required mimimum BER or FER.\n\n'], JobName(1:end-4), Username, JobParam.SNR(LastInactivePoint) );
        PrintOut(Msg, 0, obj.JobManagerParam.LogFileName);
    end
end
end


function JobParam = SetMaxTrials( JobParam, JobState, ActiveSNRPoints )
JobParam.max_trials(ActiveSNRPoints==0) = JobState.trials(end,ActiveSNRPoints==0);
end


function StopFlag = TestIfAllSnrsDone( ActiveSNRPoints )
StopFlag = ( sum(ActiveSNRPoints) == 0 );
end


function PrintJobStopMsg( StopFlag, JobName, Username, obj, narginC )
if StopFlag == 1
    
    switch JobParam.sim_type,
        case {'uncoded', 'coded'},
    if( narginC >=4 && ~isempty(JobName) && ~isempty(Username) )
        StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials and/or ',...
            'frame errors are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
        StopMsg
        PrintOut(StopMsg, 0, obj.JobManagerParam.LogFileName);
    end
    
        case {'exit'},
        if( narginC>=4 && ~isempty(JobName) && ~isempty(Username) )
        StopMsg = sprintf( ['\n\nRunning job %s for user %s is STOPPED completely because enough trials',...
        ' are observed for ALL SNR points.\n\n'], JobName(1:end-4), Username );
        PrintOut(StopMsg, 0, obj.JobManagerParam.LogFileName);        
        end
    end
end
end



function JobParam = SaveProgress( ActiveSNRPoints, RemainingTrials, JobState, JobName, Username, obj, JobParam, ...
    narginC, JobRunningDir)
% Determine and echo progress of running JobName.
RemainingTJob = sum( (ActiveSNRPoints==1) .* RemainingTrials );
CompletedTJob = sum( JobState.trials(end,:) );
% RemainingFEJob = sum( (ActiveSNRPoints==1) .* RemainingFrameErrors );
% CompletedFEJob = sum( JobState.frame_errors(end,:) );
if( narginC >=4 && ~isempty(JobName) && ~isempty(Username) )
    MsgStr = sprintf( ' for JOB %s USER %s', JobName(1:end-4), Username );
else
    MsgStr = ' ';
end
msgStatus = sprintf( ['PROGRESS UPDATE', MsgStr, ':\r\nTotal Trials Completed=%d\r\nTotal Trials Remaining=%d\r\nPercentage of Trials Completed=%2.4f'],...
    CompletedTJob, RemainingTJob, 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
PrintOut(['\n\n', msgStatus, '\n\n'], 0, obj.JobManagerParam.LogFileName);
msgResults = sprintf( 'SNR Points Completed=%.2f\n', JobParam.SNR(ActiveSNRPoints==0) );


% Save simulation progress in STATUS file. Update Results file.
if( narginC>=4 && ~isempty(JobName) && ~isempty(JobRunningDir) )
    msgStatusFile = sprintf( '%2.2f%% of Trials Completed.', 100*CompletedTJob/(CompletedTJob+RemainingTJob) );
    % SuccessFlagStatus = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
    obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Status.txt'], msgStatusFile, 'w+');
    
    % SuccessFlagResults = obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
    obj.UpdateResultsStatusFile(JobRunningDir, [JobName(1:end-4) '_Results.txt'], [msgResults '\r\n' msgStatus], 'w+');
end




end
