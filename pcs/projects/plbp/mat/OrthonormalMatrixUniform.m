% function Q = OrthonormalMatrixUniform(n, Seed)
% rand('twister',Seed);
% u1 = rand(n,n);
% Q=orth(u1);
% end
function Q = OrthonormalMatrixUniform(n, Seed)
    stream = RandStream('mt19937ar','Seed',Seed);
    u1 = rand(stream,n,n);
    Q=orth(u1);
end