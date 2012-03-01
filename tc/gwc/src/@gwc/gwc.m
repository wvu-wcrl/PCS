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
    
    % grid worker controller state
    properties
    rtc    % rapids task vector - track state of rapids tasks
    mrt    % maximum number of simultaneous rapids tasks
    jc       % job counter - increments as rapids jobs are launched
    end
    
       
    % grid worker controller paths.
    properties        
        cf     % config file path
        rp     % path to rapids
        gq     % global queue paths - read from config file
               % iq - input 
               % oq - output 
               % rq - running        
        lp     % log path - read from config file
        bs     % path to bash scripts
       
        pre  % path to Rapids executable - hard coded for now
        tp     % path to rapids template
        rtn    % rapids template name
        rtp    % rapids temporary path - scratch area
        tez    % temporary elements.zip path
        pjp    % path to job.properties
       
    end
 

   % logging parameters
   properties
      log_period     % how often to archive logs, in seconds
      num_logs    % number of archives to save
      verbose_mode   % 1- verbose logging in generic worker, 0 - non verbose
   end
       
    
    methods
        function obj = gwc(cf)
                                       
            % get config file path
            obj.cf = cf;
                        
            % initialize the grid worker controller
            init(obj);                       
            
            %main(obj);
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

