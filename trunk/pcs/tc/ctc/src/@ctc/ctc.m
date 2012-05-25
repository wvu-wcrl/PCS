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
%      [ctcobj] = ctc(  'pcs_test.cfg' );
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

        ucfg   % user configuration filename
        
        gq     % global queue paths - read from config file
               % iq - input 
               % oq - output 
               % rq - running 
               % log - log files 
       
        ws % worker state - cell array of structures
        % wid - worker id
        % user - user
        % status - worker status
     
        
        nw % total number of workers
        aw % active workers
        
        users  % cell array of structs containg active users
        % username -                           username
        % input queue path -                 iq
        % running path -                       rq
        % output path -                         oq
        % active workers for this user-        aw
        % user location - web or local        user_location        

	bs        % bash script path
        
    end
    
    
    properties    % proprties used by readcfg()
        wrklist
        qp        
    end
    
    
    properties   % logging properties
        ctc_logfile
    end
        
    
    
    methods
	function obj = ctc(cfp, ss) % ctc constructor
            
   IS_STOP = strcmp(ss, 'stop');  % if the controller is stopping, do not enter main loop
            
 
   
            % get config file path
            obj.cfp = cfp;
                        
            % initialize paths, worker states, and user structures
            
            init(obj);            
            msg = ['Cluster task controller initialized.'];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
            
            
            % manipulate queues based startup state
            manage_queues(obj, ss);

          
            if ~IS_STOP
            %  enter main control loop
            
            msg = ['Entering main task controller loop.'];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
            main(obj, ss);
            end

        end
    end
    
    
    
    methods % called by class constructor
        init(obj) % initialize ctc
        
	    main(obj, ss) % main control loop
        
    end

    
    methods % called from init()
        
        readcfg(obj)   % read ctc configuration file
        
        init_cfg(obj)   % initialize configuration structure
        
        init_ws(obj)   % initialize worker state
        
        init_users(obj) % initialize user state
                
     end
end

