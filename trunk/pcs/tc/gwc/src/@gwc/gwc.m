% gwc   create grid worker controller object
%
%
%   The calling syntax is:
%     gwc_obj = gwc(cf)
%
%   Inputs:  
%      cf = Configuration file specifying
%             - number of grid engines to utilize
%
%   Outputs:
%      cwc_obj = cluster worker controller object
%
%   Example:
%      [gwc_obj] = gwc( 'eight_core.cfg' );
%
%
% Version 1
% 2/22/2012
% Terry Ferrett

classdef gwc < handle
    
    % worker controller state
    properties
    rtc    % rapids task vector - track state of rapids tasks
    mrt    % maximum number of simultaneous rapids tasks
    end
    
    
    % Cluster controller paths.
    properties        
        rp     % path to rapids
        gq     % global queue paths - read from config file
               % iq - input 
               % oq - output 
               % rq - running        
        lp     % log path - read from config file
        bs     % path to bash scripts
        cf     % config file path

        tp     % path to rapids template
    end
 

   % logging parameters
   properties
      log_period     % how often to archive logs, in seconds
      num_logs    % number of archives to save
      verbose_mode   % 1- verbose logging in generic worker, 0 - non verbose
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

        main(obj)   % primary control loop
        
        

        % Start single worker.
        %staw(obj, worker)
        
        % Start workers on entire cluster.
        %cSta(obj, varargin)
        
        % Stop single worker.
        %stow(obj, worker)
        
        % Stop workers on entire cluster.
        %cSto(obj, varargin)

	% slay all active workers
	%slay(obj);
                
                
        
    end
    
end

