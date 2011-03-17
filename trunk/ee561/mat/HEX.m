classdef HEX < CreateModulation
    
    methods
        function obj = HEX(SignalProb)
            % (ONLY 16-)HEX modulation constructor.
            Order = 16;
            if( nargin<1 || isempty(SignalProb) )
                SignalProb = [];
            elseif ( length(SignalProb) ~= 16 )
                error('HEX:InvSignalProb', 'The 1-by-16 input vector SignalProb contains signal RELATIVE probabilities for 16-HEX modulation.');
            end
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
%             Temp = Constellation/sqrt( mean(abs(Constellation).^2) ); % Normalization
            Temp = Constellation;
            
            Constellation( MappingVector+1 ) = Temp;
            
            SignalSet=[real(Constellation); imag(Constellation)];
            
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'HEX';
%             obj.MappingVector = MappingVector;
        end
    end
    
end