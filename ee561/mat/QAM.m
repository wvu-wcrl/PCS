classdef QAM < CreateModulation
    
    methods
        function obj = QAM( Order, SignalProb, MappingType )
            % Class constructor: obj = QAM( [Order] [,SignalProb] [,MappingType/MappingVector] )
            % MappingType='gray'(Order=16,64,256), For ALL{'Antigray','SP','MSP','MSEW','huangITNr1','huangITNr2','huangLetterNr1','huangLetterNr2'} Order is 16.
            if( nargin<1 || isempty(Order) )
                Order = 16;
            elseif( rem( log2(Order),1 ) )
                % Making sure that modulation Order is a power of 2.
                error( 'The order of modulation MUST be a power of 2.' );
            end
            if( nargin<2 )
                SignalProb = [];
            end
            
            if( nargin<3 || isempty(MappingType) )
                MappingType = [];
                MappingVector = 0:Order-1;
            elseif ~ischar(MappingType)
                if (length(MappingType) ~= Order)
                    error('Length of MappingType must be EQUALL to the Order of modulation.');
                elseif (sum( sort(MappingType) ~= [0:Order-1] ) > 0)
                    error( 'MappingType must contain all integers 0 through Order-1.' );
                end
                MappingVector = MappingType;
            end
            
%           [Constellation, MappingVector] = CreateQAMConstellation( Order, MappingType );
            Constellation = CreateQAMConstellation( Order, MappingType );
            
            SignalSet = [real(Constellation); imag(Constellation)];
            
            obj@CreateModulation(SignalSet, SignalProb);
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