function P = RandomPermutationMatrix(obj, n, Seed)
N = 2*n;
P = eye( N );

rand('twister', Seed)

idx = randperm(N);
P = P(idx, :);
end