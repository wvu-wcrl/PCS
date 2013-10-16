function Q = OrthonormalMatrix(obj, n, Seed)
Q = zeros(2*n, 2*n);

rand('twister',Seed);

u1 = rand(1,n);
for i = 1:n
    Theta = 2*pi*u1(i);
    % Generate 2x2 orthonormal matrix.
    A = [cos(Theta) sin(Theta); -sin(Theta) cos(Theta)];
    x = 2*i;
    % Required orthonormal matrix.
    Q(x-1:x, x-1:x) = A;
end
end