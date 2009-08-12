classdef TailConvCode < ConvCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj=TailConvCode(Generator [, DecoderType] [,Depth])
        function obj=TailConvCode(Generator, varargin)
            if(length(varargin) == 0)
                DecoderType=-1;         % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
                Depth=-1;
            elseif(length(varargin) == 1)
                DecoderType=varargin{1};
                Depth=-1;
            elseif(length(varargin) == 2)
                DecoderType=varargin{1};
                Depth=varargin{2};
            else
                errordlg('The number of input arguments of the constructor of this class can be at most 3.', 'Constructor Calling Syntax Error');
            end
            obj@ConvCode(Generator, 2, DecoderType, Depth);
        end
    end
end