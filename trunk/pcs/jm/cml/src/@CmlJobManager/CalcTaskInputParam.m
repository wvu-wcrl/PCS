function TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)
% Calculate TaskInputParam based on the number of remaining errors and trials AND the number of new tasks to be generated.
% TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.
% If the InputParam is the same for all tasks, TaskInputParam can be 1-by-1.

JobParam = FindJobParam4NewTasks( JobParam, JobState, NumNewTasks ); % Need to modify!

%%% Added on 02/20/2013 to fix the issue of double counting of trials and errors.
% First clear the content of JobState (that is considered as the sim_state for each task).
JobState = ResetJobState(JobState, JobParam);

TaskInputParam = InitTaskInputParam( JobParam, JobState, NumNewTasks ); % Don't need to change.

TaskInputParam = RandomlyPermuteSnrPoints( obj, TaskInputParam, JobParam, JobState );

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
        switch JobParam.exit_param.exit_phase
            case 'detector',
                JobParam.max_trials = JobParam.max_trials - JobState.trials(end,:);
                JobParam.max_trials(JobParam.max_trials<0) = 0;
                JobParam.max_trials = ceil(JobParam.max_trials/NumNewTasks);
            case 'decoder'
        end
    otherwise
end
end


function TaskInputParam = InitTaskInputParam( JobParam, JobState, NumNewTasks )
TaskInputParam(1:NumNewTasks,1) = struct('JobParam', JobParam, 'JobState', JobState); % Initialize TaskInputParam structure.
end


function JobState = ResetJobState(JobState, JobParam)

%%% Added on 02/20/2013 to fix the issue of double counting of trials and errors.
% First clear the content of JobState (that is considered as the sim_state for each task).
if isfield(JobParam, 'SNR')
    NumSnrPoints = length(JobParam.SNR);
end

switch JobParam.sim_type
    
    case {'uncoded','coded'}
        JobState.timing_data.trial_samples = 0;
        JobState.timing_data.time_samples = 0;
        JobState.timing_data.elapsed_time = 0;
        
        JobState.trials = zeros( JobParam.max_iterations, NumSnrPoints );
        
        switch JobParam.sim_type
            case 'uncoded'
                JobState.frame_errors = zeros( 1, NumSnrPoints );
                JobState.symbol_errors = zeros( 1, NumSnrPoints );
                JobState.bit_errors = zeros( 1, NumSnrPoints );
                JobState.BER = JobState.trials;
                JobState.SER = JobState.trials;
                JobState.FER = JobState.trials;
            case 'coded'
                JobState.frame_errors = zeros( JobParam.max_iterations, NumSnrPoints );
                JobState.bit_errors = JobState.frame_errors;
                JobState.BER = JobState.trials;
                JobState.FER = JobState.trials;
        end
        
    case 'capacity'
        JobState.trials = zeros( JobParam.max_iterations, NumSnrPoints );
        JobState.capacity_sum = zeros( 1, NumSnrPoints );
        JobState.capacity_avg = JobState.trials;
        
    case 'exit'
        N = length(JobParam.exit_param.requested_IA);
        JobState.trials = zeros( 1, NumSnrPoints );
        JobState.exit_state.IA_det_sum = zeros( N, NumSnrPoints );
        JobState.exit_state.IE_det_sum = zeros( N, NumSnrPoints );
        JobState.exit_state.I_A_det = zeros( N, NumSnrPoints );
        JobState.exit_state.I_E_det = zeros( N, NumSnrPoints );
        JobState.exit_state.IE_vnd = zeros( N, NumSnrPoints );
        JobState.exit_state.IE_cnd = zeros( N, NumSnrPoints );
        JobState.exit_state.IA_cnd = zeros( N, NumSnrPoints );
        
    case 'bloutage'
        JobState.trials = zeros( JobParam.max_iterations, NumSnrPoints );
        JobState.frame_errors = JobState.trials;
        JobState.FER = JobState.trials;
        
    case 'outage' % Outage probability in block fading.
        JobState.trials = zeros( 1, NumSnrPoints );
        JobState.frame_errors = JobState.trials;
        JobState.FER = JobState.trials;
        
    case 'throughput'
        JobState.throughput = zeros(1,NumSnrPoints);
    otherwise
end

end


function TaskInputParam = RandomlyPermuteSnrPoints( obj, TaskInputParam, JobParam, JobState )

NumNewTasks = length(TaskInputParam);

% Find out the SNR points at which more trials are needed.
% We have to permute only those SNR points and move the rest of the finished SNR points to the end of the SNR vector.
%%% Modified on 21/02/2013 to put active SNR points at the beginning so that workers do actually work on tasks(Mohammad Fanaei).
[RemainingTrials RemainingFrameErrors RemainingMI] =  obj.UpdateRemainingMetrics( JobParam, JobState );

ActiveSNRPoints = obj.FindActiveSnrPoints( RemainingTrials, RemainingFrameErrors, RemainingMI, JobParam.sim_type, JobParam.exit_param );

IndexActiveSNRPoints = find(ActiveSNRPoints > 0);
IndexInactiveSNRPoints = find(ActiveSNRPoints <= 0);

switch JobParam.sim_type
    case {'uncoded', 'coded'}
        [SNR max_trials max_frame_errors trials bit_errors frame_errors symbol_errors] = ...
            ShortenERPermutingVariableNames( JobParam, JobState );
        
        for Task=1:NumNewTasks
            
            RandPermuteIndexActiveSNR = randperm( length(IndexActiveSNRPoints) );
            PermutedIndexActiveSNRPoints = IndexActiveSNRPoints(RandPermuteIndexActiveSNR);
            RandPos = [PermutedIndexActiveSNRPoints IndexInactiveSNRPoints];
            
            % RandPos = randperm( length(SNR) );
            
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
            
            RandPermuteIndexActiveSNR = randperm( length(IndexActiveSNRPoints) );
            PermutedIndexActiveSNRPoints = IndexActiveSNRPoints(RandPermuteIndexActiveSNR);
            RandPos = [PermutedIndexActiveSNRPoints IndexInactiveSNRPoints];
            
            %RandPos = randperm( length(SNR) );
            
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