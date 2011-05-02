function SimManager( ProjectRoot )
% EE561 Simulation Manager.  

% properties
MaxTasks = 5; % maximimum number of tasks
SimTime = 10; % Time of each task
PauseTime = 0.25; % Time to wait between task submissions

% build directories
TaskInDir = [ProjectRoot '/TaskIn/' ];
TaskOutDir = [ProjectRoot '/TaskOut/'];
JobInDir = [ProjectRoot, '/JobIn/'];
JobRunningDir = [ProjectRoot, '/JobRunning/'];
JobOutDir = [ProjectRoot, '/JobOut/'];

TempDir = [ProjectRoot, '/temp/'];

% string used to move saved files
TempFile = [TempDir 'TempSaveSimManager.mat'];
ChmodStr = ['chmod 666 ' TempFile];
MovStr = ['mv ' TempFile ' ' JobOutDir];

% Echo out starting time
msg = sprintf( 'Sim Manager started at %s\n', datestr(clock) );
fprintf( msg );

% The task ID
TaskID = 0;

running = 1;
while( running )
    % MONITOR THE JOB INPUT QUEUE
        
    % look to see if there are any .mat files in the JobInDir
    D = dir( [JobInDir '*.mat'] );
    
    % reset the stopping criteria flag
    StoppingCriteria = 0;
    
    if ~isempty(D) 
       
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
       
        msg = sprintf( 'Lauching job %s at %s\n', InFile, datestr(clock) );
        fprintf( msg );

        % try to load it
        try
            msg = sprintf( 'Loading input file\n' );
            fprintf( msg );
            load( [JobInDir InFile], 'SimParam','SimState' );
            % Reassign as Global
            SimParamGlobal = SimParam;
            SimStateGlobal = SimState;
            success = 1;
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Input File could not be loaded\n' );
            fprintf( msg );
            success = 0;
        end
        
        % delete the input job file
        if (success)
            try
                msg = sprintf( 'Deleting input job file\n' );
                fprintf( msg );
                delete( [JobInDir InFile] );
            catch
                % fcould not delete, just a warning
                msg = sprintf( 'Warning: Input job file could not be deleted\n' );
                fprintf( msg );
            end        
        end
        
        if (success)
            % Put a copy of the Job into JobRunning directory
            % Note that SimParam and SimState are still the "Global Versions"
            msg = sprintf( 'Creating the corresponding JobsRunning file %s\n', InFile );
            fprintf( msg );
            save( [JobRunningDir InFile], 'SimParam', 'SimState' );
            
            % Initialize the Local SimParam structure
            SimParamLocal = SimParamGlobal;
            
            % Update the local SimParam to the number of errors and trials that remain
            SimParamLocal.MaxSymErrors = SimParamGlobal.MaxSymErrors - SimStateGlobal.SymbolErrors;
            SimParamLocal.MaxBitErrors = SimParamGlobal.MaxBitErrors - SimStateGlobal.BitErrors;
            SimParamLocal.MaxTrials    = SimParamGlobal.MaxTrials    - SimStateGlobal.Trials;
                       
            % divide into multiple tasks
            % Sense the load of the task input queue (TaskInDir)
            DTask = dir( [TaskInDir '*.mat'] );
            TaskLoad = length(DTask);
            
            Tasks = max(MaxTasks-TaskLoad,1);  % always run at least one task
            SimParamLocal.MaxTrials = ceil(SimParamLocal.MaxTrials/Tasks);
            
            % Make sure that the FileName matches the name of the input file
            % to facilitate getting the task results back into the correct file
            SimParamLocal.FileName =  InFile;
            
            % Update the Simulation Time
            SimParamLocal.SimTime = SimTime;
            
            % submit each tasks
            % make sure that each one has a unique name
            SimParam = SimParamLocal;
            JobFile = SimParamLocal.FileName;
            for task=1:Tasks
                % Increment the TaskID counter
                TaskID = TaskID + 1;
                
                % Create the name of the task, which includes the job name
                TaskFileName = [JobFile(1:end-4) '_task_' int2str(TaskID) '.mat'];
                
                msg = sprintf( 'Saving File %s to TaskInput queue (initial)\n', TaskFileName );
                fprintf( msg );
                
                % Save in the task input queue
                save( [TaskInDir  TaskFileName], 'SimParam' );
                
                % Pause briefly for flow control
                pause( PauseTime );
            end
        end  
        
        % Done!       
        msg = sprintf( '\nWaiting for next task or job ...\n\n' );
        fprintf( msg );
        
    end
    
    % MONITOR THE JOB RUNNING QUEUE
    
    % look to see if there are any .mat files in the TaskOutDir
    D = dir( [TaskOutDir '*.mat'] );
    
    if ~isempty(D)            
        % pick a file at random
        InFileIndex = randint( 1, 1, [1 length(D)]);
        
        % construct the filename
        InFile = D(InFileIndex).name;
        OutFile = InFile;
            
        msg = sprintf( 'Receiving task %s at %s\n', InFile, datestr(clock) );
        fprintf( msg );

        % try to load the task file
        try
            msg = sprintf( 'Loading input file\n' );
            fprintf( msg );
            load( [TaskOutDir D(InFileIndex).name], 'SimParam','SimState' );
            success = 1;
            
            % Reassing as Local
            SimStateLocal = SimState;
            SimParamLocal = SimParam;
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Input File could not be loaded\n' );
            fprintf( msg );
            success = 0;
        end
        
        % delete the task file
        if (success)
            try
                msg = sprintf( 'Deleting task file\n' );
                fprintf( msg );
                delete( [TaskOutDir InFile] );
            catch
                % fcould not delete, just a warning
                msg = sprintf( 'Warning: Task file could not be deleted\n' );
                fprintf( msg );
            end
        end        
       
        % Try to load the correspoding file from the Jobs Running Directory (if it is there)
        if (success)
            try
                msg = sprintf( 'Loading the corresponding JobsRunning file\n' );
                fprintf( msg );
                load( [JobRunningDir SimParam.FileName], 'SimParam','SimState' );
                
                % Reassign as Global
                SimStateGlobal = SimState;
                SimParamGlobal = SimParam;
                
                success = 1;
            catch
                % file was bad or nonexistent, kick out of loop
                msg = sprintf( 'Error: JobsRunning File could not be loaded\n' );
                fprintf( msg );
                success = 0;
            end
        end
        
        if (success)
            
            % Update the Global SimState
            SimStateGlobal.Trials           = SimStateGlobal.Trials       + SimStateLocal.Trials;
            SimStateGlobal.BitErrors        = SimStateGlobal.BitErrors    + SimStateLocal.BitErrors;
            SimStateGlobal.SymbolErrors     = SimStateGlobal.SymbolErrors + SimStateLocal.SymbolErrors;
            SimStateGlobal.BER              = SimStateGlobal.BitErrors    ./ ( SimStateGlobal.Trials * SimParamGlobal.CodedModObj.DataLength  );
            SimStateGlobal.SER              = SimStateGlobal.SymbolErrors ./ ( SimStateGlobal.Trials * SimParamGlobal.CodedModObj.BlockLength );
            
            % See if the global stopping criteria have been reached
            % First check to see if minimum number of trials or symbol errors has been reached
            RemainingTrials = SimParamGlobal.MaxTrials - SimStateGlobal.Trials;
            RemainingTrials(RemainingTrials<0) = 0; % force to zero if negative
            RemainingSymError = SimParamGlobal.MaxSymErrors - SimStateGlobal.SymbolErrors;
            RemainingSymError(RemainingSymError<0) = 0;  % force to zero if negative
            
            % Determine the position of active SNR points based on the number of remaining symbol errors and trials.
            ActiveSNRPoints = ( (RemainingSymError>0) & (RemainingTrials>0) );         
            StoppingCriteria = ( sum(ActiveSNRPoints) == 0 );
            if StoppingCriteria
                fprintf( 'Stopping simulation because enough trials and/or errors observed\n' );
            end
            
            if ~StoppingCriteria
                
                % Check if we can discard SNR points whose BER WILL be less than SimParam.minBER.
                LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');
                
                StoppingCriteria = ~isempty(LastInactivePoint) && ...
                    (SimStateGlobal.BER(1, LastInactivePoint) ~=0) && (SimStateGlobal.BER(1, LastInactivePoint) < SimParamGlobal.minBER) && ...
                    (SimStateGlobal.SER(1, LastInactivePoint) ~=0) && (SimStateGlobal.SER(1, LastInactivePoint) < SimParamGlobal.minSER);
                
                if StoppingCriteria
                    fprintf( 'Stopping simulation because below the mimimum BER or SER\n' );
                end
                
            end
            
            % determine and echo progress
            Remaining = sum( (ActiveSNRPoints==1).*RemainingTrials );
            Completed = sum( SimStateGlobal.Trials );
            fprintf( '  Progress update: %d trials completed, %d trials remaining, %2.4f percent complete\n', Completed, Remaining, 100*Completed/(Completed+Remaining) );
            
        end
        
        % Simulation is not done, resubmit another round of tasks
        if ~StoppingCriteria 
            % Update the Running File
            SimParam = SimParamGlobal;
            SimState = SimStateGlobal;
            msg = sprintf( 'Updating the corresponding JobsRunning file %s\n', SimParamLocal.FileName );
            fprintf( msg );
            save( [JobRunningDir SimParamLocal.FileName], 'SimParam','SimState' );            
            
            % Note, this part is repetitive.  Should make object-oriented and call a common method
            
            % Update the local SimParam to the number of errors and trials that remain
            SimParamLocal.MaxSymErrors = SimParamGlobal.MaxSymErrors - SimStateGlobal.SymbolErrors;
            SimParamLocal.MaxBitErrors = SimParamGlobal.MaxBitErrors - SimStateGlobal.BitErrors;
            SimParamLocal.MaxTrials    = SimParamGlobal.MaxTrials    - SimStateGlobal.Trials;
            
            % divide into multiple tasks
            % Sense the load of the task input queue (TaskInDir)
            DTask = dir( [TaskInDir '*.mat'] );
            TaskLoad = length(DTask);
            
            Tasks = max(MaxTasks-TaskLoad,1);  % always run at least one task
            SimParamLocal.MaxTrials = ceil(SimParamLocal.MaxTrials/Tasks);
            
            % submit each tasks
            % make sure that each one has a unique name
            SimParam = SimParamLocal;
            JobFile = SimParamLocal.FileName;
            for task=1:Tasks
                % Increment the TaskID counter
                TaskID = TaskID + 1;
                
                % Create the name of the task
                TaskFileName = [JobFile(1:end-4) '_task_' int2str(TaskID) '.mat'];
                
                msg = sprintf( 'Saving File %s to TaskInput queue (resubmit)\n', TaskFileName );
                fprintf( msg );
                
                % Save in the task input queue
                save( [TaskInDir  TaskFileName], 'SimParam' );
                
                % Pause briefly for flow control
                pause( PauseTime );
            end
            
        end
        
        % Simulation is done, save to JobsOut queue
        if StoppingCriteria
            % Set SimState and SimParam to their global values
            SimState = SimStateGlobal;
            SimParam = SimParamGlobal;
            
            % save to temporary file
            save( TempFile, 'SimState', 'SimParam' );
            JobFile = SimParamLocal.FileName;
            system( ChmodStr );
            system( [ MovStr JobFile ] );
            
            % Remove the JobRunning file
            RmStr = ['rm ' JobRunningDir JobFile ];
            system( RmStr );
            
            % More Cleanup: Any tasks associated with this job should be deleted from the input queue
            RmStr = ['rm ' TaskInDir JobFile(1:end-4) '_task_*.mat' ];
            system( RmStr );
            
        end
        
        msg = sprintf( '\nWaiting for next job or task ...\n\n' );
        fprintf( msg );
        
    end
 
    % wait before looping
    pause(4);
    
end
