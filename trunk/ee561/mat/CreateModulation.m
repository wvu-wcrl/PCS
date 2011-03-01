classdef CreateModulation < handle
    
    properties
        Type='custom'   % Modulation Type (as a STRING) (ALL case-INsensitive)
                        % 'BPSK', 'QPSK', 'APSK'(Order=16,32), 'HEX'(Order=16), 'HSDPA' (Order=4,16) or 'custom'
                        % 'FSK'(MappingType='gray','reversegray'(Order=8,16),'mv'(Order=8,16),'dt'(Order=8,16), For ALL {'gray2','gray3','gray4','gray5','gray6'} Order is 8)
                        % 'PSK' (MappingType='gray','SP'(Order=4,8),'SSP'(Order=8),'MSEW'(Order=8))
                        % 'QAM'(MappingType='gray'(Order=16,64,256), For ALL{'Antigray','SP','MSP','MSEW','huangITNr1','huangITNr2','huangLetterNr1','huangLetterNr2'} Order is 16,Order=32(Fixed Mapping))
        Order       % Modulation Order which is the number of points (symbols) in the signal constellation (It has to be a power of 2.)
        MappingType         % Mapping type (as a STRING OR VECTOR of integers 0 through Order-1 exactly once)
                            % 'gray', 'Antigray', 'quasigray', 'SP', 'SSP', 'MSEW', 'huangITNr1', 'huangITNr2', 'huangLetterNr1', 'huangLetterNr2', 'mv', 'dt'.
                            % It is not needed for 'BPSK', 'QPSK', 'HSDPA', 'HEX', 'APSK', or orthogonal 'FSK' (h=1).
%         MappingVector     % Mapping vector (ith element of this vector is the set of bits associated with the ith symbol.) Its length is equal to Order.
%                           MappingVector must contain ALL integers from 0 through Order-1.
                
        SignalSet   % K by Order REAL Signal Constellation (K is the dimensionality of the signal space. There are Order points in the signal space.)
        
        SignalProb  % 1 by Order vector of signal probabilities.
    end
    
    methods
        function obj = CreateModulation(SignalSet, SignalProb)
        % Class constructor: obj = Modulation(SignalSet, SignalProb)
            obj.Order = size(SignalSet, 2);
            obj.SignalProb = (1/obj.Order) * ones(1, obj.Order);
            if ( nargin>=2 && ~isempty(SignalProb) )
                if ( (sum(obj.SignalProb<=1) ~= obj.Order) || (sum(obj.SignalProb)~=1) )
                    error('Modulation:InvSignalProb', 'The 1-by-Order input vector SignalProb contains signal probabilities. Its components should be between 0 and 1 and it should sum to 1.');
                end
                obj.SignalProb = SignalProb;
            end
            NormalizationFactor = sum( obj.SignalProb' .* diag((SignalSet' * SignalSet)) );
            obj.SignalSet = SignalSet / sqrt(NormalizationFactor);
        end
    end    
end