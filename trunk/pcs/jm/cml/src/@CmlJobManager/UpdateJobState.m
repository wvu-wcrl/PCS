function JobState = UpdateJobState(obj, JobStateIn, TaskState)

JobState = JobStateIn;      % Update the Global JobState.

% Convert the randomly-permuted SNR points of the task back to the order in which the JobState is saved.
TaskState = DepermuteSnrPoints( TaskState, JobState );


switch JobState.sim_type,
    
    case{'coded', 'uncoded'},   %%% this logic needs to be refactored - Terry 9/2012
        
        JobState.trials      = JobState.trials      + TaskState.trials;    % update trials
        if ~strcmpi( JobState.sim_type, 'bloutage' )
            JobState = UpdateBERFERStats( JobState, TaskState );
            
            if ~strcmpi( JobState.sim_type, 'coded' )   % If uncoded, update symbol error rate, too.
                [ JobState TaskState ] = UpdateSERStats( JobState, TaskState );
            end
        end
        
    case{'exit'},
        JobState = UpdateExitStats(JobState, TaskState);
        
end
end


function TaskState = DepermuteSnrPoints ( TaskState, JobState )
TaskState.trials(:,TaskState.RandPos) = TaskState.trials;

switch JobState.sim_type,
    case{'coded', 'uncoded'},
        TaskState.bit_errors(:,TaskState.RandPos) = TaskState.bit_errors;
        TaskState.frame_errors(:,TaskState.RandPos) = TaskState.frame_errors;
    case{'exit'},
        TaskState.exit_state.IA_det_sum(:,TaskState.RandPos) = TaskState.exit_state.IA_det_sum(:,TaskState.RandPos);
        TaskState.exit_state.IE_det_sum(:,TaskState.RandPos) = TaskState.exit_state.IE_det_sum(:,TaskState.RandPos);
end
end


function JobState = UpdateBERFERStats( JobState, TaskState )
JobState.bit_errors   = JobState.bit_errors   + TaskState.bit_errors;
JobState.frame_errors = JobState.frame_errors + TaskState.frame_errors;

JobState.BER = JobState.bit_errors   ./ ( JobState.trials * JobState.data_bits_per_frame );
JobState.FER = JobState.frame_errors ./ JobState.trials;
end


function [ JobState TaskState ] = UpdateSERStats( JobState, TaskState )
if( JobState.mod_order > 2 )
    % Update symbol error counter.
    TaskState.symbol_errors(:,TaskState.RandPos) = TaskState.symbol_errors;
    JobState.symbol_errors = JobState.symbol_errors + TaskState.symbol_errors;
    JobState.SER = JobState.symbol_errors ./ ( JobState.trials * JobState.symbols_per_frame );
else
    JobState.symbol_errors = JobState.bit_errors;
    JobState.SER = JobState.BER;
end
end


function JobState = UpdateExitStats(JobState, TaskState)
JobState.trials = JobState.trials      + TaskState.trials;    % update trials
JobState.exit_state.IA_det_sum = JobState.exit_state.IA_det_sum +...
    TaskState.exit_state.IA_det_sum;
JobState.exit_state.IE_det_sum = JobState.exit_state.IE_det_sum +...
    TaskState.exit_state.IE_det_sum;
end