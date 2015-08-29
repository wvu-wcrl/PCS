function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
% Assign the Task State Matching Score to the JobState
JobState.MatchingScore=TaskState.MatchingScore;
end
