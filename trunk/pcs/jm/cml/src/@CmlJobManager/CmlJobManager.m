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
        

        function [JobParam, JobState] = PreProcessJob(obj, JobParamIn, JobStateIn, CodeRoot)
            
            OldPath = obj.SetCodePath(CodeRoot);                                                     % set the path to CML
             
            [JobParam, CodeParam] = InitializeCodeParam( JobParamIn, CodeRoot ); % initialize coding parameters
            
            JobParam.code_param_short = CodeParam;                                             % store short code param inside JobParam
                                                                                                                             % long code param will be stored in a separate file
                                                                                                                             
            JobParam.cml_rhome = obj.RenameLocalCmlHome(CodeRoot);               % rename local cml path to remote
                        
            JobState = JobStateIn;                                                                               % restore previous simulation state
            
            %%%%%%% simulation specific parameters     %%%%%%%%%%% question
            JobState.mod_order = JobParam.mod_order;
            JobState.data_bits_per_frame = CodeParam.data_bits_per_frame;
            JobState.sim_type = JobParam.sim_type;
            JobState.symbols_per_frame = CodeParam.symbols_per_frame;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch JobParam.sim_param,
                case{'exit'},
                    AllTrialsRun = sum(JobStateIn.trials < JobParamIn.max_trials) ==0,
                    if AllTrialsRun,
                        JobState.compute_final_exit_metrics = 1;
                    else
                        JobState.compute_final_exit_metrics = 0;
                    end
            end
            
            path(OldPath);
        end


         TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks)    % need to modify
            % Calculate TaskInputParam based on the number of remaining errors and trials AND the number of new tasks to be generated.
            % TaskInputParam is an either 1-by-1 or NumNewTasks-by-1 vector of structures each one of them containing one Task's InputParam structure.
            % If the InputParam is the same for all tasks, TaskInputParam can be 1-by-1.            


         JobState = UpdateJobState(obj, JobStateIn, TaskState)            

        [StopFlag, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobName, Username, JobRunningDir)
 
    end

end
