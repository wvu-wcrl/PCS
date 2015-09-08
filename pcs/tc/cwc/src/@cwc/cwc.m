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
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


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
        
        qn              % queue name

        gq     % global queue paths - read from config file
        % iq - input
        % oq - output
        % rq - running
        
        lp     % log path - read from config file
        lfup           % logging function path
    end
    
    
    % Cluster controller paths.
    properties
        bs       % path to bash scripts
        cf        % config file path
    end
    
    
    % logging parameters for workers, updated 5/25/2012
    properties
        log_period     % how often to archive logs, in seconds
        num_logs    % number of archives to save
        verbose_mode   % 1- verbose logging in generic worker, 0 - non verbose
    end

   % worker performance parameters, updated 10/2013
    properties
        wsp   % worker sweep period
    end

   
    
    
    % logging parameters for worker controller, added 5/25/2012
    properties
        cwc_logfile
    end
    
    
    
    
    methods
        function obj = cwc(cf)
            
            % get config file path
            obj.cf = cf;
            
            % initialize the cluster worker controller
            init(obj);
            
            
            % message regarding cwc initialization
            msg = ['Worker controller started.'];
            PrintOut(msg, 0, obj.cwc_logfile{1}, 1);
            
            
        end
    end
    
    
    
    
    methods
        
        % Clean PCS temporary directories on all specified nodes.
        cptd(obj, nodes);
        
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
        
        % monitor and revive workers which die
        status(obj);
        
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
