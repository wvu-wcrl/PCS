function [minEsN0dB, minEbN0dB] = InversePsUB( SignalSet, Ps )
% InversePsUB finds the SNR required to achieve a required symbol-error rate.
%    It operates by inverting the corresponding union bound.
%
%    Calling syntax:
%    [EsN0dB, EbN0dB] = InversePsUB( SignalSet [,Ps] )
%
%    where:
%        SignalSet is a K by M real-valued signal matrix.
%        Ps is the requred SER (optional argument; defaults to 1e-5).
%        EsN0dB is the Es/N0 value (in dB) for which the union bound equals Ps.
%        EbN0dB is the Eb/N0 value (in dB) for which the union bound equals Ps.

% If the second argument is missing or empty, use default value.
if ( nargin<2 || isempty(Ps) )
    Ps = 1e-5;
end

% determine the corresponding values of Es/N0 and Eb/N0.
PsF = @(EsN0) (PsUB( SignalSet, EsN0 ) - Ps);
minEsN0 = fzerotx(PsF, [0,10^(50/10)]);
minEsN0dB = 10*log10(minEsN0);
minEbN0 = minEsN0 / log2(size(SignalSet, 2));
minEbN0dB = 10*log10(minEbN0);