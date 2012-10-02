function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
% Calculate TaskInputParam based on the number of remaining errors and trials AND the number of new tasks to be generated.
% TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.
% If the InputParam is the same for all tasks, TaskInputParam can be 1-by-1.

JobParam = FindJobParam4NewTasks( JobParam, JobState, NumNewTasks ); % Need to modify!

TaskInputParam = InitTaskInputParam( JobParam, JobState, NumNewTasks ); % Don't need to change.

TaskInputParam = RandomlyPermuteSnrPoints( TaskInputParam, JobParam, JobState );

end


function JobParam = FindJobParam4NewTasks( JobParam, JobState, NumNewTasks )
switch JobParam.sim_type
    case {'uncoded', 'coded'}
        JobParam.max_frame_errors = JobParam.max_frame_errors - JobState.frame_errors(end,:);
        JobParam.max_frame_errors(JobParam.max_frame_errors<0) = 0;
        % JobParam.MaxBitErrors = JobParam.MaxBitErrors - JobState.BitErrors(end,:);
        % JobParam.MaxBitErrors(JobParam.MaxBitErrors<0) = 0;
        JobParam.max_trials = JobParam.max_trials - JobState.trials(end,:);
        JobParam.max_trials(JobParam.max_trials<0) = 0;
        
        JobParam.max_trials = ceil(JobParam.max_trials/NumNewTasks);
        
    case {'exit'}
        switch JobState.compute_final_exit_metrics
            case 0
                JobParam.max_trials = JobParam.max_trials - JobState.trials(end,:);
                JobParam.max_trials(JobParam.max_trials<0) = 0;
                JobParam.max_trials = ceil(JobParam.max_trials/NumNewTasks);
            case 1
        end
    otherwise
end
end


function TaskInputParam = InitTaskInputParam( JobParam, JobState, NumNewTasks )
TaskInputParam(1:NumNewTasks,1) = struct('JobParam', JobParam, 'JobState', JobState); % Initialize TaskInputParam structure.
end


function TaskInputParam = RandomlyPermuteSnrPoints( TaskInputParam, JobParam, JobState )

NumNewTasks = length(TaskInputParam);

switch JobParam.sim_type
    case {'uncoded', 'coded'}
        [SNR max_trials max_frame_errors trials bit_errors frame_errors symbol_errors] = ...
            ShortenERPermutingVariableNames( JobParam, JobState );
        
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
        
    case {'exit'}
        
        [ SNR max_trials trials IA_det_sum IE_det_sum IE_vnd IE_cnd IA_cnd I_A_det I_E_det ] = ...
            ShortenExitPermutingVariableNames( JobParam, JobState );
        
        for Task=1:NumNewTasks
            
            RandPos = randperm( length(SNR) );
            TaskInputParam(Task).JobState.RandPos = RandPos;
            
            TaskInputParam(Task).JobParam.SNR = SNR( RandPos );
            
            TaskInputParam(Task).JobParam.max_trials = max_trials( RandPos );
            
            TaskInputParam(Task).JobState.trials = trials( :,RandPos );
            
            TaskInputParam(Task).JobState.exit_state.IA_det_sum = IA_det_sum( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.IE_det_sum = IE_det_sum( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.IE_vnd = IE_vnd( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.IE_cnd = IE_cnd( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.IA_cnd = IA_cnd( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.I_A_det = I_A_det( :, RandPos );
            TaskInputParam(Task).JobState.exit_state.I_E_det = I_E_det( :, RandPos );
            
        end
end
end


function [SNR max_trials max_frame_errors trials bit_errors frame_errors symbol_errors] = ...
    ShortenERPermutingVariableNames( JobParam, JobState )

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
else
    symbol_errors = 0;
    %SER = 0;
end

end


function [ SNR max_trials trials IA_det_sum IE_det_sum IE_vnd IE_cnd IA_cnd I_A_det I_E_det] = ...
    ShortenExitPermutingVariableNames( JobParam, JobState )
SNR = JobParam.SNR;
max_trials = JobParam.max_trials;
trials = JobState.trials;
IA_det_sum = JobState.exit_state.IA_det_sum;
IE_det_sum = JobState.exit_state.IE_det_sum;
IE_vnd = JobState.exit_state.IE_vnd;
IE_cnd = JobState.exit_state.IE_cnd;
IA_cnd = JobState.exit_state.IA_cnd;
I_A_det = JobState.exit_state.I_A_det;
I_E_det = JobState.exit_state.I_E_det;

end


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
%             JobState.symbols_per_frame =
%             JobParam.code_param_short.symbols_per_frame;
