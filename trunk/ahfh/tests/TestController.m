% refresh
clear;
LocalStartup; % assuming you are in the root ahfh directory

% the root directory (be sure to run LocalStartup)
ahfhRoot = cml_home;

% set the parameters
m = 3;
M = 50;

% The file where the network coefficients "Omega" are stored.
OmegaFileName = 'Omega_N20_M50_r30.mat';

% Create the Param structure
JobParam.m_i = 3*ones(1,M);
JobParam.m = m;
JobParam.Gamma = 10*log(1:10);
JobParam.Beta = [0.1 1 10];
JobParam.p = [1 0.1 0.01 0.001];
JobParam.OmegaFileName = OmegaFileName;

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




