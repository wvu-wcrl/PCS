% SpecificJobManager.m
%  The contents of this source file contain the implementation
%  for the specific job manager class.  The methods inherited
%  from the base class are defined in source files contained
%  in the directory that contains SpecificJobManager.m.
%
%  This class inherits from the general JobManager class.
%  
%  The specific job manager class constructor takes as input
%    job manager configuration file
%    queue configuration file
%
%  and constructs a specific job manager object.
%
%     Last updated on 9/7/2015
%
%     Copyright (C) 2015, Terry Ferrett and Matthew C. Valenti.
%     For full copyright information see the bottom of this file.


classdef SpecificJobManager < JobManager
    
    
    methods(Static)
        
        % Add algorithm path to MATLAB path.
        function OldPath = SetCodePath(CodeRoot)
            % Save path as it exists prior to adding algorithm path.
            OldPath = path;
            
            % Add algorithm path to MATLAB path.
            addpath( fullfile(CodeRoot, 'algorithms/osiris') );
        end
        
    end
   
    methods
        function obj = SpecificJobManager( cfgRoot, queueCfg )
    
            % Determine if configuration files specified as input,
            %  if not, set default values.
            if( nargin<1 || isempty(cfgRoot) ), cfgRoot = []; end
            if( nargin<2 || isempty(queueCfg) ), queueCfg = []; end
            
            % Create job manager object for specific job manager
            % 'IrisCloud'
            obj@JobManager(cfgRoot, queueCfg, 'IrisCloud');
        end
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
