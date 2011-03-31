function [minEsN0dB, minEbN0dB] = minEsN0PBit( SignalSet, maxPb )
% minEsN0PBit finds the minimum EsN0 (in dB) that is required to achieve bit error probability of  maxPb (Default maxPb = 1e-5).
% Calling Syntax: [minEsN0dB, minEbN0dB] = minEsN0PBit( SignalSet [,maxPb] )

if ( nargin<2 || isempty(maxPb) )
    maxPb = 1e-5;
end
% syms EsN0;
% Pb = PbUB( SignalSet, EsN0 );
% minEsN0 = double( solve(Pb - maxPb) );
% minEsN0dB = 10*log10(minEsN0);
% clear EsN0;

PbF = @(EsN0) (PbUB( SignalSet, EsN0 ) - maxPb);
minEsN0 = fzerotx(PbF, [0,10^(50/10)]);
minEsN0dB = 10*log10(minEsN0);
minEbN0 = minEsN0 / log2(size(SignalSet, 2));
minEbN0dB = 10*log10(minEbN0);