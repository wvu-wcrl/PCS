classdef QPSK < CreateModulation
    
    methods
        function obj = QPSK(SignalProb)
        % Calling Syntax: obj = QPSK( [SignalProb] )
            if( nargin<1 ), SignalProb = []; end
            Constellation = [1 j -j -1];
            SignalSet=[real(Constellation); imag(Constellation)];
%             MappingVector = 0:3;
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'QPSK';
%             obj.MappingVector = MappingVector;
        end
    end
    
end