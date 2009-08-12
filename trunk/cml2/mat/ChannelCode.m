classdef ChannelCode < handle
    
    properties
        DataBits        % Row vector of data bits to be coded
        DataLength      % Length of DataBits vector
        CodeWord        % Generated row vector codeword of DataBits
        CodeWordLength  % Length of each CodeWord
        ReceivedLLR     % Received vector of bit Log-Likelihood-Ratio (LLR) for the received data (CodeWord) to be decoded
        EstBits         % Row vector of decoded bits of ReceivedLLR
        Rate            % Code rate (R=k/n)
    end
    
    methods
        function [CodeWord]=Encode(obj, DataBits)
        end
        function [EstData]=Decode(obj, ReceivedLLR)
        end
    end    
end