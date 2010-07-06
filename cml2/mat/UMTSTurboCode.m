classdef UMTSTurboCode < TurboCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj=UMTSTurboCode(DataLength [, DecoderType] [,Iteration])
        function obj=UMTSTurboCode(DataLength, varargin)
            
            G1 = [1 0 1 1;1 1 0 1];
            PuncturePatt = [1 1;1 1;0 0;1 1];
            TailPunc = [1 1 1;1 1 1;1 1 1;1 1 1];
            
            if(length(varargin) == 0)
                DecoderType=0;      % SISO decoding algorithm using linear-log-MAP (Correction function is a straght line) (DEFAULT).
                Iteration=8;
            elseif(length(varargin) == 1)
                DecoderType=varargin{1};
                Iteration=8;
            elseif(length(varargin) == 2)
                DecoderType=varargin{1};
                Iteration=varargin{2};
            else
                errordlg('The number of input arguments of the constructor of this class can be at most 3.', 'Constructor Calling Syntax Error');
            end
            
            obj@TurboCode(G1, G1, 3, PuncturePatt, TailPunc, DataLength, DecoderType, Iteration);
        end
    end
    
end