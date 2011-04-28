% refresh
clear;
LocalStartup; % assuming you are in the root ahfh directory

% the root directory (be sure to run LocalStartup)
ahfhRoot = cml_home;

% set the parameters
m = 3;
M = 50;
m_i = 3;  % should be constant for all interferers (for now)

% Create an object
load( [ahfhRoot '/tables/Omega_N20_M50_r30.mat'] )

% The object needs to be called this
b = OutageNakagami( Omega, m, m_i );

% The name of where an example OutageNakagami object is stored
% Previously we called this OmegaFileName
% We use an OutageNakagami object to store m, m_i, and Omega 
NetworkFileName = 'Network1.mat';

% save b
save( [ahfhRoot '/tables/' NetworkFileName ]. 'b' );

SNRdB = [10 20];

% Create the Param structure
JobParam.m_i = 3*ones(1,M);
JobParam.m = m;
JobParam.Gamma = 10.^(SNRdB/10);
JobParam.Beta = [0.1 1 10];
JobParam.p = [1 0.1 0.01 0.001];
JobParam.NetworkFileName = NetworkFileName;

% Test multiple jobs
NumberJobs = 3;

% Create an array of JobManager Objects
for job=1:NumberJobs
  
    JobFileName = ['Job' int2str(job) '.mat'];
    
    % Create a JobController object
    % In practice, should have a different JobParam set for each job
    a(job) = JobManager( JobParam, JobFileName, ahfhRoot );
    
end

% Submit the jobs
for job=1:NumberJobs    
    % Submit the job
    a(job).SubmitJob( );
end

% to check status use:
a(job).GetStatus( );

% to get results, use:
epsilon{job} = a(job).GetResults( );




