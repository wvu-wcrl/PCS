% cwc   create cluster worker controller object
%
%
%   The calling syntax is:
%     cwc_obj = cwc(cf)
%
%   Inputs:  
%      cf = Configuration file specifying
%             - List of cluster nodes and maximum workers per node.
%             - Input and output paths for worker data.
%
%   Outputs:
%      cwc_obj = cluster worker controller object
%
%   Example:
%      [cwc_obj] = cwc( 'eight_core.cfg' );
%
%
% Version 1
% 12/26/2011
% Terry Ferrett

classdef cwc < handle
    
    % worker controller state
    properties
        workers     % cell array of structs containing wid, node name, pid 
                         % wid - worker id
                         % node - node name
                         % pid    - process id

        nodes       % master list of active nodes
                         
        gwp             % generic worker path
        gwn             % generic worker script name
        
        gq     % global queue paths - read from config file
               % iq - input 
               % oq - output 
               % rq - running 
       
        lp     % log path - read from config file
    end
    
    
    % Cluster controller paths.
    properties        
        bs       % path to bash scripts
        cf        % config file path
        
        %cmlRoot
	    %srv_root
	    %proj_root	
        %workerPath        
        %svPath
        %svFile
    end
    
    
    
    methods
        function obj = cwc(cf)
                                       
            % get config file path
            obj.cf = cf;
                        
            % initialize the cluster worker controller
            init(obj);            
       
            
            
        end
    end
    
    
    
    
    methods
               
        
        % Start single worker.
        staw(obj, worker)
        
        % Start workers on entire cluster.
        cSta(obj, varargin)
        
        % Stop single worker.
        stow(obj, worker)
        
        % Stop workers on entire cluster.
        cSto(obj, varargin)

	% slay all active workers
	slay(obj);
                
        
        % return the number of workers for user 'user'
        %[NumberWorkers nodes] = cstat(obj, user)
        
        
        % return the number of workers for all users
        
        
        % return list of active users
        
        
        % stop n workers for user 'user' and move back to input
        
        
        % stop n workers for user 'user' and flush
                
        
    end
    
    
    
    
    
    
    
    
    methods (Access = private)
                
        % create worker objects from configuration file data
      %  cw(obj, cf)
                
        % delete worker object
       % dw(obj, worker)
        
        % Unconditionally stop all workers running under this username.
    %    slay(obj)
    
        % Save the cluster state.
        %svSt(obj)
    
    end
end

