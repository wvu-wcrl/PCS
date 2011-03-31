
function Ps = PsUB( SignalSet, EsN0 )

% normalize the signal set (should already be done)
SignalEnergy = sum( abs(SignalSet).^2 );
EsAvg = mean( SignalEnergy );
if (EsAvg ~= 1)
    fprintf( 'warning, signal set was not normalized\n' );
    SignalSet = SignalSet / sqrt(EsAvg);
end

NoSignals = size( SignalSet, 2);    % Determine the number of signals.
Distance = zeros( NoSignals );

% Calculate the distance between each signal and the rest of the signals.
% Upper triangular part of Distance has the distances of signals with each other. It is a symmetric matrix.
for m = 1:NoSignals-1
    SignalDifference = repmat(SignalSet(:,m), [1 NoSignals-m]) - SignalSet(:, m+1:end);
    Distance(m, m+1:end) = sqrt( sum( abs(SignalDifference).^2 ) );     % Sum over columns of matrix.
end

% loop over the elements of EsNo
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
