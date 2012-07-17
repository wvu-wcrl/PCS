function [sim_param_changeable, sim_param_unchangeable, sim_state_prototype] = DefineStructures
% DefineStructures specifies the prototype structures.
%
% The calling syntax is:
%     [sim_param_changeable, sim_param_unchangeable, sim_state_prototype] = DefineStructures
%
%     sim_param_changeable = Prototype structure containing simulation parametes that can be changed
%     sim_param_unchangeable = Prototype structure containing simulation parametes that cannot be changed
%     sim_state_prototype = Prototype of structure containing simulation results
%
%     Note: See readme.pdf for a description of the structure formats.
%
% Copyright (C) 2006-2008, Matthew C. Valenti
%
% Last updated on May 22, 2008
%
% Function DefineStructures is part of the Iterative Solutions Coded Modulation
% Library (ISCML).  
%
% The Iterative Solutions Coded Modulation Library is free software;
% you can redistribute it and/or modify it under the terms of 
% the GNU Lesser General Public License as published by the 
% Free Software Foundation; either version 2.1 of the License, 
% or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
% USA

% unchangeable paramaters and their default values
sim_param_unchangeable = struct(...
    'sim_type', [], ...
    'SNR_type', 'Eb/No in dB', ...
    'framesize', [], ...
    'bicm', 1, ...
    'modulation', 'BPSK', ...
    'mod_order', 2, ...
    'mapping', 'gray', ...
    'h', [], ...
    'demod_type', [], ...
    'code_configuration', [], ...
    'g1', [], ...
    'nsc_flag1', [], ...
    'pun_pattern1', [], ...
    'tail_pattern1', [], ...
    'g2', [], ...
    'nsc_flag2', [], ...
    'pun_pattern2', [], ...
    'tail_pattern2', [], ...
    'decoder_type', [], ...
    'max_iterations', 1, ...
    'code_interleaver', [], ...
    'parity_check_matrix', [], ...
    'channel', 'AWGN', ...
    'blocks_per_frame', [], ...
    'N_IR', [], ...
    'X_set', [], ...
    'P', [], ...
    'combining_type', [], ...
    'rate', [], ...
    'csi_flag', [], ...
    'bwconstraint', [], ...
    'bwdatabase', [], ...
    'code_bits_per_frame', [], ...
    'S_matrix', [], ...
    'k_per_row', [], ... 
    'k_per_column', [], ...
    'B', [], ...
    'Q', [], ...
    'depth', 6 );

sim_param_changeable = struct( ...
    'SNR', [], ...
    'filename', [], ...
    'comment', [], ...
    'legend', [], ...
    'linetype', 'k', ...
    'plot_iterations', [], ...
    'save_rate', 100, ...
    'reset', 0, ...
    'max_trials', [], ...
    'minBER', 1e-8, ...
    'minFER', 1e-8, ...
    'max_frame_errors', [], ...
    'compiled_mode', 0, ...
    'input_filename', [], ...
    'trial_size', 1, ...
    'scenarios', [], ...
    'SimLocation', 'local');

sim_state_prototype = struct( ...
    'trials', [], ...
    'capacity_sum', [], ...
    'capacity_avg', [], ...
    'frame_errors', [], ...
    'symbol_errors', [], ...
    'bit_errors', [], ...
    'FER', [], ...
    'SER', [], ...
    'BER', [], ...
    'throughput', [], ...
    'min_rate', [], ...
    'best_rate', [], ...
    'min_EsNodB', [], ...
    'min_EbNodB', [] );










