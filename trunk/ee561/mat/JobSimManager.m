function status = JobSimManager( varargin )
% JobManager
%
% Manage communication theory project
%
% Including the running of the simulation
%
% Usage: status = JobSimManager( TomcatDir, MatlabDir )
% TomCatDir gives location of TomCat input/output files
% MatlabDir gives locaiton of Matlab directory structure

% default location
% my local location is:
TomcatDir = '/Users/mvalenti/Dropbox/web/webapps/CommunicationTheory/';
TomcatDir = '/usr/share/tomcat5.5/webapps/EE561/';
MatlabDir = '/home/mvalenti/svn/ee561';

% if there is an option argument, assign it to rootdir
if (nargin >= 1)
    % change the save filename
    TomcatDir = varargin{1};
    MatlabDir = varargin{2};
end

% build name of the input queue
% queue = [TomcatDir 'Jobs/inputQueue/'];
queue = [TomcatDir 'Jobs/inputQueue/']; % Temporarily rename

% build name of JobIn and JobOut (Matlab Side)
JobInDir = [MatlabDir, '/JobIn/'];
JobOutDir = [MatlabDir, '/JobOut/'];
JobRunningDir = [MatlabDir, '/JobRunning/'];

% flag to indicate still running
running = 1;

% echo out what the queue files should look like
fprintf( 'Starting\nLocation of input queue: ' );
fprintf( queue );
fprintf( '\n' );

