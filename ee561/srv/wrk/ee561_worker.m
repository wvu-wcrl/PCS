function ee561_worker( WorkerID, ProjectRoot)
% EE561 Worker.  Loads a Job, runs it, and saves result.

% Inputs: WorkerID = worker number (as an integer)
%         ProjectRoot = location of the root for this project
%
% The input file is located in the TaskIn directory
%
% The JobFile contains SimParam structure (SimState is ignored)
%
% After loading the object from file, creates a LinkSimulation object,
% and executes the SingleSimulate method.
%
% Saves the SimParam and SimState result to the TaskOut directory


% build directories
InDir = [ProjectRoot '/TaskIn/' ];
OutDir = [ProjectRoot '/TaskOut/'];
LogDir = [ProjectRoot, '/log/'];
TempDir = [ProjectRoot, '/temp/'];

% string used to move saved files
TempFile = [TempDir 'TempSave' int2str(WorkerID) '.mat'];
ChmodStr = ['chmod 666 ' TempFile];
MovStr = ['mv ' TempFile ' ' OutDir];

% update path
MatDir = [ProjectRoot, '/mat'];
addpath( MatDir );

% Mex dir
MexDir = [ProjectRoot, '/mex/', lower(computer)];
addpath( MexDir );

running = 1;

% create a logfile for this worker
LogFile = ['Worker' int2str(WorkerID) '.log'];
fid = fopen( [LogDir LogFile], 'a+' );

[tilde, HostName] = system( 'hostname' );
StartTime = datestr(clock);

% Information about this Worker
WorkerInfo.WorkerID = WorkerID;
WorkerInfo.HostName = HostName;

msg = sprintf( 'Worker %d started at %s on host %s\nRoot dir is %s\n', WorkerID,  StartTime, HostName, ProjectRoot );

fprintf( msg );
fprintf( fid, msg );

while( running )
    % look to see if there are any .mat files in the InDir
    D = dir( [InDir '*.mat'] );
    
    if ~isempty(D) 
        % start a timer
        t1 = tic;
        StartTime = datestr(clock);
        
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
        OutFile = InFile;
       
        msg = sprintf( 'Servicing job %s using worker %d at %s on host %s', InFile, WorkerID, StartTime, HostName );
        fprintf( msg );
        fprintf( fid, msg );

        % try to load it
        try
            msg = sprintf( 'Loading input file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            load( [InDir D(InFileIndex).name], 'SimParam' );
            success = 1;
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Input File could not be loaded\n' );
            fprintf( msg );
            fprintf( fid, msg );
            success = 0;
        end
        
        % delete input file
        if (success)
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
        end

        % Construct the Link Simulation object
        if (success)
            try
                msg = sprintf( 'Constructing the Link Simulation object\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % Construct the object
                LinkObjLocal = LinkSimulation( SimParam );

                msg = sprintf( 'Done constructing the object\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 1;
            catch
                % file was bad, kick out of loop
                msg = sprintf( '\nError: Could not construct the Link Simulation object\n\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end
        
        % try to run one work unit
        if (success)
            try
                msg = sprintf( 'Processing one work unit\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % Run the simulation
                LinkObjLocal.SingleSimulate();               

                msg = sprintf( 'Done with work unit\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 1;
            catch
                % file was bad, kick out of loop
                msg = sprintf( '\nError: Could not complete the work unit\n\n' );
                fprintf( msg );
                fprintf( fid, msg );
                success = 0;
            end
        end

        
        % try to save it
        if (success)
            try
                msg = sprintf( 'Saving output file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % We are bypassing the Save method, because each worker needs
                % its own independent temporary file, and also we want to save
                % how much work this worker has expended (to credit the "donor")
                               
                % Update SimState 
                SimState = LinkObjLocal.SimState;
                
                % Update the Worker information
                WorkerInfo.StartTime = StartTime;
                WorkerInfo.StopTime = datestr(clock);
                WorkerInfo.RunTime = toc(t1);
                
                % save to temporary file
                save( TempFile, 'SimState', 'SimParam', 'WorkerInfo' );
                system( ChmodStr );
                system( [MovStr OutFile] );
                               
                % Done!
                msg = sprintf( 'Completed job at %s for a runtime of %f seconds\n', WorkerInfo.StopTime, WorkerInfo.RunTime );
                fprintf( msg );
                fprintf( fid, msg );
                
                % success = 1;
            catch
                % file cound not save, kick out of loop
                msg = sprintf( 'Error: Output File could not be saved\n' );
                fprintf( msg );
                fprintf( fid, msg );
                
                % success = 0;
            end
        end
        
        
        msg = sprintf( '\nWaiting for next job...\n\n' );
        fprintf( msg );
        fprintf( fid, msg );
    end
        
    
    % wait before looping
    pause(4);
    
end
    