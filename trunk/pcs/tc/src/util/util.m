% util.m
%
% Utility Class for CML2.
%
% Functionality:
% 1. General-Purpose File Parser, fp().
%
% Version 1, 02/27/2011, Terry Ferrett.
% Version 2, 01/07/2012, Mohammad Fanaei.

classdef util < handle
    
    methods(Static)
        % fp() - File Parser
        function out = fp(filename, heading, key)
            % Method Steps:
            % 1. Open the file specified by filename.
            % 2. Seek to 'heading'.
            % 3. For the ONLY field denoted by 'key', read value into 'out' as a string.
            % 4. Close the file.
            
            fid = fopen(filename);
            
            str_in = fgetl(fid);
            empty_file = isnumeric(str_in);
            
            % Scan for heading.
            while(empty_file == false)
                switch str_in
                    case heading
                        break;
                    otherwise
                        str_in = fgetl(fid);
                        empty_file = isnumeric(str_in);
                end
            end
            
            str_in = fgetl(fid);
            empty_file = isnumeric(str_in);
            
            
            % Scan for key values.
            k = 1;
            while(empty_file == false)
                if( ~isempty(str_in) && str_in(1) ~= '%' )
                    Ind = strfind(str_in, '=');
                    l_key = strtrim( str_in(1:Ind-1) );
                    l_val = strtrim( str_in(Ind+1:end) );
                    Ind_lVal = strfind(l_val, ';');
                    if ~isempty(Ind_lVal), l_val = l_val(1:Ind_lVal-1); end
                    
                    % [l_key l_val] = strtok(str_in, '=');
                    % Remove whitespace
                    % l_key = strtok(l_key);
                    
                    % Remove equal sign
                    % l_val = l_val(2:end);
                    
                    switch l_key
                        case key
                            temp_cell = textscan(l_val, '%s');
                            out{k} = temp_cell{1};
                            k = k+1;
                        otherwise
                            if( ~isempty(l_key ) )
                                if( l_key(1) == '[' )
                                    break;
                                end
                            end
                    end
                end
                str_in = fgetl(fid);
                empty_file = isnumeric(str_in);
                
            end
            fclose(fid);
            % If no matching keys were found, assign out to null.
            out_flag = strcmp('out',who('out'));
            if  isempty(out_flag),
                out = {};
            end
        end
        
    end
end