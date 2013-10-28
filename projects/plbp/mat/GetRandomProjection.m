function [JobParam] = GetRandomProjection(JobParam, Key)

    JobParam.R = 2;
    JobParam.P = 4;
    Mappingtype = 'u2';
    JobParam.Mapping = Getmapping(JobParam.P, Mappingtype);
    Seed = sum(double(Key));
    if strcmpi(Mappingtype,'riu2')
        n = (JobParam.P + 2)/2;
        % Orthonormal matrix
        Q = OrthonormalMatrix(n, Seed);
        
        % RandomPermutation matrix
        % Seed = prod(double(JobParam.Key));
        P1 = RandomPermutationMatrix(n, Seed);
        
        % Blinding vector
        JobParam.N = 2*n;
        stream = RandStream('mt19937ar','Seed',Seed);
        JobParam.B = rand(stream,JobParam.N,1);
                
        % Orthonormal matrix and RandomPermutation matrix
        JobParam.RandomProjection = Q*P1; 
    elseif strcmpi(Mappingtype,'u2')
        n = (JobParam.P * (JobParam.P - 1)) + 3;
        % Orthonormal matrix
        Q = OrthonormalMatrixUniform(n, Seed);
                
        % RandomPermutation matrix
        % Seed = prod(double(JobParam.Key));
        P1 = RandomPermutationMatrixUniform(n, Seed);
   
        % Blinding vector
        JobParam.N = n;
        stream = RandStream('mt19937ar','Seed',Seed);
        JobParam.B = rand(stream,JobParam.N,1);
                
        % Orthonormal matrix and RandomPermutation matrix
        JobParam.RandomProjection = Q*P1;
    end
end