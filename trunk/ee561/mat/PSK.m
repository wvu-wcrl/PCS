classdef PSK < Modulation
    
    properties
    end
    
    methods
        % Class constructor: obj = PSK( [Order] [,MappingType/MappingVector] )
        % MappingType='gray','SP'(Order=4,8),'SSP'(Order=8) or 'MSEW'(Order=8)
        function obj = PSK( varargin )
            Order = 8;
            if length(varargin) >= 1
                Order = varargin{1};
                % Making sure that modulation Order is a power of 2.
                if ( rem( log(Order)/log(2),1 ) )
                    error( 'The order of modulation MUST be a power of 2.' );
                end
            end
            
            if length(varargin) >= 2
                MappingType = varargin{2};
                if ~ischar(MappingType)
                    if (length(MappingType) ~= Order)
                        error('Length of MappingType must be EQUALL to the Order of modulation.');
                    elseif (sum( sort(MappingType) ~= [0:Order-1] ) > 0)
                        error( 'MappingType must contain all integers 0 through Order-1.' );
                    end
                    MappingVector = MappingType;
                    MappingType = 'UserDefined';
                end
            else
                MappingType = [];
                MappingVector = 0:Order-1;
            end
            
            Temp = exp( j*2*pi*[0:Order-1]/Order );
            if ( ischar(MappingType) && ~strcmpi(MappingType, 'UserDefined') )
                switch MappingType
                    case 'gray'
                        MappingVector = [0 1];
                        for m = 2:log2(Order)
                            MappingVector = [ MappingVector, 2^(m-1) + fliplr(MappingVector) ];
                        end
                    case 'SP'
                        if (Order == 8)
                            MappingVector = [0 1 2 3 4 5 6 7];
                        elseif (Order == 4)
                            MappingVector = [0 1 2 3];
                        else
                            error('SP coded PSK is ONLY supported for Order=4 or 8.');
                        end
                    case 'SSP'
                        if Order == 8
                            MappingVector = [0 5 2 7 4 1 6 3];
                        else
                            error( 'SSP coded PSK is ONLY supported for Order=8.' );
                        end
                    case 'MSEW'
                        if Order == 8
                            MappingVector = [0 3 5 6 1 2 4 7];
                        else
                            error( 'MSEW coded PSK is ONLY supported for Order=8.' );
                        end
                    otherwise
                        error('Labeling (MappingType) or symbol set size (Order) is not supported for PSK modulation.');
                end
            end
            
            Constellation( MappingVector+1 ) = Temp;
            SignalSet = [real(Constellation); imag(Constellation)];
            
            obj@Modulation(SignalSet);
            obj.Type = 'PSK';
            obj.MappingType = MappingType;
%             obj.MappingVector = MappingVector;
        end
    end
    
end