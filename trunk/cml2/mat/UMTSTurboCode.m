classdef UMTSTurboCode < TurboCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj = UMTSTurboCode(DataLength [,CodewordLength] [,DecoderType] [,Iteration])
        function obj = UMTSTurboCode(DataLength, varargin)
            
            G1 = [1 0 1 1;1 1 0 1];
            
            % Default values for DecoderType and Iteration parameters.
            CodewordLength = -1;    % In this case, the DEFAULT CodewordLength of the specified UMTS turbo code and DEFAULT PUNCTURING is used.
            DecoderType = 0;        % SISO decoding algorithm using linear-log-MAP (Correction function is a straght line) (DEFAULT).
            Iteration = 8;
            
            if (length(varargin) >= 1)
                CodewordLength = varargin{1};
                if (length(varargin) >= 2)
                    DecoderType = varargin{2};
                    if (length(varargin) >= 3)
                        Iteration = varargin{3};
                    end
                end
            end
            
            % Determine the puncturing pattern of the UMTS codewords ONLY if the CodewordLength has been specified.
            if CodewordLength ~= -1
                [PuncturePatt, TailPunc] = UmtsPunPattern( DataLength, CodewordLength );
            else
                PuncturePatt = [1 1;1 1;0 0;1 1];
                TailPunc = ones(4,3);
            end
            
            obj@TurboCode(G1, G1, 3, PuncturePatt, TailPunc, DataLength, DecoderType, Iteration);
        end
    end
    
end