% util.m
%
% Utility class for CML.
%
% Functionality
%  1. General-purpose file parser, fp()
%
% Version 1
% 2/27/2011
% Terry Ferrett


classdef util < handle
        
    methods(Static)
        % fp() - File Parser
        function out = fp(cfp, heading, key)
            %1. Open the file.
            %2. Seek to 'heading'
            %3. for all fields denoted by 'key
            %   Read value into 'out' array
            
            cfgFid = fopen(cfp);
            
            str_in = fgetl(cfgFid);
            empty_file = isnumeric(str_in);
            
            % Scan for heading.
            while(empty_file == false)
                switch str_in
                    case heading
                        break;
                    otherwise
                        str_in = fgetl(cfgFid);
                        empty_file = isnumeric(str_in);
                end
            end
            
            str_in = fgetl(cfgFid);
            empty_file = isnumeric(str_in);
            
            
            % Scan for key values.
            k = 1;
            while(empty_file == false)
                [l_key l_val] = strtok(str_in, '=');
                % Remove whitespace
                l_key = strtok(l_key);
                
                % Remove equal sign
                l_val = l_val(2:end);
                
                switch l_key
                    case key
                        temp_cell = textscan(l_val, '%s');
                        out{k} = temp_cell{1};
                        k = k+1;
                    otherwise
                        if( length(l_key ) ~= 0 )
                            if( l_key(1) == '[' )
                                break;
                            end
                        end
                end
                                
                str_in = fgetl(cfgFid);
                empty_file = isnumeric(str_in);
                
            end
            
            % If no matching keys were found, assign out to null.
            out_flag = strcmp('out',who('out'));
            if  isempty(out_flag),
                out = {};
            end
        end
        
    end    
end