while running   
   
    % check the queue for files
    D = dir( queue );
    
    % if there are any files, start servicing them
    % assume the first two files returned by the dir call are '.' and '..'
    for count=3:length(D)
        % construct queue filename
        queuefile = [queue D(count).name];
        
        % MatlabFileName
        MatlabFileName = [D(count).name '.mat'];
        
        % parse job and username from file
        job = sscanf( D(count).name, '%i' );
        job_str = int2str( job );
        user = sscanf( D(count).name( (length(job_str)+1):end ), '%s' );
        
        % delete the queue file
        delete( queuefile );
        
        % echo what we are doing
        fprintf( '\n\nServicing job %s for user %s at %s\n', job_str, user, datestr(clock) );
        
        % construct the input and output directory strings
        indir  = [TomcatDir 'Jobs/' user '/' job_str '/input/' ];
        outdir = [TomcatDir 'Jobs/' user '/' job_str '/output/'];
        
        fprintf( 'Input directory: %s\n', indir );
        
        % load whatever .mat file may be in the input directory
        Z = dir( [indir '*.mat'] );
        
        if (length( Z ) == 1)
            % input file name
            infile = [indir Z(1).name];

            % name of output text file
            txtfile = [outdir 'results.txt'];
            fid = fopen( txtfile, 'w+' );
            
            % try to load the input file
            fprintf( 'Loading User File:   %s\n', infile );
            try
                S = randn(6,256);
                load( infile, 'S' );
            catch
                % file was bad, kick out of loop
                fprintf( '\nWarning: File could not be loaded\n\n' );
                fprintf( fid, 'Error: (1)\nN/A\nN/A\nN/A' ); 
                fclose( fid );
                break
            end
                       
            % make sure it is numeric 
            if ~isnumeric( S )
                fprintf( '\nWarning: S matrix is not numeric\n\n' );
                break;
            end
            
            % process the input
            
            % determine size
            [K,M] = size( S );
            
            % make sure there are at least as many columns as rows
            if (K>M)
                fprintf( '\nWarning: S matrix has more rows than columns\n\n' );
                fprintf( fid, 'Error: (3)\nN/A\nN/A\nN/A' );
                fclose( fid );
                break;
            end           
           
            fprintf( 'Tring to Process signal matrix\n' );
            
            try          
                % normalize
                S = sqrt(M)*S./norm( S, 'fro' );
                
                % determine the PAPR
                PAPR = max( sum( S.^2 ) );
                
                % determine the threshold SNR's.
                GammaPs = InversePsUB( S );
                GammaPb = InversePbUB( S );
            catch
                % file was bad, kick out of loop
                fprintf( '\nWarning: Error processing S matrix \n\n' );
                fprintf( fid, 'Error: (4)\nN/A\nN/A\nN/A' ); 
                fclose( fid );
                break
            end
            
            % update the status
            status = 'Simulating';
            
            % write results to the results.txt file
            fprintf( fid, '%s\n', status );
            fprintf( fid, '%2.4f\n', PAPR );
            fprintf( fid, '%2.4f\n', GammaPs );
            fprintf( fid, '%2.4f', GammaPb );
            
            % close the txt file
            fclose( fid );
            
            % create the SimParam and SimState structures
            % Create Simulation Parameters
                        
            % create a modulation object with equally-likely symbols
            SymbolProb = ones(1,M);
            ModObj = CreateModulation( S, SymbolProb );
            
            % create channel object @ 0 dB (SNR = 1)
            ChannelObj = AWGN( ModObj, 1 );
            
            % create CM obj
            BlockLength = 1000;  % number of symbols per block
            CodedModObj = UncodedModulation( M, SymbolProb, BlockLength );
            
            % Deterine the SNR vector
            FirstSNR = InversePsUB( S, 1 );
            LastSNR = InversePsUB( S, 1e-6 );
            SNRperdB = 2;
            SNRdB = 1/SNRperdB*[ round( SNRperdB*FirstSNR):ceil( SNRperdB*LastSNR) ];
            SNRdB = [10 SNRdB];            
           
            SimParam = struct(...
                'CodedModObj', CodedModObj, ...    % Coded modulation object.
                'ChannelObj', ChannelObj, ...     % Channel object (Modulation is a property of channel).
                'SNRType', 'Es/N0 in dB', ...
                'SNR', SNRdB, ...            % Row vector of SNR points in dB.
                'MaxTrials', 100000*ones( size(SNRdB) ), ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
                'FileName', MatlabFileName, ...
                'MaxRunTime', 30, ...    % Maximum simulation time in Seconds.
                'CheckPeriod', 5, ...    % Checking time in number of Trials.
                'MaxBitErrors', 4000*ones( size(SNRdB) ), ...
                'MaxSymErrors', 1000*ones( size(SNRdB) ), ...
                'minBER', 5e-6, ...
                'minSER', 5e-6 );
            
            % Create the Link Object
            LinkObjGlobal = LinkSimulation( SimParam );
            
            % Intiialize SimState
            SimState = LinkObjGlobal.SimState;
            
            % Save
            save( [JobInDir MatlabFileName], 'SimParam', 'SimState' ); 
            
            
        else
            fprintf( '\nWarning: The following directory did not contain a .mat file: \n' );
            fprintf( indir );
            fprintf( '\n\n' );
        end     
      
      
    end
    
    % reset the check flag
    checkflag = 0;      
    
    % check to see if there are any results in the JobOut directory
    D = dir( [JobOutDir '*.mat'] );
    
    % could do the same thing for JobRunning by copying instead of moving
    
    if ~isempty(D)
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
        
        % try to parse out jobid and user from filename (STICKING POINT)
        job = sscanf( InFile, '%i' );
        job_str = int2str( job );
        user = sscanf( InFile( (length(job_str)+1):end-4 ), '%s' );
        
        % try to copy the file to the proper directory
        outdir = [TomcatDir 'Jobs/' user '/' job_str '/output/'];
        fprintf( 'Copying %s to %s\n', InFile, outdir );

        try
            fprintf( 'Loading Job File\n' );
            load( [JobOutDir InFile], 'SimParam', 'SimState' );
            
            fprintf( 'Saving Job File\n' );
            save( [outdir InFile], 'SimParam', 'SimState' );
            
            fprintf( 'Updating Results File\n' );
            S = SimParam.ChannelObj.ModulationObj.SignalSet;
            % determine the PAPR
            PAPR = max( sum( S.^2 ) );
            
            % determine the threshold SNR's.
            GammaPs = InversePsUB( S );
            GammaPb = InversePbUB( S );
            
            % update the status
            status = 'Done';
            
            % open the results file
            txtfile = [outdir 'results.txt'];
            fid = fopen( txtfile, 'w+' );
            
            % write results to the results.txt file
            fprintf( fid, '%s\n', status );
            fprintf( fid, '%2.4f\n', PAPR );
            fprintf( fid, '%2.4f\n', GammaPs );
            fprintf( fid, '%2.4f', GammaPb );  
            
            % close results file
            fclose( fid );
           
            success = 1;
        catch
            % file was bad or nonexistent, kick out of loop
            msg = sprintf( 'Error: JobsRunning File could not be loaded and/or saved\n' );
            fprintf( msg );            
           
            success = 0;
        end
        
        % delete the input job file
        if (success)
            try
                msg = sprintf( 'Deleting output job file\n' );
                fprintf( msg );
                delete( [JobOutDir InFile] );

            catch
                % fcould not delete, just a warning
                msg = sprintf( 'Warning: Could not make figure\n' );
                fprintf( msg );
            end        
        end
        
        % create and save the figure
        if (success)
            try
                h = figure(1);
                fprintf( 'Making figure\n'); 
                semilogy( SimParam.SNR, PsUB( S, 10.^(SimParam.SNR/10) ), '--b',...
                    SimParam.SNR, SimState.SER, '.b-', ...
                    SimParam.SNR, PbUB( S, 10.^(SimParam.SNR/10) ), '--r', ...
                    SimParam.SNR, SimState.BER, '.r-' );
                
                legend( 'SER: Union Bound', 'SER: Simulated', 'BER: Union Bound', 'BER: Simulated' );
                
                xlabel( 'E_s/N_0 (in dB)' );
                ylabel( 'Error Rate' );
                
                TitleTxt = sprintf( 'Error rate for Job %s', job_str );
                title( TitleTxt );
                
                axis( [min(SimParam.SNR) max(SimParam.SNR) 1e-6 1] );


                print( h, '-dpdf', [outdir 'figure.pdf'] );               
                

            catch
                % fcould not delete, just a warning
                msg = sprintf( 'Warning: Input job file could not be deleted\n' );
                fprintf( msg );
            end        
        end
        
        
    end
   
    % sleep briefly before checking again
    pause(1);
    
end