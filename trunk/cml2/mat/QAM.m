classdef QAM < Modulation
    
    properties
    end
    
    methods
        % Class constructor: obj = QAM( [Order] [,MappingType/MappingVector] )
        % MappingType='gray'(Order=16,64,256), For ALL{'Antigray','SP','MSP','MSEW','huangITNr1','huangITNr2','huangLetterNr1','huangLetterNr2'} Order is 16.
        function obj = QAM( varargin )
            Order = 16;
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
                end
            else
                MappingType = [];
                MappingVector = 0:Order-1;
            end
%             [Constellation, MappingVector] = CreateQAMConstellation( Order, MappingType );
            Constellation = CreateQAMConstellation( Order, MappingType );
            
            SignalSet = [real(Constellation); imag(Constellation)];
            
            obj@Modulation(SignalSet);
            obj.Type = 'QAM';
            if ( ~ischar(MappingType) && length(MappingType)==Order )
                obj.MappingType = 'UserDefined';
            else
                obj.MappingType = MappingType;
            end
%             obj.MappingVector = MappingVector;
        end
    end
    
end