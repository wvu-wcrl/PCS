% outate_worker
%
% computes the outage

function outage_worker(n,ahfhRoot)

% build directories
InDir = [ahfhRoot '/input/' ];
OutDir = [ahfhRoot '/output/'];
TableDir = [ahfhRoot, '/tables/'];
LogDir = [ahfhRoot, '/log/'];

% update path
MatDir = [ahfhRoot, '/mat'];
addpath( MatDir );

running = 1;

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
        
        % create a logfile
        LogFile = [D(InFileIndex).name(1:(end-3)) 'log'];
        fid = fopen( [LogDir LogFile], 'w+' );
        
        [tilde, host] = system( 'hostname' );
        msg = sprintf( 'Servicing job using worker %d at %s on host %s', n, datestr(clock), host );
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
            fclose( fid );
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

        
        % try to load the Omega file
        OmegaFile = JobParam.OmegaFileName;
        try
            msg = sprintf( 'Loading Omega file\n' );
            fprintf( msg );
            fprintf( fid, msg );
            load( [TableDir OmegaFile], 'Omega' );           
        catch
            % file was bad, kick out of loop
            msg = sprintf( 'Error: Omega File could not be loaded\n' );
            fprintf( msg );
            fprintf( fid, msg );
            fclose( fid );
            break
        end
        
        [N,M] = size( Omega );
        
        % check to see if there is a saved version of the object
        ObjFile = ['Obj_' int2str(JobParam.m) '_' int2str(M) '.mat'];
        
        D = dir( [TableDir ObjFile ] );
        if ~isempty(D)
            % file is there, try to load it
            try
                msg = sprintf( 'Loading existing Object file\n' );
                fprintf( msg );
                fprintf( fid, msg );
                load( [TableDir ObjFile], 'b' );
            catch
                % file was bad, kick out of loop
                msg = sprintf( 'Error: Object File could not be loaded\n' );
                fprintf( msg );
                fprintf( fid, msg );
                fclose( fid );
                break
            end        
        
            % update the Omega and the normalized Omega
            b.Omega_i = Omega;           
            if (length( JobParam.m_i ) == 1)
                b.Omega_i_norm = Omega./repmat( JobParam.m_i, N, M);
            else
                b.Omega_i_norm = Omega./repmat( JobParam.m_i, N, 1);
            end
        else            
            fprintf( fid, 'Creating oject\n' );
            % if not, then create an OutageProbability object
            b = OutageNakagami(Omega,JobParam.m,JobParam.m_i );            
            msg = sprintf( 'Done creating object. Saving to file.\n' );
            fprintf( msg );
            fprintf( fid, msg );
                
            % save the OutageProbability object
            save( [TableDir ObjFile], 'b' )
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
            fclose( fid );
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
            fclose( fid );
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
    pause(1);
    
end
    