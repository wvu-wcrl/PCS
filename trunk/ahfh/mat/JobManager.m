classdef JobManager
    %JOBMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        JobParam    % Job Parameter: OmegaFileName, m_i, Gamma, Beta, p, m
        JobStatus   % Job status: -1=not submitted,0=queued, 1=running, 2=done
        epsilon     % outage probability
        ahfhRoot    % root of the ahfh directory
        JobFileName % Name of the input and output files for this job
        InDir       % Directory of the input file
        OutDir      % Directory of the output file
    end
    
    methods
        % constructor
        function obj = JobManager( JobParam, JobFileName, ahfhRoot )
            obj.JobParam = JobParam;
            obj.JobFileName = JobFileName;
            obj.ahfhRoot = ahfhRoot;  
            obj.JobStatus = -1;
            
            % build directories
            obj.InDir = [ahfhRoot '/input/' ];
            obj.OutDir = [ahfhRoot '/output/'];
        end  
        
        % submit a job
        function obj = SubmitJob( obj )
            obj.JobStatus = 0;
            JobParam = obj.JobParam;
            save( [obj.InDir obj.JobFileName], 'JobParam' );
        end
        
        % check status
        function JobStatus = GetStatus( obj )
            if (obj.JobStatus < 0)
                % job hasn't been submitted yet
                JobStatus = obj.JobStatus;
                return;
            end
            
            % see if the file is in the input directory
            D = dir( [obj.InDir obj.JobFileName] );
            if ~isempty
                % job is queued
                obj.JobStatus = 0;
                JobStatus = obj.JobStatus;
                return;
            end
            
            % see if it is in the in the output directory
            D = dir( [obj.OutDir obj.JobFileName] );
            if ~isempty
                % job is done
                obj.JobStatus = 2;
                JobStatus = obj.JobStatus;
                return;
            end
            
            % job is running
            obj.JobStatus = 1;       
            JobStatus = obj.JobStatus;

        end
            
        
        % get results
        function epsilon = GetResults( obj )
            % first check status
            if (obj.Gettatus( obj ) < 2)
                fprintf( 'Job not completed yet\n' );
                epsilon = 0;
                return;
            end
            
            % now load the save file
            epsilon = load( [obj.OutDir obj.JobFileName ], 'epsilon' );
        end            
        
    end
    
end

