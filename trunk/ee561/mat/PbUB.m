function Pb = PbUB( SignalSet, EsN0 )
% EsN0 is in linear (Es = 1).

Tol = 1e-8;
% Normalize the signal set (should have already be done).
SignalEnergy = sum( abs(SignalSet).^2 );
EsAvg = mean( SignalEnergy );
if ( (EsAvg < 1-Tol) || (EsAvg > 1+Tol) )
    fprintf( 'Warning, signal set was not normalized.\n' );
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

% Calculate the Hamming distance between the elements of a vector of symbols.
Symbols = 0:NoSignals-1;
NoBits = ceil( log2(NoSignals) );    % The number of required bits to represent all Sybmols.

HammingDistanceT = zeros(NoSignals);
% Calculate the Hamming distance between each symbol and the rest of the symbols.
% Lower triangular part of HammingDistance is filled with the Hamming distances of symbols with each other. It is a symmetric matrix.
for k=1:NoSignals-1
    % Represent current symbol in binary format.
    CurrentSym = de2bi( Symbols(k), NoBits, [], 'left-msb' );
    % Represnt other symbols in binary format in each row of OtherSym.
    OtherSym = de2bi( Symbols(k+1:end), NoBits, [], 'left-msb' );
    BitDifference =  repmat(CurrentSym, [NoSignals-k 1]) ~= OtherSym;
    HammingDistanceT(k+1:end, k) = sum( BitDifference, 2 );
end
DL = tril(HammingDistanceT, -1);
HammingDistance = DL + DL.';

Pb = zeros(size(EsN0));
% Loop over the elements of EsN0.
for snrpoint = 1:length(EsN0)
    % Calculate Q function for upper triangular part.
    QValuesT = 0.5 * (1 - erf( sqrt(EsN0(snrpoint))*Distance / 2 ));

    % Use the symmetry to get the Q function valued for upper triangular part.
    QValuesUp = triu(QValuesT, 1);
    QValues = QValuesUp.' + QValuesUp;

    % Calculate conditional bit error bound.
    CondBitErrorBound = sum(HammingDistance .* QValues) / log2(NoSignals);

    % Calculate the union bound on average symbol error probability.
    Pb(snrpoint) = sum(CondBitErrorBound) / NoSignals;
end