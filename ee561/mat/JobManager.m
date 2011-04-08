function status = JobManager( varargin )
% JobManager
%
% Manage communication theory project
%
% Usage: status = ProjectMonitor( [rootdir] )
% [rootdir] is location of the project files

% default location
% my local location is /Users/mvalenti/Dropbox/web/webapps/CommunicationTheory/
rootdir = '/usr/share/tomcat5.5/webapps/CommunicationTheory/';

% if there is an option argument, assign it to rootdir
if (nargin >= 1)
    % change the save filename
    rootdir = varargin{1};
end

% build name of the input queue
queue = [rootdir 'Jobs/inputQueue/'];

% flag to indicate still running
running = 1;

% echo out what the queue files should look like
fprintf( 'Starting\nLocation of input queue: ' );
fprintf( queue );
fprintf( '\n' );

% column_width = 80;
% heartbeat_counter = column_width;

while running
    
    % fprintf( '.' );
    % heartbeat_counter = heartbeat_counter - 1;
    % if ~heartbeat_counter
    %     heartbeat_counter = column_width;
    %     fprintf('\n');
    % end
        
    
    % check the queue for files
    D = dir( queue );
    
    % if there are any files, start servicing them
    % assume the first two files returned by the dir call are '.' and '..'
    for count=3:length(D)
        % construct queue filename
        queuefile = [queue D(count).name];
        
        % parse job and group name from file
        job = sscanf( D(count).name, '%i' );
        job_str = int2str( job );
        user = sscanf( D(count).name( (length(job_str)+1):end ), '%s' );
        
        % delete the queue file
        delete( queuefile );
        
        % echo what we are doing
        fprintf( '\n\nServicing job %s for user %s at %s\n', job_str, user, datestr(clock) );
        
        % construct the input and output directory strings
        indir  = [rootdir 'Jobs/' user '/' job_str '/input/' ];
        outdir = [rootdir 'Jobs/' user '/' job_str '/output/'];
        
        fprintf( 'Input directory: %s\n', indir );
        
        % load whatever .mat file may be in the input directory
        Z = dir( [indir '*.mat'] );
        
        if (length( Z ) == 1)
            % input file name
            infile = [indir Z(1).name];
            
            % output file name
            outfile = [outdir 'Result' job '.mat' ];

            % name of output text file
            txtfile = [outdir 'results.txt'];
            fid = fopen( txtfile, 'w+' );
            
            % try to load the input file
            fprintf( 'Loading User File:   %s\n', infile );
            try
                user_data = load( infile );
            catch
                % file was bad, kick out of loop
                fprintf( '\nWarning: File could not be loaded\n\n' );
                break
            end
            
            % see if there is an S matrix in the file
            if isfield( user_data, 'S' )
                S = user_data.S;
            else
                fprintf( '\nWarning: File does not contain an S matrix\n\n' );
                break;
            end
            
            % make sure it is numeric 
            if ~isnumeric( S )
                fprintf( '\nWarning: S matrix is not numeric\n\n' );
                break;
            end
            
            % process the input, but ...
            % at this point, could have problems if not a valid S matrix
            
            % determine size
            [K,M] = size( S );
            
            % make sure there are at least as many columns as rows
            if (K>M)
                fprintf( '\nWarning: S matrix has more rows than columns\n\n' );
                break;
            end           
           
            fprintf( 'Processing user file\n' );
            
            % normalize
            S = sqrt(M)*S./norm( S, 'fro' );
            
            % determine the PAPR
            PAPR = max( sum( S.^2 ) );
            
            % determine the threshold SNR's.
            GammaPs = InversePsUB( S );
            GammaPb = InversePbUB( S );
            
            % update the status
            status = 'In Progress';
            
            % write results to the results.txt file
            fprintf( fid, '%s\n', status );
            fprintf( fid, '%2.4f\n', PAPR );
            fprintf( fid, '%2.4f\n', GammaPs );
            fprintf( fid, '%2.4f', GammaPb );
            
            % close the txt file
            fclose( fid );
            
        else
            fprintf( '\nWarning: The following directory did not contain a .mat file: \n' );
            fprintf( indir );
            fprintf( '\n\n' );
        end     
      
      
    end
    
    % sleep briefly before checking again
    pause(1);
    
end

