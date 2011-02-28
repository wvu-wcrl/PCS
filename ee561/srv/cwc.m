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
            obj.workerPath = [cmlRoot '/srv' '/wrk'];
        end
    end
       
    
    methods
        function wSta(obj, hostname, wNum)
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
            
            wNum_str = int2str(wNum);
                
            % Form the command string.
            cmd_str = [obj.workerPath, ' ',...
                    obj.workerScript];
                
            cmd_str = [cmd_str, ' ',...
                hostname, ' ',...
                obj.workerPath, ' ',...
                obj.workerScript, ' ',...
                wNum_str];
            
            [stat pid] = system(cmd_str);  
            % Save the PID
            % Create worker object from node name and
            %  PID and worker number
            % Increment worker number
            % Write test
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