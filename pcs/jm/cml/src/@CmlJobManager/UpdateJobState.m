function JobState = UpdateJobState(obj, JobStateIn, TaskState)

JobState = JobStateIn;      % Update the Global JobState.

% Convert the randomly-permuted SNR points of the task back to the order in which the JobState is saved.
TaskState = DepermuteSnrPoints( TaskState );

JobState.trials      = JobState.trials      + TaskState.trials;    % update trials
if ~strcmpi( JobState.sim_type, 'bloutage' )
    JobState = UpdateOutageStats( JobState, TaskState );
    
    if ~strcmpi( JobState.sim_type, 'coded' )   % If uncoded, update symbol error rate, too.
        [ JobState TaskState ] = UpdateBERStats( JobState, TaskState );
    end
end
end


function TaskState = DepermuteSnrPoints ( TaskState )
TaskState.trials(:,TaskState.RandPos) = TaskState.trials;
TaskState.bit_errors(:,TaskState.RandPos) = TaskState.bit_errors;
TaskState.frame_errors(:,TaskState.RandPos) = TaskState.frame_errors;
end


function JobState = UpdateOutageStats( JobState, TaskState )
JobState.bit_errors   = JobState.bit_errors   + TaskState.bit_errors;
JobState.frame_errors = JobState.frame_errors + TaskState.frame_errors;

JobState.BER = JobState.bit_errors   ./ ( JobState.trials * JobState.data_bits_per_frame );
JobState.FER = JobState.frame_errors ./ JobState.trials;
end


function [ JobState TaskState ] = UpdateBERStats( JobState, TaskState )
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