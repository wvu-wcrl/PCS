classdef NSCConvCode < ConvCode
    
    properties
    end
    
    methods
        % The syntax of calling the construcot of this class is as follows: obj=NSCConvCode(Generator [, DecoderType])
        function obj=NSCConvCode(Generator, varargin)
            if(length(varargin) == 0)
                DecoderType=-1;         % optimum Soft-In/Hard-Out Viterbi decoding algorithm (DEFAULT)
            elseif(length(varargin) == 1)
                DecoderType=varargin{1};
            else
                errordlg('The number of input arguments of the constructor of this class can be at most 2.', 'Constructor Calling Syntax Error');
            end
            obj@ConvCode(Generator, 1, DecoderType);
        end
    end
end