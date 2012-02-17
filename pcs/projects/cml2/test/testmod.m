% Common parameters
EsN0 = 2;
variance = 1/(2*EsN0);

data = round(rand(1,20));
data_int = cast( data, 'uint8' );
noise = sqrt(variance)*( randn( 1,5 ) + sqrt(-1)*randn( 1,5 ) );
noise_vector = [real(noise);imag(noise)];
% noise = sqrt(variance)*( randn( 1,10 ) );
% noise_vector = [real(noise)];

% start with old CML way (make sure ./cml is in the path)
S = CreateConstellation( 'APSK', 16 );
s_scalar = Modulate( data, S )
r_scalar = s_scalar + noise;
log_likelihood_old = Demod2D( r_scalar, S, EsN0 );
% s_scalar = Modulate( data, [2 3*i -3 -2*i] )
% log_likelihood_old = Demod2D( r_scalar, [2 3*i -3 -2*i], EsN0 );
llr_old = Somap( log_likelihood_old, 0 )

% now the new CML2 way
% A=CustomMod([2,0,-3,0;0,3,0,-2], [1,3,2,0]);
A=APSK(16);
s_vector = A.Modulate(data_int)
% S_vector = [real(S);imag(S)];
% symbols = Map( data_int, 4 );
% s_vector = S_vector( :, symbols );
r_vector = s_vector + noise_vector;
% log_likelihood_new = VectorDemod( r_vector, S_vector, EsNo );
% llr_new = Demap( log_likelihood_new, 4 );
llr_new = A.Demodulate( r_vector, EsN0 )