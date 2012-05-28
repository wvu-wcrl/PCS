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
        tp     % path to rapids templates
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
 
        jobid = start_job(obj, job_name, dataset, resultset)     % create new rapids job
        
        update_job(obj, job_name, task_name)    % add new task to existing rapids job
        
        
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
