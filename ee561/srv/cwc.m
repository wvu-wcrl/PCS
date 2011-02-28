% cwc.m
%
% Implementation of the cluster worker controller.
%
% Version 1
% 2/27/2011
% Terry Ferrett

classdef cwc < wc
        
    properties        
        nodes        
        maxWorkers
        workers
        workerPath % path to worker script
        workerScript
        bashScriptPath
        cfp % config file path
        cmlRoot
    end
    
    % Derived properties
    properties
        inPath    % Path to input
        outPath  % Path to results
    end
    
    properties (Access=private)
        wrkCnt
    end
    
    
    methods
        function obj = cwc(cmlRoot, cfpIn, workerScript)
            % 1. Read configuration file name.
            obj.cfp = cfpIn;
            
            % 2. Read input and output paths from configuration file.
            heading = '[Paths]';
            key = 'InputPath';
            out = util.fp(obj.cfp, heading, key);
            obj.inPath = out{1}{1};
            
            heading = '[Paths]';
            key = 'OutputPath';
            out = util.fp(obj.cfp, heading, key);
            obj.outPath = out{1}{1};
            
            % 4. Read active nodes and max workers per node
            %      from configuration file.
            heading = '[Hosts]';
            key = 'host';
            out = util.fp(obj.cfp, heading, key);
            numHosts = length(out);
            for k = 1:numHosts,
                obj.nodes{k} = out{k}{1};
                obj.maxWorkers(k) = str2num(out{k}{2});
            end
            
            obj.cmlRoot = cmlRoot;
            obj.workerScript = workerScript;
            obj.bashScriptPath = [cmlRoot '/srv'];

[ignore pathTemp] = strtok(cmlRoot, '/');
obj.workerPath = ['/rhome' pathTemp '/srv' '/wrk'];
            %obj.workerPath = [cmlRoot '/srv' '/wrk'];
            
            obj.wrkCnt = 0;
            
            % Initialize worker array
            obj.workers = cWrk.empty(1,0);
        end
    end
       
    
    methods
        function wSta(obj, hostname)
            % Inputs
            %  hostname - node hostname, e.g., node01
            %  wNum - unique integer identifying the worker.
            %
            % Execution steps
            % Start a single worker on a single node.
            % 1. Connect to node
            % 2. Start worker
            %   Inputs: unique ID (integer counter)
            % 3. Return process ID
            
            wNum_str = int2str(obj.wrkCnt);
                
            % Form the command string.
            cmd_str = [obj.bashScriptPath, '/start_worker.sh'];
                           
            cmd_str = [cmd_str, ' ',...
                hostname, ' ',...
                obj.workerPath, ' ',...
                obj.workerScript, ' ',...
                int2str(obj.wrkCnt)];
            
            [stat pid] = system(cmd_str);  
            % Create worker object from node name and
            newWrkObj = cWrk(hostname, pid, obj.wrkCnt);
            
            % Add worker object to worker array.
           obj.workers(end+1) = newWrkObj;
            
            % Write test
            
            % Increment worker counter
            obj.wrkCnt = obj.wrkCnt + 1;
        end
        
        function cSta(obj)
        end
                
        function wSto(obj)
        end
        
        function cSto(obj)
        end
                
        function status(obj)
        end
        
     end    
  
end
