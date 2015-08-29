classdef IrisCloudJobManager < JobManager
    
    
    methods(Static)
        function OldPath = SetCodePath(CodeRoot)
            % Determine the home directory.
            OldPath = path;
            
            addpath( fullfile(CodeRoot, 'Algorithms') );
            addpath( fullfile(CodeRoot, 'mat') );
            % This is the location of the mex directory for this architecture.
            % addpath( fullfile( CodeRoot, 'mex', lower(computer) ) );
        end
    end
    
    
    methods
        function obj = IrisCloudJobManager( cfgRoot, queueCfg )
% This is the job manager for the Iris CLoud project.
            % Calling syntax: obj = IrisCloudJobManager( [cfgRoot] [,queueCfg] )
            % Input 'cfgRoot' is the FULL path to the configuration file of the job manager.
            % Default: cfgRoot = [filesep,'home','pcs','jm',ProjectName,'cfg',CFG_Filename]
            % ProjectName = 'IrisCloud';
            % CFG_Filename = 'IrisCloudJobManager_cfg';
            % cfgRoot = '/home/pcs/jm/plbp/cfg/IrisCloudJobManager_cfg';
            % queueCfg = '/home/pcs/tc/cfg/short.cfg';
            
            % (Optional) input argument 'queueCfg' stores the full path to the queue configuration file.
            
            % Both input arguments must be defined.
            % If no specific job manager configuration file is desired, the argument must be specified as '[]'.
            
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            if( nargin<2 || isempty(queueCfg) ), queueCfg = []; end
            
            obj@JobManager(cfgRoot, queueCfg, 'IrisCloud');
        end

%  function [JobParam, JobState, JobInfo, SuccessFlag, ErrorMsg] = PreProcessJob(obj, JobParamIn, JobStateIn, JobInfoIn, CurrentUser, JobName)
%             
%             CodeRoot = CurrentUser.CodeRoot;
%             
%             % First, set the path.
%             OldPath = obj.SetCodePath(CodeRoot);
%             Username = obj.FindUsername(CurrentUser.UserPath);
%             
%              if( isfield(JobParamIn,'UserType') && ~isempty(JobParamIn.UserType) )
%                 switch JobParamIn.UserType
%                     
%                     case{'EndUser'}
%             
% %             JobParam = JobParamIn;
% %             JobState = JobStateIn;
% %             JobInfo = JobInfoIn;
%             
%             if (isfield(JobParamIn,'ImageOnePath')&& ~isempty(JobParamIn.ImageOnePath))
%                 if (isfield(JobParamIn,'ImageTwoPath')&& ~isempty(JobParamIn.ImageTwoPath))
%                     
%                      AlgorithmIndex=obj.Algorithm(JobParamIn.ImageOnePath,JobParamIn.ImageTwoPath);
%                      % Look for the Algorithm and Developer Name in the table corresponding to
%                      % the algorithm index
%                      
%                      [Algorithm]=Match(AlgorithmIndex);
%                      
%                     
%                       
%                        JobState.ImageOnePath=JobParamIn.ImageOnePath;
%                        JobState.ImageTwoPath=JobParamIn.ImageTwoPath;
%                        JobState.UserType=JobParamIn.UserType;
%                        JobState.AlgorithmName= Algorithm.AlgorithmName;
%                        JobState.DeveloperName= Algorithm.DeveloperName;
%                        
%                        
%                        
%                        
%                        
%                        
%                      
%             SuccessFlag = 1;
%             ErrorMsg = '';
%             
%             path(OldPath);
%                        
%                      
%                      
%                      
%                 else
%                     
%                 ErrorMsg = sprintf( 'Sorry. Image 2 not found\n' );
%                 fprintf( ErrorMsg );
%                 SuccessFlag = 0;
%                 path(OldPath);
%                 return;
%                 end
%             else
%                 ErrorMsg = sprintf( 'Sorry. Image 1 not found\n' );
%                 fprintf( ErrorMsg );
%                 SuccessFlag = 0;
%                 path(OldPath);
%                 return;
%             end
%                     case {'Developer'}
%                     otherwise
%                  ErrorMsg = sprintf( 'Sorry. UserType is not valid. Only valid options are NormalUser or Developer.\n' );
%                 fprintf( ErrorMsg );
%                 SuccessFlag = 0;
%                 path(OldPath); 
%                 end
%              end
%  end
%  
             
            
                     
                     
                     
                     
                     
                     
                    
               
    
end