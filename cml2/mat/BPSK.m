classdef BPSK < Modulation
    
    properties
    end
    
    methods
        
        function obj = BPSK()
            Order = 2;
            Contellation = [1 -1];
            SignalSet=[real(Constellation); imag(Constellation)];
            MappingVector = [0:1];
            obj@Modulation('BPSK');
        end
        
    end
end