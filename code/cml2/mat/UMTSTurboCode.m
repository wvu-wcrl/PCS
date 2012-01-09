classdef UMTSTurboCode < TurboCode
    
    methods
        
        function obj = UMTSTurboCode(DataLength, CodewordLength, DecoderType, Iteration)
        % Calling syntax: obj = UMTSTurboCode(DataLength [,CodewordLength] [,DecoderType] [,Iteration])
            G1 = [1 0 1 1 ; 1 1 0 1];
            
            % Default values for CodewordLength, DecoderType, and Iteration parameters.
            if(nargin<2 || isempty(CodewordLength))
                CodewordLength = -1; % DEFAULT CodewordLength of the specified UMTS turbo code and DEFAULT PUNCTURING is used.
                PuncturePatt = [1 1;1 1;0 0;1 1];
                TailPunc = ones(4,3);
            elseif( CodewordLength ~= -1 )
                % Determine the puncturing pattern of the UMTS codewords ONLY if the CodewordLength has been specified.
                [PuncturePatt, TailPunc] = UmtsPunPattern( DataLength, CodewordLength );
            end
            if(nargin<3 || isempty(DecoderType))
                DecoderType = 0; % SISO decoding algorithm using linear-log-MAP (Correction function is a straght line) (DEFAULT).
            end
            if(nargin<4 || isempty(Iteration)), Iteration = 8; end
            
            obj@TurboCode(G1, G1, 3, PuncturePatt, TailPunc, DataLength, DecoderType, Iteration);
        end
        
    end
end