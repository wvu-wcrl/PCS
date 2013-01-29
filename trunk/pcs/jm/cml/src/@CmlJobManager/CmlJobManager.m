classdef CmlJobManager < JobManager
    
    methods( Static, Access = protected )
        function CmlRHome = RenameLocalCmlHome( CmlHome )
            CmlRHome = CmlHome;
            if ~ispc
                [Dummy EndPath] = strtok(CmlHome, filesep);
                CmlRHome = fullfile(filesep,'rhome',EndPath);
            end
        end
    end
    
    methods
        function obj = CmlJobManager( cfgRoot )
            % Distributed CML Simulation Job Manager.
            % Calling syntax: obj = CmlJobManager([cfgRoot])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'cml';
            % CFG_Filename = 'CmlJobManager_cfg';
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            obj@JobManager(cfgRoot);
        end
        
        
        
        %%% Terry: add CurrentUser as input argument to PreProcessJob
        % add logic to SetPaths to return JobDataDir
        function [JobParam, JobState] = PreProcessJob(obj, JobParamIn, JobStateIn, CurrentUser, ...
                JobName)            
            
            CodeRoot = CurrentUser.CodeRoot;
            
            [ JobParamIn ] = ProcessDataFiles( obj, JobParamIn, CurrentUser, JobName );
                        
            OldPath = obj.SetCodePath(CodeRoot); % Set the path to CML.
            
            [JobParam, CodeParam] = InitializeCodeParam( JobParamIn, CodeRoot ); % Initialize coding parameters.
            JobParam.code_param_short = CodeParam; % Store short code param inside JobParam.
                        
            JobParam.cml_rhome = obj.RenameLocalCmlHome(CodeRoot); % Rename local cml path to remote.
            
            JobState = JobStateIn; % Restore previous simulation state.
            
            %%%%%%% Simulation Specific Parameters %%%%%%%%%%% question!
            JobState.mod_order = JobParam.mod_order;
            JobState.data_bits_per_frame = CodeParam.data_bits_per_frame;
            JobState.sim_type = JobParam.sim_type;
            JobState.symbols_per_frame = CodeParam.symbols_per_frame;
            
            %%% Selecting ldpc exit phases.
            % switch JobParam.sim_type
            %    case{'exit'}
            %        AllTrialsRun = sum(JobState.trials < JobParamIn.max_trials) == 0;
            %        if AllTrialsRun
            %            JobState.compute_final_exit_metrics = 1;
            %        else
            %            JobState.compute_final_exit_metrics = 0;
            %        end
            % end
            
            path(OldPath);
        end
        
        
        function NumProcessUnit = FindNumProcessUnits(obj, TaskState)
            NumProcessUnit = sum(TaskState.trials(end,:));
        end
        
        
        TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks) % Need to modify.
        
        
        JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
        
        
        [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, JobRunningDir)
        
    end
    
end