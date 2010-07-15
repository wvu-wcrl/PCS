classdef BPSK < Modulation
    
    properties
    end
    
    methods
        
        function obj = BPSK()
            Order = 2;
            Constellation = [1 -1];
            SignalSet=[real(Constellation); imag(Constellation)];
            MappingVector = 0:1;
            obj@Modulation(SignalSet);
            obj.Type = 'BPSK';
            obj.MappingVector = MappingVector;
        end
        
    end
end