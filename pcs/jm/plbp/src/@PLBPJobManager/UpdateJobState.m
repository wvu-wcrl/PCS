function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)

JobState = JobStateIn; % Update the Global JobState.

switch JobParam.TaskType
    case{'Identification'}
        Count = JobState.CompletedTasks + 1;
        JobState.CompletedTasks = Count;
        
        if JobState.CompletedTasks >= 1
            cnt = size(TaskState.Distance, 1);
            if ~isfield(JobState, 'G2TDist')
                p_cnt = 0;
            else
                p_cnt = size(JobState.G2TDist, 1);
            end
            
            JobState.G2TDist((p_cnt+1):(p_cnt+cnt),:) = TaskState.Distance;
            JobState.G2TClassID((p_cnt+1):(p_cnt+cnt),:) = TaskState.InputParam.ClassID;
            JobState.G2TFilenames((p_cnt+1):(p_cnt+cnt),:) = TaskState.InputParam.Filenames(1:cnt,:);
            
            [JobState.Distance(Count,:), index] = min(TaskState.Distance); % Find Nearest Neighbor.
            JobState.MatchClassID(Count,:) = TaskState.InputParam.ClassID(index);
            JobState.MatchFilename(Count,:) = {TaskState.InputParam.Filenames(index)};
        end
        
        if JobState.CompletedTasks >= JobParam.TaskCount
            % [JobState.MinDist, ind] = min(JobState.Distance);
            % JobState.MinDist_ClassID = JobState.MatchClassID(ind);
            % JobState.MinDist_Filename = JobState.MatchFilename(ind);
            % Get 3 closest templates 
            [JobState.MinDist, ClosestNDistanceIndices] = GetNCloserDistance(JobState.G2TDist, 3);
            JobState.MinDist_ClassID = JobState.G2TClassID(ClosestNDistanceIndices);  
            JobState.MinDist_Filename = JobState.G2TFilenames(ClosestNDistanceIndices); 
        end
        
    case{'Verification'}
        Count = JobState.CompletedTasks + 1;
        JobState.CompletedTasks = Count;
        if JobState.CompletedTasks >= 1
            cnt = size(TaskState.Distance, 1);
            if ~isfield(JobState, 'G2TDist')
                p_cnt = 0;
            else
                p_cnt = size(JobState.G2TDist, 1);
            end
            JobState.G2TDist((p_cnt+1):(p_cnt+cnt),:) = TaskState.Distance;
            JobState.G2TClassID((p_cnt+1):(p_cnt+cnt),:) = TaskState.InputParam.ClassID;
            JobState.G2TFilenames((p_cnt+1):(p_cnt+cnt),:) = TaskState.InputParam.Filenames(1:cnt,:);
            
            [JobState.Distance(Count,:), index] = min(TaskState.Distance);   % find Nearest Neighbor.
            JobState.MatchClassID(Count,:) = TaskState.InputParam.ClassID(index);
            JobState.MatchFilename(Count,:) = TaskState.InputParam.Filenames(index);
        end
        
        if JobState.CompletedTasks >= JobParam.TaskCount
            [JobState.MinDist, ind] = min(JobState.Distance);
            JobState.MinDist_ClassID = JobState.MatchClassID(ind);
            JobState.MinDist_Filename = JobState.MatchFilename(ind);
            
            if strcmp(JobParam.TestClassID, JobState.MinDist_ClassID) == 1
                JobState.Match = 'Yes';
            else
                JobState.Match = 'No';
            end
        end
        
    case{'Model'}
        Count = JobState.CompletedTasks + 1;
        JobState.CompletedTasks = Count;
        
        if JobState.CompletedTasks == 1
            JobState.Model = TaskState.LBP_Pattern;
            JobState.ClassID = TaskState.TrainClassID;
            JobState.Filenames = TaskState.Filenames;
        elseif JobState.CompletedTasks > 1
            ind_cnt = size(TaskState.LBP_Pattern,1);
            cnt = size(JobState.Model,1);
            JobState.Model((cnt+1) : (cnt+ind_cnt),:) = TaskState.LBP_Pattern;
            JobState.ClassID((cnt+1) : (cnt+ind_cnt),:) = TaskState.TrainClassID;
            JobState.Filenames((cnt+1) : (cnt+ind_cnt),:) = TaskState.Filenames;
        end
end
end

function [ClosestNDistance, ClosestNDistanceIndices] = GetNCloserDistance(Distance, N)
     [SortedDistance, DistanceIndex] = sort(Distance);
     ClosestNDistance = SortedDistance(1:N);
     ClosestNDistanceIndices = DistanceIndex(1:N);
end

function [Match, ClassificationAccuracyValue] = ClassificationAccuracy(TrainClassIDs, TestClassIDs)
CorrectClassificationCount = 0;
Match = zeros(length(TestClassIDs),2);
for i=1:length(TestClassIDs);
    Match(i,:) = [TrainClassIDs(i) TestClassIDs(i)];
    if TrainClassIDs(i) == TestClassIDs(i)  % judge whether the nearest one is correctly classified.
        CorrectClassificationCount = CorrectClassificationCount + 1;
    end
end
ClassificationAccuracyValue = CorrectClassificationCount/length(TestClassIDs)*100;
end
