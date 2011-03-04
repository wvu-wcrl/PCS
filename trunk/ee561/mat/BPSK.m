classdef BPSK < CreateModulation
    
    properties
    end
    
    methods
        function obj = BPSK(SignalProb)
%             Order = 2;
            if( nargin<1 )
                SignalProb = [];
            end
            Constellation = [1 -1];
            SignalSet = Constellation;
%             SignalSet=[real(Constellation); imag(Constellation)];
%             MappingVector = 0:1;
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'BPSK';
%             obj.MappingVector = MappingVector;
        end
    end
end