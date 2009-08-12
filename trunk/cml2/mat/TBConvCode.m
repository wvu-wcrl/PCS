classdef TBConvCode < ConvCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj=TailConvCode(Generator [, Depth])
        function obj=TailConvCode(Generator, varargin)
            DecoderType=-1;         % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            if(length(varargin) == 0)
                Depth=-1;
            elseif(length(varargin) == 1)
               Depth=varargin{1};
            else
                errordlg('The number of input arguments of the constructor of this class can be at most 2.', 'Constructor Calling Syntax Error');
            end
            obj@ConvCode(Generator, 2, DecoderType, Depth);
        end
    end
end