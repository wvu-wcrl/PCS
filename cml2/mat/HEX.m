classdef HEX < Modulation
    
    properties
    end
    
    methods
        
        % (ONLY 16-)HEX modulation constructor.
        function obj = HEX()
            Order = 16;
            MappingVector = 0:Order-1;
            
            % Fixed mapping.
            Constellation = transpose( [0
                -2
                2
                4
                (-1 + j*sqrt(3))
                (-3 + j*sqrt(3))
                ( 1 + j*sqrt(3))
                ( 3 + j*sqrt(3))
                ( 1 - j*sqrt(3))
                (-1 - j*sqrt(3))
                ( 3 - j*sqrt(3))
                (-3 - j*sqrt(3))
                (-2 + j*2*sqrt(3))
                (   - j*2*sqrt(3))
                (   + j*2*sqrt(3))
                (-2 - j*2*sqrt(3))] );
            Temp = Constellation/sqrt( mean(abs(Constellation).^2) ); % Normalization
            
            Constellation( MappingVector+1 ) = Temp;
            
            SignalSet=[real(Constellation); imag(Constellation)];
        end
        
    end
    
end