% outate_worker
%
% computes the outage

function outage_worker(n,ahfhRoot)
% Outage Worker.  Loads a Job and runs it.
%
% The JobFile contains a JobParam structure containing the following
% elements:
%   Gamma  % SNR values
%   Beta   % Threholds 
%   p      % Collision probabilities
%   NetworkFileName  % Name of file in the TableDir containing network
%   description (in the form of an OutageNakagami object called "b")
%

% build directories
InDir = [ahfhRoot '/input/' ];
OutDir = [ahfhRoot '/output/'];
TableDir = [ahfhRoot, '/tables/'];
LogDir = [ahfhRoot, '/log/'];

% update path
MatDir = [ahfhRoot, '/mat'];
addpath( MatDir );

running = 1;

% create a logfile for this worker
LogFile = ['Worker' int2str(n) '.log'];
fid = fopen( [LogDir LogFile], 'a+' );

[tilde, host] = system( 'hostname' );
msg = sprintf( 'Worker %d started at %s on host %s\nRoot dir is %s\n', int2str(n), datestr(clock), host, ahfhRoot );

fprintf( msg );
fprintf( fid, msg );

while( running )
    % look to see if there are any .mat files in the InDir
    D = dir( [InDir '*.mat'] );
    
    if ~isempty(D) 
        % start a timer
        t1 = tic;
        
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
        OutFile = InFile;
       
        msg = sprintf( 'Servicing job %s using worker %d at %s on host %s', InFile, n, datestr(clock), host );
        fprintf( msg );
        fprintf( fid, msg );

        % try to load it
        try
            msg = sprintf( 'Loading input file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            load( [InDir D(InFileIndex).name], 'JobParam' );
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Input File could not be loaded\n' );
            fprintf( msg );
            fprintf( fid, msg );
            break
        end
        
        % delete input file
        try
            msg = sprintf( 'Deleting input file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            delete( [InDir InFile] );
        catch
            % fcould not delete, just a warning
            msg = sprintf( 'Warning: Input file could not be deleted\n' );
            fprintf( msg );
            fprintf( fid, msg );
        end        

        
        % try to load the Network Description file
        NetworkFile = JobParam.NetworkFileName;
        try
            msg = sprintf( 'Loading Network file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            load( [TableDir NetworkFile], 'b' );           
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Network File could not be loaded\n' );
            fprintf( msg );
            fprintf( fid, msg );
            break
        end
            
        % try to compute the outage probability
        try
            msg = sprintf( 'Computing outage probabilty\n' );
            fprintf( msg );
            fprintf( fid, msg );
            
            epsilon = b.ComputeOutage( JobParam.Gamma, JobParam.Beta, JobParam.p );                      
        catch
            % file was bad, kick out of loop
            msg = sprintf( '\nError: Could not compute outage probability\n\n' );
            fprintf( msg );
            fprintf( fid, msg );
            break
        end

        msg = sprintf( 'Done computing outage probabilty\n' );
        fprintf( msg );
        fprintf( fid, msg );
        
        % update status
        JobStatus = 2;
        
        % try to save it
        try
            msg = sprintf( 'Saving output file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            save( [OutDir OutFile], 'JobParam', 'JobStatus', 'epsilon' );
            % save( [OutDir OutFile] );
        catch
            % file cound not save, kick out of loop
            msg = sprintf( 'Error: Output File could not be saved\n' );
            fprintf( msg );
            fprintf( fid, msg );
            break
        end
        
        % Done!
        msg = sprintf( 'Completed job at %s for a runtime of %f seconds\n', datestr(clock), toc(t1) );
        fprintf( msg );
        fprintf( fid, msg );
        
        msg = sprintf( '\nWaiting for next job...\n\n' );
        fprintf( msg );
        fprintf( fid, msg );
    end
        
    
    % wait before looping
    pause(4);
    
end
    