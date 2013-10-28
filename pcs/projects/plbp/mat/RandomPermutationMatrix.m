% function P = RandomPermutationMatrix(n, Seed)
% N = 2*n;
% P = eye( N );
% 
% rand('twister', Seed)
% 
% idx = randperm(N);
% P = P(idx, :);
% end
function P = RandomPermutationMatrix(n, seed)
    N = 2*n;
    P = eye( N );
    stream = RandStream('mt19937ar','Seed',seed);
    idx = randperm(stream,N);
    P = P(idx, :);
end