% CWC   Create Cluster Worker Controller Object
%
%
%   The calling syntax is:
%     cwc_obj = cwc(cmlRoot, cf, ws)
%
%   Inputs:
%      cmlRoot = CML root directory.
%      cf = Configuration file specifying
%             - List of cluster nodes and maximum workers per node.
%             - Input and output paths for worker data.
%      ws = Name of worker .m script.
%
%   Outputs:
%      cwc_obj = Cluster Worker Controller Object
%
%   Example:
%      [cwc_obj] = cwc( cml_home, 'test.cfg', 'stub_worker' );
%
%          where cml_home is a workspace variable containing the cml
%             root directory, created by the script 'CmlStartup'


% cwc.m
%
% Implementation of the cluster worker controller.
%
% Version 1
% 9/18/2011
% Terry Ferrett

classdef cwc < wc
    
    % Cluster state.
    properties
        wrkCnt
        %nodes
        %maxWorkers
        workers
        workerScript
    end
    
    % Cluster controller paths.
    properties
        bashScriptPath
        cfp
        cmlRoot
        workerPath
        
        svPath
        svFile
    end
    
    % Worker paths.
    properties
        inPath
        outPath
    end
    
    
    methods
        function obj = cwc(cmlRoot, cfpIn)
            % 1. Read configuration file name.
            obj.cfp = strcat(cmlRoot, '/srv/cfg/', cfpIn);
            
            % 2. Read worker input path from configuration file.
            heading = '[Paths]';
            key = 'InputPath';
            out = util.fp(obj.cfp, heading, key);
            obj.inPath = out{1}{1};
            
            % 3. Read worker output path from configuration file.
            heading = '[Paths]';
            key = 'OutputPath';
            out = util.fp(obj.cfp, heading, key);
            obj.outPath = out{1}{1};
            
            
            % 4. Worker script.
            %obj.workerScript = workerScript;
            
            % 5. CML root path and path to BASH scripts.
            obj.cmlRoot = cmlRoot;
            obj.bashScriptPath = [cmlRoot '/srv'];
            
            % 6. State file and path.
            svPathRelative = ['/srv/state'];
            obj.svPath = [cmlRoot svPathRelative];
            obj.svFile = 'cwc_state.mat';
            
            
            % 7.Change the home directory to /rhome - the
            %   mount point for home directories on the cluster nodes.
            [ignore pathTemp] = strtok(cmlRoot, '/');
            obj.workerPath = ['/rhome' pathTemp '/srv' '/wrk'];
            
            % 8. Initialize the worker ID counter to 0.
            obj.wrkCnt = 0;
            
            % 9. Initialize the worker array.
            obj.workers = cWrk.empty(1,0);
            
            
            % Read the worker configuration from the configuration file.
            heading = '[Workers]';
            key = 'worker';
            out = util.fp(obj.cfp, heading, key);
            n = length(out);
            % create a worker object for every worker specified in the config file.
            for k = 1:n,
                cw(obj,out);
            end
            
        end
    end
    
    
    
    methods
        % create worker objects from configuration file data
        cw(obj, cfd)
        % Start single worker.
        staw(obj, worker)
        % Start workers on entire cluster.
        cSta(obj, varargin)
        
        % Stop single worker.
        stow(obj, worker)
        % Stop workers on entire cluster.
        cSto(obj, varargin)
        % delete worker object
        dw(obj, worker)
        % Unconditionally stop all workers running under this username.
        slay(obj)
        % Save the cluster state.
        svSt(obj)
    end
end

