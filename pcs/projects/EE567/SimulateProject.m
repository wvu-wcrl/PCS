function [BECLink, EpsilonThresholdStar, EpsSimThresh, CodeRate, FullRank] = SimulateProject( HStruct, ResultFileName, ResumeFlag )
% Simulates the channel code specified by HStruct over binary erasure channel.
%
% Calling syntax: BECLink = SimulateProject( [HStruct] [,ResultFileName] [,ResumeFlag])
%
% Inputs
%       HStruct: A structure array corresponding to the parity-check matrix.
%                In particular, HStruct(j).loc_ones gives the location of the ones in the jth row of H matrix.
%                Default: Rate-1/2 short (CodewordLength = 16200) DVBS2 LDPC code.
%       ResultFileName: Optional filename (Default 'BECSimResults.mat') to frequently save simulation results in it AND
%                       to read two structures called "SimParam" and "SimState" from it IF ResumeFlag=1.
%                       It must be a string (enclosed in single quotes).
%       ResumeFlag:     Optional flag telling the simulator to read in two saved structures called "SimParam" and "SimState"
%                       from ResultFileName and resume the simulation.
% Output
%       BECLink:        Simulation object.

% if( nargin<1 || isempty(HStruct) )
%     % Create the H-matrix in HStruct format for DVBS2 standard LDPC code.
%     n = 16200;
%     rate = 1/2;  % actually rate 4/9.
%     HStruct = HstructDVBS2( rate, n );
% end

if( nargin<2 || isempty(ResultFileName) )
    ResultFileName = 'BECSimResults.mat';  % Default save file name.
end

if( nargin<3 || isempty(ResumeFlag) )
    ResumeFlag = 0; % Default is to not resume.
end

if( ResumeFlag == 0 )
    % Create Simulation Parameters.
    SimParam = struct(...
        'Epsilon', [0.15:0.005:0.25], ...     % Row vector of channel erasure probabilities. ([0.10:0.002:0.25])
        'MaxTrials', 1e6, ...       % Maximum number of trials to run per point. A vector of integers (or a scalar), one for each Epsilon point. (0.25e5)
        'MaxFrameErrors', 1e3, ...	% Max number of frame errors. A vector of integers (or a scalar), one for each Epsilon point.
        'MaxIteration', 100, ...	% Maximum number of decoding iterations.
        'HStruct', HStruct, ...     % A structure array corresponding to the parity-check matrix.
        ...                         % H(j).loc_ones gives the location of ones in the jth row of H matrix.
        'FileName', ResultFileName, ...
        'MaxRunTime', 300, ...      % Maximum simulation time in Seconds.
        'CheckPeriod', 60 );        % Checking time in number of Trials.
    InitialTrials = 0;
elseif( ResumeFlag == 1 )
    FileContent = load(ResultFileName,'SimState','SimParam');
    SimParam = FileContent.SimParam;
    InitialTrials = sum(FileContent.SimState.Trials);
end

BECLink = BECLinkSimulation( SimParam );
BECLink.RunMode = 0;    % Running Mode: 0=Local, 1=Cluster.

if( ResumeFlag == 1 ), BECLink.SimStateInit(FileContent.SimState); end
BECLink.Save(); % Save the Object.

fprintf('The maximum channel erasure probability for your given parity-check matrix is EpsilonStar = %.4f.\n',BECLink.EpsilonThresholdStar);
EpsilonThresholdStar = BECLink.EpsilonThresholdStar;
fprintf('The rate of your given code is CodeRate = %.4f.\n',BECLink.CodeRate);
CodeRate = BECLink.CodeRate;
if BECLink.FullRank == 1
    fprintf('Your given parity-check matrix IS FULL-RANK! The simulation will continue.\n\n');
    FullRank = 'Yes';
else
    fprintf('Your given parity-check matrix IS NOT FULL-RANK! The simulation is terminated.\nYou have to specify another FULL-RANK H matrix.\n');
    FullRank = 'NO';
    return;
end

GlobalRunTime = tic;
WorkUnit = 0;

while(  sum( ( BECLink.SimState.Trials < BECLink.SimParam.MaxTrials ) & ...
        ( BECLink.SimState.FrameErrors(end,:) < BECLink.SimParam.MaxFrameErrors ) ) )
    WorkUnit = WorkUnit + 1;
    fprintf('****************************\nProcessing WORK UNIT %d.\n****************************\n', WorkUnit);
    % Execute this work unit.
    CurrentSimState = BECLink.SingleSimulate();

    % Determine and echo simulation progress.
    CompletedTrials = DetermineProgress(SimParam, CurrentSimState);
end

RunDuration = toc(GlobalRunTime);
fprintf( '\n\nSimulation is COMPLETE.\nIt took %.4f seconds at a rate of %.4f trials/second.\n', RunDuration, (CompletedTrials-InitialTrials)/RunDuration );

% Determine the largest value of Epsilon for which the BER is less than 10^-2 after MaxIteration decoding iterations.
EpsSimThresh = BECLink.SimParam.Epsilon( find( BECLink.SimState.BER(end,:) < 1e-2, 1, 'last' ) );
fprintf('\nThe largest value of Epsilon (channel erasure probability) for which the BER is less than 1e-2 after %d decoding iterations is \n%.5f.\n\n', ...
    BECLink.SimState.MaxIteration, EpsSimThresh);
end


function CompletedTrials = DetermineProgress(SimParam, SimState)
% Determine and echo simulation progress.

% Determine the number of remaining frame errors reqiured for each Epsilon point.
RemainingFrameError = SimParam.MaxFrameErrors - SimState.FrameErrors(end,:);
RemainingFrameError(RemainingFrameError<0) = 0;
% Determine the number of remaining trials reqiured for each Epsilon point.
RemainingTrials = SimParam.MaxTrials - SimState.Trials;
RemainingTrials(RemainingTrials<0) = 0;
% Determine the position of active Epsilon points based on the number of remaining frame errors and trials.
ActiveEpsilonPoints = ( (RemainingFrameError>0) & (RemainingTrials>0) );

RequiredTrials = sum( (ActiveEpsilonPoints).*RemainingTrials + SimState.Trials );
CompletedTrials = sum( SimState.Trials );

fprintf( '\nProgress Update: %d Trials Completed, %d Trials Remain, %2.4f%% Complete.\n', ...
    CompletedTrials, RequiredTrials-CompletedTrials, 100*CompletedTrials/RequiredTrials );
end