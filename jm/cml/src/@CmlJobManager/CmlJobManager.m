classdef CmlJobManager < JobManager
    
    methods( Static, Access = protected )
        function CmlRHome = RenameLocalCmlHome( CmlHome )
            CmlRHome = CmlHome;
            if ~ispc
                [Dummy EndPath] = strtok(CmlHome, filesep);
                CmlRHome = fullfile(filesep,'rhome',EndPath);
            end
        end
        
        
        function CodeParam = RmHmat(CodeParam)
        % Remove parity check matrix from CodeParam for efficiency.
            
            if isfield(CodeParam, 'H_rows')
                CodeParam = rmfield(CodeParam, 'H_rows');
            end
            if isfield(CodeParam, 'H_cols')
                CodeParam = rmfield(CodeParam, 'H_cols');
            end
        end
        
    end
    
    
    methods
	    function obj = CmlJobManager( cfgRoot, queueCfg )
            % Distributed CML Simulation Job Manager.
            % Calling syntax: obj = CmlJobManager([cfgRoot, varargin])
            % Optional input cfgRoot is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'cml';
            % CFG_Filename = 'CmlJobManager_cfg';
      
            % input argument 'queueCfg' stores the full path to the queue configuration file
          
            % Both input arguments must be defined.
            % If no specific job manager configuration file is desired,
            %  the argument must be specified as '[]'

        
%        if( nargin<2 || isempty(cfgRoot) ), cfgRoot = []; end
     obj@JobManager(cfgRoot, queueCfg, 'cml');
       end
        
        
        function [JobParam, JobState, PPSuccessFlag, PPErrorMsg] =...
                PreProcessJob(obj, JobParamIn, JobStateIn, CurrentUser, JobName)
            
            CodeRoot = CurrentUser.CodeRoot;
            OldPath = obj.SetCodePath(CodeRoot); % Set the path to CML.
            
            [JobParam PPSuccessFlag PPErrorMsg] =...
                obj.ProcessDataFiles( JobParamIn, CurrentUser, JobName );
            
            % return if failure in data file processing
            if PPSuccessFlag == 0,
                JobState = JobStateIn;
                return;
            end
            
            
            
            [JobParam, CodeParam] = InitializeCodeParam( JobParam, CodeRoot ); % Initialize coding parameters.
            % Parity check matrix is stored as a data file for efficiency.
            % Clear it in CodeParam.
            CodeParam = obj.RmHmat(CodeParam);
            
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
        
        
        function [RemainingTrials RemainingFrameErrors RemainingMI] =  UpdateRemainingMetrics( obj, JobParam, JobState )
            
            switch JobParam.sim_type
                case {'uncoded', 'coded'}
                    % First check to see if minimum number of trials or frame errors has been reached.
                    RemainingTrials = JobParam.max_trials - JobState.trials(end,:);
                    RemainingTrials(RemainingTrials<0) = 0;           % Force to zero if negative.
                    RemainingFrameErrors = JobParam.max_frame_errors - JobState.frame_errors(end,:);
                    RemainingFrameErrors(RemainingFrameErrors<0) = 0; % Force to zero if negative.
                    
                    RemainingMI = 0;
                    
                case {'exit'}
                    % Check to see if exit_state vectors are full.
                    % If full, 1; if not, 0.
                    switch JobParam.exit_param.exit_phase,
                        case 'detector'
                            RemainingTrials = JobParam.max_trials - JobState.trials;
                            RemainingTrials(RemainingTrials<0) = 0;
                            RemainingFrameErrors = 0; %%%% refactor - replace output args with varargout!
                            RemainingMI = 0;
                        case 'decoder'
                            RemainingMI = (sum( JobState.exit_state.IA_cnd ) == 0);
                            RemainingFrameErrors = 0;
                            RemainingTrials = 0;
                    end
            end
        end
        
        
        function ActiveSNRPoints = FindActiveSnrPoints( obj, RemainingTrials, RemainingFrameErrors, RemainingMI, SimType, ExitParam )
            
            switch SimType
                case {'uncoded', 'coded'}
                    ActiveSNRPoints  = ( (RemainingTrials>0) & (RemainingFrameErrors>0) );
                case{'exit'}
                    switch ExitParam.exit_phase,
                        case 'detector'
                            ActiveSNRPoints  = ( RemainingTrials > 0);
                        case 'decoder'
                            ActiveSNRPoints = RemainingMI;
                    end
            end
        end
        
        
        TaskInputParam = CalcTaskInputParam(obj, JobParam, JobState, NumNewTasks) % Need to modify.
        
        JobState = UpdateJobState(obj, JobStateIn, TaskState, JobParam)
        
        [StopFlag, JobInfo, varargout] = DetermineStopFlag(obj, JobParam, JobState, JobInfo, JobName, Username, FiguresDir)
        
        [JobParam PPSuccessFlag PPErrorMsg] = ProcessDataFiles( obj, JobParam, CurrentUser, JobName )
        
        PlotResults( obj, JobParam, JobState, FiguresDir, JobName, TempJMDir )
        
    end
    
end
