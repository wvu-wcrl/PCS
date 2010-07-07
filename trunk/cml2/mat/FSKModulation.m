classdef FSKModulation < Modulation
 
    properties
        % In this case, MappingType could be one of the following options:
        % 'gray', 'reversegray'(Order=8,16), 'mv'(Order=8,16), 'dt'(Order=8,16), for ALL {'gray2','gray3','gray4','gray5','gray6'} Order is 8
        h=1         % FSK modulation index (Default h=1, i.e. Orthogonal FSK)
        
        DemodFSK=0  % Demodulater type ONLY for 'FSK' demodulator
                    % =0 For coherent reception (DEFAULT)
                    % =1 For noncoherent reception with perfect amplitude estimates
                    % =2 For noncoherent reception without amplitude estimates
    end
    
    methods
        
        % Class constructor: obj = FSKModulation([Order] [,MappingType] [,h])
        function obj = FSKModulation(varargin)
            
            if (length(varargin)>=1)
                Order = varargin{1};
            else
                Order=2;
            end
            
            if (length(varargin)>=2)
                MappingType = varargin{2};
                if ~ischar(MappingType)
                    if (length(MappingType) ~= Order)
                        error('Length of MappingType must be EQUALL to the Order of modulation.');
                    elseif (sum( sort(MappingType) ~= [0:Order-1] ) > 0)
                        error( 'MappingType must contain integers 0 through Order-1.' );
                    end
                end
            else
                MappingType = 'gray';
            end
            
            obj@Modulation('FSK', Order, MappingType);
            
            if (length(varargin)>=3)
                obj.h = varargin{3};
            else
                obj.h=1;
            end
            
            [Constellation, obj.MappingVector] = CreateConstellation('FSK', obj.Order, obj.MappingType, obj.h);
            obj.SignalSet=[real(Constellation); imag(Constellation)];
        end
        
        
        % Demodulate Method: BitLikelihood=Demodulate(RecievedSignal [,EsN0], [,FadingCoef] [DemodFSK])
        function BitLikelihood=Demodulate(obj, RecievedSignal, varargin)
            obj.RecievedSignal=RecievedSignal;
            if (length(varargin)>=1)
                    obj.EsN0 = varargin{1};
                    if (length(varargin)>=2)
                        obj.FadingCoef=varargin{2};
                    elseif (strcmpi(obj.FadingCoef, 'UnDef'))
                        obj.FadingCoef=ones(1,length(obj.RecievedSignal)); % Fading Coefficients for AWGN Channel
                    end
            elseif (obj.EsN0<0)
                error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified.');
            elseif (strcmpi(obj.FadingCoef, 'UnDef'))
                obj.FadingCoef=ones(1,length(obj.RecievedSignal)); % Fading Coefficients for AWGN Channel
            end
            
            if (length(varargin)>=3)
                obj.DemodFSK=varargin{3};
            end
            
            obj.SymbolLikelihood = DemodFSK(obj.RecievedSignal, obj.EsN0, obj.DemodFSK, obj.FadingCoef);
            
            BitLikelihood = Somap(obj.SymbolLikelihood, obj.DemodType); % Extrinsic information is considered to be all zero (DEFAULT).
            
            obj.BitLikelihood=BitLikelihood;
        end
    end
    
end