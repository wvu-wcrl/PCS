% ctc.m   cluster task controller
%
%
%   Calling syntax:
%   ctcobj = ctc(cfp)
%
%   Inputs:
%      cfp = path to configuration file
%                  
%   Outputs:
%      ctcobj = cluster task controller object
%
%   Example:
%      [ctcobj] = ctc(  'eight_core.cfg' );
%
%
% Implementation of the cluster worker controller.
%
% Version 2
% 11/29/2011
% Terry Ferrett


classdef ctc < handle
    
    
    properties       % cluster state
        cfp    % config file path
        
        cfg    % controller configuration structure
        % nl - node list
        % wpn - workers per node
        % qp - queue path
        
        ws % worker state - cell array of structures
        % wid - worker id
        % user - user
        % status - worker status
        
        nw % total number of workers
        aw % active workers
        
        users  % cell array of structs containg active users
        % username - .name
        % input queue path - iqp
        % running path -        rp
        % number of active workers - aw        
        
    end
    
    
    properties    % proprties used by readcfg()
        wrklist
        qp        
    end
        
    
    methods
           function obj = ctc(cfp) % ctc constructor
                        
            % get config file path
            obj.cfp = cfp;
                        
            % initialize the cluster task controller
            init(obj);            
       
            %  enter main control loop
            main(obj);
        end
    end
    
    
    
    methods % called by class constructor
        init(obj) % initialize ctc
        
        main(obj) % main control loop
        
    end
    
    methods % called from init()
        
        readcfg(obj)   % read ctc configuration file
        
        init_cfg(obj)   % initialize configuration structure
        
        init_ws(obj)   % initialize worker state
        
        init_users(obj) % initialize user state
                
     end
end

