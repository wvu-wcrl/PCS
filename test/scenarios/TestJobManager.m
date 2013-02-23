% TestJobManager.m

% determine where your root directory is.
load( 'CmlHome.mat' );

% determine where to store your files.
base_name = 'TestJobManager';

data_directory = fullfile(filesep, 'output', base_name, filesep);

full_directory = fullfile( cml_home, data_directory );

if ~exist( full_directory, 'dir' )
    mkdir( full_directory);
end

% This record is used to compare the cluster performance (TotalProcessDuration) with random versus sequential SNR ordering in tasks.
record = 1;
sim_param(record).comment = 'Uncoded 64-QAM in AWGN w/ gray labeling';
sim_param(record).sim_type = 'uncoded';
sim_param(record).SNR = [0:0.25:30];
sim_param(record).SNR_type = 'Eb/N0 in dB';
sim_param(record).framesize = 1e5;
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'b-';
sim_param(record).legend = 'Uncoded 64-QAM';
sim_param(record).filename = strcat( data_directory, 'QAM64AWGN.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-8;
sim_param(record).minFER = 1e-8;
sim_param(record).max_frame_errors = 1e2*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).MaxRunTime = 5*60;