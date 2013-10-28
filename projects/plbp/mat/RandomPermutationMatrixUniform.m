% function P = RandomPermutationMatrixUniform(N, Seed)
% P = eye( N );
% rand('twister', Seed);
% idx = randperm(N);
% P = P(idx, :);
% end

function P = RandomPermutationMatrixUniform(n, Seed)
    N = n;
    P = eye( N );
    stream = RandStream('mt19937ar','Seed',Seed);
    idx = randperm(stream,N);
    P = P(idx, :);
end