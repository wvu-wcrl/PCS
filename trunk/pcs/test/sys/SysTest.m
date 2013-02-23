% SysTest.m
%

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'SysTest';
if ispc
    data_directory = strcat( '\output\', base_name, '\' );
else
    data_directory = strcat( '/output/', base_name, '/' );
end

full_directory = strcat( cml_home, data_directory );

if ~exist( full_directory, 'dir' )
    mkdir( full_directory);
end

% Long, with 64-QAM
record = 1;
effective_rate = '4/5';
sim_param(record).comment = strcat( 'Rate=', ' ', effective_rate, ' long DVB-S2 LDPC code w/ 64QAM in AWGN' );
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 2; % LDPC
sim_param(record).SNR = [0:0.5:8.5 8.55 8.6:0.1:11];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 64800;
sim_param(record).parity_check_matrix = strcat( 'InitializeDVBS2(', effective_rate , ',', int2str( sim_param(record).framesize ), ')' );
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 0;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'm-.';
sim_param(record).legend = strcat( 'Long r=', ' ', effective_rate );
sim_param(record).max_iterations = 100;
sim_param(record).decoder_type = 0;
sim_param(record).filename = strcat( data_directory, 'DVBS2longRate4by5_64QAM.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-8;
sim_param(record).max_frame_errors = 40*ones( size(sim_param(record).SNR) );
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).save_rate = 5;
sim_param(record).MaxRunTime = 5*60;


record = 2;
sim_param(record).comment = 'Uncoded 64-QAM in AWGN w/ gray labeling';
sim_param(record).sim_type = 'uncoded';
sim_param(record).SNR = [0:0.25:30];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 1e5;
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'b:';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'QAM64AWGN.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e12*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-10;
sim_param(record).minFER = 1e-8;
sim_param(record).max_frame_errors = 100*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).MaxRunTime = 5*60;


% Long, with 128-APSK
record = 3;
effective_rate = '4/5';
sim_param(record).comment = strcat( 'Rate=', ' ', effective_rate, ' long DVB-S2 LDPC code w/ 64QAM in AWGN' );
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 2; % LDPC
sim_param(record).SNR = [0:0.5:8.5 8.55 8.6:0.1:17];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 64800;
sim_param(record).parity_check_matrix = strcat( 'InitializeDVBS2(', effective_rate , ',', int2str( sim_param(record).framesize ), ')' );
sim_param(record).modulation = 'custom';
sim_param(record).S_matrix = [
    0.8734 + 0.0286i
    -1.0860 - 0.7340i
    1.0919 - 0.0286i
    -0.1665 + 1.3002i
    0.6454 - 0.1138i
    0.6378 - 0.5974i
    0.1131 + 0.4220i
    -0.3090 + 0.3090i
    -1.0860 + 0.7340i
    0.5707 + 0.9313i
    -0.3102 + 1.0473i
    -0.1131 + 0.4220i
    -1.1944 + 0.5399i
    1.0740 + 0.1991i
    -0.8734 - 0.0286i
    -1.0621 + 0.2550i
    -0.0286 + 0.8734i
    -0.1092 + 0.1892i
    0.2242 + 0.6159i
    -0.4220 - 0.1131i
    0.4213 - 0.5021i
    0.4213 + 0.5021i
    0.5974 + 0.6378i
    -0.1092 - 0.1892i
    -0.5901 + 1.1704i
    1.0198 + 0.8235i
    -0.9002 - 0.6187i
    -0.7519 - 0.7923i
    -0.7421 - 0.4615i
    -0.7794 + 1.0539i
    -0.6378 + 0.5974i
    -0.1131 - 0.4220i
    -0.7794 - 1.0539i
    -0.2537 + 0.8362i
    0.5676 + 0.3277i
    0.1984 + 0.8510i
    0.3090 - 0.3090i
    -0.4220 + 0.1131i
    0.8660 + 0.9840i
    1.1443 + 0.6393i
    0.1426 + 1.0830i
    -0.2185 - 0.0000i
    -0.2242 + 0.6159i
    -0.8510 + 0.1984i
    -1.3060 + 0.1112i
    0
    0.1092 - 0.1892i
    0.3090 + 0.3090i
    0.8660 - 0.9840i
    0.0556 - 1.3096i
    1.0198 - 0.8235i
    0.5212 - 0.9599i
    -0.5212 + 0.9599i
    0.4615 - 0.7421i
    -0.1665 - 1.3002i
    0.0000 - 0.6554i
    0.6872 - 1.1162i
    0.5676 - 0.3277i
    -0.7707 + 0.4119i
    1.2359 - 0.4367i
    -0.5901 - 1.1704i
    0.1092 + 0.1892i
    0.4887 + 1.2163i
    -0.3838 - 1.2533i
    -0.1426 - 1.0830i
    0.9859 - 0.4703i
    0.7094 - 0.8306i
    -0.1984 - 0.8510i
    -1.0740 - 0.1991i
    -1.0919 + 0.0286i
    -1.3060 - 0.1112i
    -0.9463 - 0.9070i
    1.1443 - 0.6393i
    -0.4615 + 0.7421i
    -1.2685 - 0.3303i
    -0.8666 + 0.6650i
    -0.8362 - 0.2537i
    0.6872 + 1.1162i
    -0.9463 + 0.9070i
    -0.0857 + 1.0889i
    1.3108
    0.7519 + 0.7923i
    -0.4213 - 0.5021i
    0.0286 - 0.8734i
    0.0857 - 1.0889i
    -0.5676 + 0.3277i
    -1.2685 + 0.3303i
    -0.2242 - 0.6159i
    -0.6454 - 0.1138i
    0.4220 + 0.1131i
    -0.6454 + 0.1138i
    1.0621 - 0.2550i
    -0.4119 - 0.7707i
    0.0556 + 1.3096i
    0.8362 + 0.2537i
    0.2242 - 0.6159i
    -0.3838 + 1.2533i
    1.2919 + 0.2215i
    0.8666 - 0.6650i
    0.1131 - 0.4220i
    0.6454 + 0.1138i
    0.4119 + 0.7707i
    0.9002 + 0.6187i
    0.8510 - 0.1984i
    1.0092 + 0.4180i
    0.4887 - 1.2163i
    -0.5676 - 0.3277i
    -0.3090 - 0.3090i
    0.2537 - 0.8362i
    -0.5974 - 0.6378i
    0.7421 + 0.4615i
    -1.0092 - 0.4180i
    0.4220 - 0.1131i
    0.7707 - 0.4119i
    -1.1944 - 0.5399i
    0.2185
    0.2762 + 1.2814i
    0.2762 - 1.2814i
    -0.3646 - 1.0297i
    0.3646 + 1.0297i
    -0.0000 + 0.6554i
    0.3102 - 1.0473i
    1.2359 + 0.4367i
    -0.7094 + 0.8306i
    -0.9859 + 0.4703i
    -0.4213 + 0.5021i
    -0.5707 - 0.9313i
    1.2919 - 0.2215i
    ].';
