classdef APSK < CreateModulation
    
    methods
        function obj = APSK( Order, SignalProb )
            % Calling Syntax: obj = APSK( [Order] [,SignalProb] )
            % APSK modulation order can be 16 (DEFAULT) or 32.
            if( nargin<1 || isempty(Order) )
                Order = 16;
            elseif( Order~=16 && Order~=32 )
                % Making sure that modulation Order is supported.
                error( 'APSK:InvalidOrder', 'APSK modulation is supported ONLY for Order=16 or 32.' );
            end
            if( nargin<2 ), SignalProb = []; end
            
            Temp = [1 j -1 -j]; % Inner ring is QPSK.
            % Mapping is fixed.
            if Order==16
                rho = 2.85; % This value could be varied.
                Temp(5:16) = rho*exp( j*2*pi*[0:11]'/12 ); % Outer ring is 12-PSK w/ radius rho.
                MappingVector =  0:15;
%                 MappingVector = [3 11 9 1 6 2 10 14 15 13 12 8 0 4 5 7];
            elseif Order==32
                rho1 = 2.84; % These values could be varied.
                rho2 = 5.27;
                % Middle and outer rings.
                Temp(5:16) = rho1*exp( j*2*pi*[0:11]'/12 );
                Temp(17:32) = rho2*exp( j*2*pi*[0:15]'/16 );
                MappingVector = [24 8 0 16 29 28 12 13 9 1 5 4 20 21 17 25 ...
                    26 30 14 10 15 11 3 7 2 6 22 18 23 19 27 31];
            else
                error( 'APSK:InvalidOrder', 'APSK modulation is supported ONLY for Order=16 or 32.' );
            end
            
            Constellation( MappingVector+1 ) = Temp;
%             Constellation = Constellation/sqrt( mean(abs(Constellation).^2) ); % Normalization
            
            SignalSet=[real(Constellation); imag(Constellation)];
            
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'APSK';
%             obj.MappingVector = MappingVector;
        end
    end
    
end