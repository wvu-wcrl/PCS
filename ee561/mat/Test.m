MM = CreateModulation([-1 1]);
C = AWGN( MM, 20 );
D = UncodedModulation(2, 4);

M = Encode(D, [0 0 1 1])
SymbolLikelihood = ChannelUse(C, M)
EstBits = Decode(D, SymbolLikelihood)