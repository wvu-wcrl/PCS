function JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)

JobState = JobStateIn; % Update the Global JobState.

% Convert the randomly-permuted SNR points of the task back to the order in which the JobState is saved.
TaskState = DepermuteSnrPoints( TaskState, JobState );

switch JobState.sim_type
    
    case{'coded', 'uncoded'} %%% This logic needs to be refactored - Terry 9/2012.
        
        JobState.trials = JobState.trials + TaskState.trials; % Update trials.
        if ~strcmpi( JobState.sim_type, 'bloutage' )
            JobState = UpdateBERFERStats( JobState, TaskState );
            
            if ~strcmpi( JobState.sim_type, 'coded' ) % If uncoded, update symbol error rate, too.
                [JobState, TaskState] = UpdateSERStats( JobState, TaskState );
            end
        end
        
    case{'exit'}
        JobState = UpdateExitStats(JobState, TaskState, JobParam);
end
end


function TaskState = DepermuteSnrPoints ( TaskState, JobState )
TaskState.trials(:,TaskState.RandPos) = TaskState.trials;

switch JobState.sim_type
    case{'coded', 'uncoded'}
        TaskState.bit_errors(:,TaskState.RandPos) = TaskState.bit_errors;
        TaskState.frame_errors(:,TaskState.RandPos) = TaskState.frame_errors;
        
    case{'exit'}
        
        switch JobState.compute_final_exit_metrics
            case 0
                % Round 1
                TaskState.exit_state.IA_det_sum(:,TaskState.RandPos) = TaskState.exit_state.IA_det_sum;
                TaskState.exit_state.IE_det_sum(:,TaskState.RandPos) = TaskState.exit_state.IE_det_sum;
            case 1
                TaskState.exit_state.IE_vnd(:,TaskState.RandPos)  = TaskState.exit_state.IE_vnd;
                TaskState.exit_state.IA_cnd(:,TaskState.RandPos)  = TaskState.exit_state.IA_cnd;
                TaskState.exit_state.IE_cnd(:,TaskState.RandPos)  = TaskState.exit_state.IE_cnd;
                TaskState.exit_state.I_E_det(:,TaskState.RandPos) = TaskState.exit_state.I_E_det;
                TaskState.exit_state.I_A_det(:,TaskState.RandPos) = TaskState.exit_state.I_A_det;
                
                % JobState.exit_state.IA_cnd(:,TaskState.RandPos)  = JobState.exit_state.IA_cnd;
                % JobState.exit_state.IE_cnd(:,TaskState.RandPos)  = JobState.exit_state.IE_cnd;
                % JobState.exit_state.I_E_det(:,TaskState.RandPos) = JobState.exit_state.I_E_det;
                % JobState.exit_state.I_A_det(:,TaskState.RandPos) = JobState.exit_state.I_A_det;
        end
end
end


function JobState = UpdateBERFERStats( JobState, TaskState )
JobState.bit_errors   = JobState.bit_errors   + TaskState.bit_errors;
JobState.frame_errors = JobState.frame_errors + TaskState.frame_errors;

JobState.BER = JobState.bit_errors   ./ ( JobState.trials * JobState.data_bits_per_frame );
JobState.FER = JobState.frame_errors ./ JobState.trials;
end


function [JobState, TaskState] = UpdateSERStats( JobState, TaskState )
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


function JobState = UpdateExitStats(JobState, TaskState, JobParam)

switch JobParam.exit_phase
    case 'detector'
        JobState.trials = JobState.trials + TaskState.trials; % Update trials.
        JobState.exit_state.IA_det_sum = JobState.exit_state.IA_det_sum +...
            TaskState.exit_state.IA_det_sum;
        JobState.exit_state.IE_det_sum = JobState.exit_state.IE_det_sum +...
            TaskState.exit_state.IE_det_sum;
        
    case 'decoder'
        % JobState.trials = JobState.trials + TaskState.trials; % Update trials.
        %%% shorten names.
        IE_vnd_J = JobState.exit_state.IE_vnd;
        IA_cnd_J = JobState.exit_state.IA_cnd;
        IE_cnd_J = JobState.exit_state.IE_cnd;
        I_E_det_J = JobState.exit_state.I_E_det;
        I_A_det_J = JobState.exit_state.I_A_det;
        
        IE_vnd_T = TaskState.exit_state.IE_vnd;
        IA_cnd_T = TaskState.exit_state.IA_cnd;
        IE_cnd_T = TaskState.exit_state.IE_cnd;
        I_E_det_T = TaskState.exit_state.I_E_det;
        I_A_det_T = TaskState.exit_state.I_A_det;
        
        %%% combine.
        IE_vnd_J = combine_vectors( IE_vnd_J, IE_vnd_T );
        IA_cnd_J = combine_vectors( IA_cnd_J, IA_cnd_T );
        IE_cnd_J = combine_vectors( IE_cnd_J, IE_cnd_T );
        I_E_det_J = combine_vectors( I_E_det_J, I_E_det_T );
        I_A_det_J = combine_vectors( I_A_det_J, I_A_det_T );
        
        %%% assign to output structure.
        JobState.exit_state.IE_vnd = IE_vnd_J;
        JobState.exit_state.IA_cnd = IA_cnd_J;
        JobState.exit_state.IE_cnd = IE_cnd_J;
        JobState.exit_state.I_E_det = I_E_det_J;
        JobState.exit_state.I_A_det = I_A_det_J;
end
end


function vec_comb = combine_vectors(vec_1, vec_2)
vec_comb = vec_1;
vec_comb( ( vec_2 > 0 ) ) = vec_2( vec_2 > 0 );
end