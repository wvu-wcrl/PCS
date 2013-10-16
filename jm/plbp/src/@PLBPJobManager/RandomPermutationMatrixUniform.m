function P = RandomPermutationMatrixUniform(N, Seed)
P = eye( N );
rand('twister', Seed);
idx = randperm(N);
P = P(idx, :);
end