% Common parameters
S = CreateConstellation( 'QAM', 16 );
EsNo = 2;
variance = 1/(2*EsNo);
data = round(rand(1,100));
noise = sqrt(variance)*( randn( 1,25 ) + sqrt(-1)*randn( 1,25 ) );

% start with old CML way (make sure ./cml is in the path)
s_scalar = Modulate( data, S );
r_scalar = s_scalar + noise;
log_likelihood_old = Demod2D( r_scalar, S, EsNo );
llr_old = Somap( log_likelihood_old, 4 );

% now the new way
S_vector = [real(S);imag(S)];
noise_vector = [real(noise);imag(noise)];
data_int = cast( data, 'uint8' );
symbols = Map( data_int, 4 );
s_vector = S_vector( :, symbols );
r_vector = s_vector + noise_vector;
log_likelihood_new = VectorDemod( r_vector, S_vector, EsNo );
llr_new = Demap( log_likelihood_new, 4 );

