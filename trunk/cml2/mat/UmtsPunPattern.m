function [PuncturePattern, TailPuncPattern] = UmtsPunPattern( DataLength, CodewordLength )

N = 3*DataLength + 12;
X_i = N/3;

% This is the combined PuncturePattern and TailPuncPattern.
TotalPattern = zeros(3,X_i);

% Do not puncture the systematic part of the codewords.
TotalPattern(1,:) = ones(1,X_i);

% Set up parameters:
delta_N = CodewordLength - N;
e_ini = X_i;

% Puncture first parity stream.
e_plus = 2*X_i;
e_minus = 2*abs( floor( delta_N/2 ) );
Parity_1 = RateMatch( 1:X_i, X_i, e_ini, e_plus, e_minus );
TotalPattern(2,Parity_1) = ones( size(Parity_1) );

% Puncture second parity stream.
e_plus = X_i;
e_minus = abs( ceil( delta_N/2 ) );
Parity_2 = RateMatch( 1:X_i, X_i, e_ini, e_plus, e_minus );
TotalPattern(3,Parity_2) = ones( size(Parity_2) );

% Bit collection:
PuncturePattern(1,:) = ones(1,DataLength);
PuncturePattern(2,:) = TotalPattern(2,1:DataLength);
PuncturePattern(3,:) = zeros(1,DataLength);
PuncturePattern(4,:) = TotalPattern(3,1:DataLength);

TailPuncPattern = reshape( TotalPattern(:,DataLength+1:X_i), 4, 3 );