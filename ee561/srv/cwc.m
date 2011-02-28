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
        cfp % config file path
    end
    
    % Derived properties
    properties
        inPath    % Path to input
        outPath  % Path to results
    end
    
    
    
    methods
        function obj = cwc(cfpIn)
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
            
        end
    end
       
    
    methods
        function wSta(obj)
        end
        
        function wSto(obj)
        end
        
        function status(obj)
        end
        
        function rcf(obj)
        end
    end    
  
end