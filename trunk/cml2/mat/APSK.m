classdef APSK < Modulation
    
    properties
    end
    
    methods
        
        % Class constructor: obj = APSK( [Order] [,MappingType] [,Mapper] )
        function obj = APSK( varargin )
            
            if length(varargin) >= 1
                Order = varargin{1};
                % Making sure that modulation Order is a power of 2.
                if ( rem( log(Order)/log(2),1 ) )
                    error('The order of modulation MUST be a power of 2.');
                end
            else
                Order = 16;
            end
            
            Temp = [+1 +j -1 -j]; % Inner ring is QPSK.
            % Mapping is fixed.
            if Order==16
                rho = 2.85; % This value could be varied.
                Temp(5:16) = rho*exp( j*2*pi*[0:11]'/12 ); % Outer ring is 12-PSK w/ radius rho.
                MappingVector = [3 11 9 1 6 2 10 14 15 13 12 8 0 4 5 7];
            elseif Order==32
                rho1 = 2.84; % These values could be varied.
                rho2 = 5.27;
                % Middle and outer rings.
                Temp(5:16) = rho1*exp( j*2*pi*[0:11]'/12 );
                Temp(17:32) = rho2*exp( j*2*pi*[0:15]'/16 );
                MappingVector = [24 8 0 16 29 28 12 13 9 1 5 4 20 21 17 25 ...
                    26 30 14 10 15 11 3 7 2 6 22 18 23 19 27 31];
            else
                error( 'APSK modulation requires Order=16 or 32.' );
            end
            
            Constellation( MappingVector+1 ) = Temp;
            Constellation = Constellation/sqrt( mean(abs(MappingVector).^2) ); % Normalization
            
            SignalSet=[real(Constellation); imag(Constellation)];
        end
        
    end
    
end