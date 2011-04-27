clear

%set the parameters
alpha = 3;
radius = 30;
m = 3;
M = 50;
N = 20;

% create N random networks
for i=1:N
    a=Network(1,pi*radius^2,0.1,alpha,0.001,100,0.7,2,M);
    Xi=a.Placement;
    Omega(i,:) = abs(Xi).^-alpha;
end

% save this into the "tables" directory
OmegaFileName = 'Omega_N20_M50_r30.mat';
save( OmegaFileName, 'Omega' )

% create the Param structure
JobParam.m_i = 3*ones(1,50);
JobParam.m = m;
JobParam.Gamma = 10*log(1:10);
JobParam.Beta = [0.1 1 10];
JobParam.p = [1 0.1 0.01 0.001];
JobParam.OmegaFileName = OmegaFileName;

% save the structure in the "input" directory
save( 'Test1.mat', 'JobParam' );
