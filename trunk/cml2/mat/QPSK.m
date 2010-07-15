classdef QPSK < Modulation
    
    properties
    end
    
    methods
        
        function obj = QPSK()
            Order = 4;
            Constellation = [1 +j -j -1];
            SignalSet=[real(Constellation); imag(Constellation)];
            MappingVector = [0:3];
        end
        
    end
    
end