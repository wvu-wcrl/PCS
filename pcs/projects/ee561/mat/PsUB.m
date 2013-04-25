function Ps = PsUB( SignalSet, EsN0 )
% PsUB computes the union bound on symbol-error probability over an AWGN channel.
%
%    Calling syntax:
%    Ps = PsUB( SignalSet, EsN0 )
%
%    where:
%        SignalSet is a K by M real-valued signal matrix.
%        EsN0 is a vector of SNR points (in linear, not dB, units).
%        Ps is the upper/union bound on symbol-error rate.
%
%    notes:
%        The SignalSet provided as an input should be normalized to unit
%        energy. However, if it is not normalized, the program will
%        normalize it and flag a warning.

% Tolerance used to determine if the signal is normalized.
Tol = 1e-7;

% Check to see if SignalSet is normalized. If it is not, then normalize it.
SignalEnergy = sum( abs(SignalSet).^2 );
EsAvg = mean( SignalEnergy );
if ( (EsAvg < 1-Tol) || (EsAvg > 1+Tol) )
    fprintf( 'Warning, signal set was not normalized.\n' );
    SignalSet = SignalSet / sqrt(EsAvg);
end

NoSignals = size( SignalSet, 2);    % Determine the number of signals.
Distance = zeros( NoSignals );      % Euclidian distance betweeen signals.

% Calculate the distance between each signal and the rest of the signals.
% Upper triangular part of Distance has the distances of signals with each other. It is a symmetric matrix.
for m = 1:NoSignals-1
    SignalDifference = repmat(SignalSet(:,m), [1 NoSignals-m]) - SignalSet(:, m+1:end);
    Distance(m, m+1:end) = sqrt( sum( abs(SignalDifference).^2 ) );     % Sum over columns of matrix.
end

Ps = zeros(size(EsN0));
% Loop over the elements of EsN0.
for snrpoint = 1:length(EsN0)
    
    % Calculate Q function for upper triangular part.
    QValuesT = 0.5 * (1 - erf( sqrt( EsN0(snrpoint) )*Distance / 2 ));
    
    % Use the symmetry to get the Q function valued for upper triangular part.
    QValuesUp = triu(QValuesT, 1);
    QValues = QValuesUp.' + QValuesUp;
    
    % Calculate conditional symbol error bound.
    CondSymbolErrorBound = sum(QValues);
    
    % Calculate the union bound on average symbol error probability.
    Ps(snrpoint) = sum(CondSymbolErrorBound) / NoSignals;
end