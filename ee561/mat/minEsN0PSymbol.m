function [minEsN0dB, minEbN0dB] = minEsN0PSymbol( SignalSet, maxPs )
% minEsN0PSymbol finds the minimum EsN0 (in dB) that is required to achieve symbol error probability of  maxPs (Default maxPs = 1e-5).
% Calling Syntax: [minEsN0dB, minEbN0dB] = minEsN0PSymbol( SignalSet [,maxPs] )

if ( nargin<2 || isempty(maxPs) )
    maxPs = 1e-5;
end
% syms EsN0;
% Ps = PsUB( SignalSet, EsN0 );
% minEsN0 = double( solve(Ps - maxPs) );
% minEsN0dB = 10*log10(minEsN0);
% clear EsN0;

PsF = @(EsN0) (PsUB( SignalSet, EsN0 ) - maxPs);
minEsN0 = fzerotx(PsF, [0,10^(50/10)]);
minEsN0dB = 10*log10(minEsN0);
minEbN0 = minEsN0 / log2(size(SignalSet, 2));
minEbN0dB = 10*log10(minEbN0);