function [minEsN0dB, minEbN0dB] = InversePbUB( SignalSet, Pb )
% InversePbUB finds the SNR required to achieve a required bit-error rate.
%    It operates by inverting the corresponding union bound.
%
%    Calling syntax:
%    [EsN0dB, EbN0dB] = InversePbUB( SignalSet [,Pb] )
%
%    where:
%        SignalSet is a K by M real-valued signal matrix.
%        Pb is the requred BER (optional argument; defaults to 1e-5).
%        EsN0dB is the Es/N0 value (in dB) for which the union bound equals Pb.
%        EbN0dB is the Eb/N0 value (in dB) for which the union bound equals Pb.

% If the second argument is missing or empty, use default value.
if ( nargin<2 || isempty(Pb) )
    Pb = 1e-5;
end

% determine the corresponding values of Es/N0 and Eb/N0.
PbF = @(EsN0) (PbUB( SignalSet, EsN0 ) - Pb);
minEsN0 = fzerotx(PbF, [0,10^(50/10)]);
minEsN0dB = 10*log10(minEsN0);
minEbN0 = minEsN0 / log2(size(SignalSet, 2));
minEbN0dB = 10*log10(minEbN0);