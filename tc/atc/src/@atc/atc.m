% atc.m   cluster task controller
%
%
%   Calling syntax:
%   ctcobj = atc(cfp, ss)
%
%   Inputs:
%      cfp   path to configuration file
%      ss    starting state. see header of 'manage_queues.m' for
%              details
%
%   Outputs:
%      ctcobj = cluster task controller object
%
%   Example:
%      [ctcobj] = ctc(  'pcs_test.cfg', 'start' );
%
%
% Implementation of the AWS worker controller.
%
% Version 1
% 11/2016
% Terry Ferrett
%
%     Copyright (C) 2016, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


classdef atc < handle
    
    % Task controller state
    properties
 
        cfp      % Queue configuration file path
        
        ucfg     % User configuration file name
        %%% potentially need configuration file for AWS users
        
        bs       % bash script path
        
        gq_name  % Global queue name - {short, long, testing}
        %%% set to AWS

        gq       % Global queue paths 
                    % iq - input
                    % oq - output
                    % rq - running
                    % log - log files
                    
        peu      % path to file containing username of 
                 %  previously executing user
        
        ceu      % path to file containing username of 
                 %  previously executing user
        
                 
        %%% implement logic for starting and maintaining workers   
        ws       % Worker state 
                   % wid - worker id
                   % user - user
                   % status - worker status
                
        nw       % total number of workers
        
        aw       % active workers
     
        upfp     % user priority file path.  read from ctc configuration file.
        
        d_pr     % default priority. read from ctc configuration file.
                 
        %%% Adjust for AWS
        qbuf     % queue buffer specifying the number of tasks which may be loaded
                 %  into the input queue beyond the total number of workers
        
        %%% adjust for AWS
        tsp      % sweep period - time between queue passes
        
        users    % active users
                    % username - username of POSIX user
                    % iq - input queue path
                    % rq - running path
                    % oq - output path
                    % aw - active workers for this user
                    % user_location - user location - web or local
                    % pr  - priority: 0-10
                    %         determines proportion of queue user utilizes            
                    
         bu       % store information about user who is blocked waiting
                  %  for free workers
                    % username   Blocked user username
                    % tu         Number of tasks to execute when the blocked user
                    %            user resumes
                    % isbl       user blocked state
                    %              0   not blocked
                    %              1   blocked
    end
    
    
    % Used by atc configuration file parser: readcfg()
    properties    
        
        wrklist
        
        qp
        
    end
    
    
    % Logging 
    properties   
        
        lfup          % log function path
        
        %%% Modify for AWS
        atc_logfile   % log file path
    
    end
    
    
    % Heartbeat
    properties 
        
        hb_path       % path to heartbeat directory
        
        hb_period     % heartbeat period in seconds
    
    end
    
    
    methods
        
        % atc constructor
        %  cfp - config file path
        %  ss  - ctc starting state
        function obj = atc(cfp, ss) 
            
            % if the controller is stopping, do not enter main loop
            IS_STOP = strcmp(ss, 'stop');  
                    
            % get atc config file path
            obj.cfp = cfp;
            
            % perform atc initialization              
            init(obj);
            
            % in console, show that atc was initialized
            msg = 'AWS task controller initialized.';
            PrintOut(msg, 0, obj.atc_logfile{1}, 1);
            
            % manage global queues based on startup state
            manage_queues(obj, ss);
            
            % Enter main control loop
            if ~IS_STOP          
                
                % in console, show that main loop is starting
                msg = 'Entering main AWS task controller loop.';
                PrintOut(msg, 0, obj.atc_logfile{1}, 1);
                
                main(obj, ss);
                
            end
            
        end
    end
    
    
    % called by class constructor
    methods 
        
        init(obj)       % initialize ctc
        
        main(obj, ss)   % main control loop
        
    end
    
    
    % called from initialization method, init
    methods 
        
        readcfg(obj)   % read atc configuration file
        
        init_cfg(obj)   % initialize configuration structure
        
        init_ws(obj)   % initialize worker state
        
        init_users(obj) % initialize user state
        
    end
end


%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