sim_param(record).mod_order = length( sim_param(record).S_matrix );
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 0;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'm-.';
sim_param(record).legend = strcat( '128-APSK with Long r=', ' ', effective_rate, 'DVBS2 LDPC code' );
sim_param(record).max_iterations = 100;
sim_param(record).decoder_type = 0;
sim_param(record).filename = strcat( data_directory, 'DVBS2longRate4by5_128APSK.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-8;
sim_param(record).max_frame_errors = 40*ones( size(sim_param(record).SNR) );
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).save_rate = 5;
sim_param(record).MaxRunTime = 5*60;


record = 4;
sim_param(record).comment = 'Uncoded 64-QAM in AWGN w/ gray labeling';
sim_param(record).sim_type = 'uncoded';
sim_param(record).SNR = [0:0.25:17 17.05:0.05:22 22.25:0.25:30];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 1e5;
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'b:';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'QAM64AWGNAccurate.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e12*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-10;
sim_param(record).minFER = 1e-8;
sim_param(record).max_frame_errors = 100*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).MaxRunTime = 5*60;


% Terry has already generated the results of the stand-alone simulation for this record.
record = 5;
sim_param(record).comment = 'Uncoded 64-QAM in AWGN w/ gray labeling';
sim_param(record).sim_type = 'uncoded';
sim_param(record).SNR = [0:0.25:30];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 1e5;
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'b-';
sim_param(record).legend = 'Uncoded 64-QAM';
sim_param(record).filename = strcat( data_directory, 'QAM64AWGN_CL.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-10;
sim_param(record).minFER = 1e-10;
sim_param(record).max_frame_errors = 1e2*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).MaxRunTime = 5*60;


% Standalone 64-QAM uncoded
record = 6;
sim_param(record).comment = 'Uncoded 64-QAM in AWGN w/ gray labeling';
sim_param(record).sim_type = 'uncoded';
sim_param(record).SNR = [0:0.25:30];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 1e5;
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 64;
sim_param(record).mapping = 'gray';
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0;
sim_param(record).linetype = 'b-';
sim_param(record).legend = 'Uncoded 64-QAM';
sim_param(record).filename = strcat( data_directory, 'QAM64AWGN_ST.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e12*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-10;
sim_param(record).minFER = 1e-10;
sim_param(record).max_frame_errors = 2e2*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).MaxRunTime = 5*60;
