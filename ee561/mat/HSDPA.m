classdef HSDPA < CreateModulation
    
    methods
        function obj = HSDPA( Order, SignalProb )
            % Class constructor: obj = HSDPA( [Order] [,SignalProb] )
            if( nargin<1 || isempty(Order) )
                Order = 4;
            elseif( Order~=4 && Order ~= 16 )
                % Making sure that modulation Order is supported.
                error( 'HSDPA modulation is supported ONLY for Order=4 or 16.' );
            end
            if( nargin<2 )
                SignalProb = [];
            end
            
            if Order == 4 % QPSK
                Temp = [1 1;1 -1;-1 1;-1 -1]';
%                 Constellation = (Temp(1,:) + sqrt(-1)*Temp(2,:))/sqrt(2);
                Constellation = Temp(1,:) + sqrt(-1)*Temp(2,:);
%                 MappingVector = 0:3;
            elseif Order == 16 % 16-QAM
                for Point=0:15
                    T = Point;
                    for k=4:-1:1
                        bit_vector(4-k+1) = fix( T/(2^(k-1)) );
                        T = T - bit_vector(4-k+1)*2^(k-1);
                    end
                    iq = (-1).^bit_vector;
                    % Constellation(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(5);
%                     Constellation(1,Point+1) = ( iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4)) )/sqrt(10);
                    Constellation(1,Point+1) = iq(1)*(2-iq(3)) + sqrt(-1)*iq(2)*(2-iq(4));
                end
%                 MappingVector = 0:15;
            else
                error( 'HSDPA modulation is supported ONLY for Order=4 or 16.' );
            end
            
            SignalSet=[real(Constellation); imag(Constellation)];
            
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'HSDPA';
%             obj.MappingVector = MappingVector;
        end
    end
    
end