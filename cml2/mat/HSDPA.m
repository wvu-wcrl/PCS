classdef HSDPA < Modulation
    
    properties
    end
    
    methods
        
        % Class constructor: obj = HSDPA( [Order] )
        function obj = HSDPA( varargin )
            
            if length(varargin) >= 1
                Order = varargin{1};
                % Making sure that modulation Order is a power of 2.
                if ( rem( log(Order)/log(2),1 ) )
                    error( 'The order of modulation MUST be a power of 2.' );
                end
            else
                Order = 4;
            end
            
            if Order == 4 % QPSK
                Temp = [1 1;1 -1;-1 1;-1 -1]';
                Constellation = (Temp(1,:) + sqrt(-1)*Temp(2,:))/sqrt(2);
                MappingVector = 0:3;
            elseif Order == 16 % 16-QAM
                for Point=0:15
                    T = Point;
                    for k=4:-1:1
                        bit_vector(4-k+1) = fix( T/(2^(k-1)) );
                        T = T - bit_vector(4-k+1)*2^(k-1);
                    end
                    iq = (-1).^bit_vector;
                    % Constellation(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(5);
                    Constellation(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(10);
                end
                MappingVector = 0:15;
            else
                error( 'HSDPA modulation is supported ONLY for Order=4 or 16.' );
            end
            
            SignalSet=[real(Constellation); imag(Constellation)];
            
            obj@Modulation(SignalSet);
            obj.Type = 'HSDPA';
            obj.MappingVector = MappingVector;
        end
        
    end
    
end