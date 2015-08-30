classdef SpecificJobManager < JobManager
    
    
    methods(Static)
        
        
        function OldPath = SetCodePath(CodeRoot)
            % Determine the home directory.
            OldPath = path;
            
            addpath( fullfile(CodeRoot, 'algorithms/osiris') );
            % This is the location of the mex directory for this architecture.
            % addpath( fullfile( CodeRoot, 'mex', lower(computer) ) );
        end
        
    end
    
    
    methods
        function obj = SpecificJobManager( cfgRoot, queueCfg )
            
            % (Optional) input argument 'queueCfg' stores the full path to the queue configuration file.
            
            % Both input arguments must be defined.
            % If no specific job manager configuration file is desired, the argument must be specified as '[]'.
            
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            if( nargin<2 || isempty(queueCfg) ), queueCfg = []; end
            
            obj@JobManager(cfgRoot, queueCfg, 'IrisCloud');
        end
    end
    
    
end