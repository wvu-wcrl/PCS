function [BECLink, EpsilonDEThreshStar, EpsSimThresh, CodeRate, FullRank] = SimulateProject( HStruct, ResultFileName, ResumeFlag )
% Simulates the LDPC channel code specified by HStruct over binary erasure channel.
%
% Calling syntax: [BECLink, EpsilonThresholdStar, EpsSimThresh, CodeRate, FullRank] = ...
%                     SimulateProject( HStruct [,ResultFileName] [,ResumeFlag])
%
% Inputs
%       HStruct: A structure array corresponding to the parity-check matrix.
%                In particular, HStruct(j).loc_ones gives the location of the ones in the jth row of H matrix.
%       ResultFileName: OPTIONAL filename (Default 'BECSimResults_MMMDD_HHMM.mat') to frequently save simulation results in it AND
%                       to read two structures called "SimParam" and "SimState" from it IF ResumeFlag=1.
%                       It must be a string (enclosed in single quotes).
%       ResumeFlag:     OPTIONAL flag telling the simulator to read in two saved structures called "SimParam" and "SimState"
%                       from ResultFileName and resume the simulation.
% Output
%       BECLink:        Simulation object.
%       EpsilonDEThreshStar   Theoretical maximum channel erasure probability for the given parity-check matrix based on Density Evolution.
%       EpsSimThresh    Maximum channel erasure probability for the given parity-check matrix based on Monte-Carlo simulation.
%       CodeRate
%       FullRank        A flag which is either YES or NO depending on whether the parity-check matrix is full-rank or not.

% Default HStruct was defined as Rate-1/2 short (CodewordLength = 16200) DVBS2 LDPC code.
% if( nargin<1 || isempty(HStruct) )
%     % Create the H-matrix in HStruct format for DVBS2 standard LDPC code.
%     n = 16200;
%     rate = 1/2;  % actual rate is 4/9.
%     HStruct = HstructDVBS2( rate, n );
% end

if( nargin<3 || isempty(ResumeFlag) )
    ResumeFlag = 0; % Default is to not resume.
end

if ResumeFlag == 0
    if( nargin<2 || isempty(ResultFileName) )
        % ResultFileName = 'BECSimResults.mat';  % Default save file name.
        ResultFileName = ['BECSimResults_' datestr(clock,'mmmdd_HHMM') '.mat'];  % Default save file name.
    end
    % Create Simulation Parameters.
    SimParam = struct(...
        'Epsilon', [0.15:0.005:0.25], ...     % Row vector of channel erasure probabilities. (Original Default Value: [0.10:0.002:0.25])
        'MaxTrials', 1e6, ...       % Maximum number of trials to run per point. A vector of integers (or a scalar), one for each Epsilon point.
        ...                         % (Original Default Value: 0.25e5).
        'MaxFrameErrors', 1e3, ...	% Max number of frame errors. A vector of integers (or a scalar), one for each Epsilon point.
        'MaxIteration', 100, ...	% Maximum number of decoding iterations.
        'HStruct', HStruct, ...     % A structure array corresponding to the parity-check matrix.
        ...                         % H(j).loc_ones gives the location of ones in the jth row of H matrix.
        'FileName', ResultFileName, ...
        'MaxRunTime', 300, ...      % Maximum simulation time in Seconds.
        'CheckPeriod', 200 );       % Checking time in number of Trials.
    InitialTrials = 0;
    
elseif ResumeFlag == 1
    if( nargin<2 || isempty(ResultFileName) )
        fprintf('\nPlease specify the full name of a valid job file that you would like to resume its simulation.\n');
        ExistingJobFiles = dir('BECSimResults*.mat');
        if ~isempty(ExistingJobFiles)
            fprintf('\nThe following job files exist in the current directory:\n')
            for FileNum = 1:length(ExistingJobFiles)
                fprintf('%s\n', ExistingJobFiles(FileNum).name);
            end
        else
            fprintf('Example: BECSimResults_Apr13_0856.mat\n');
        end
        ResultFileName = input('\n','s');
    end
    if isempty( dir([ResultFileName '*']) )
        fprintf('\nThe job file %s that you have specified to resume its simulation does NOT exist.\n', ResultFileName);
        
        ExistingJobFiles = dir('BECSimResults*.mat');
        if ~isempty(ExistingJobFiles)
            fprintf('\nThe following job files exist in the current directory:\n')
            for FileNum = 1:length(ExistingJobFiles)
                fprintf('%s\n', ExistingJobFiles(FileNum).name);
            end
        end
        
        fprintf('\nPlease specify the full name of a valid job file that you would like to resume its simulation.');
        if isempty(ExistingJobFiles)
            fprintf('\nExample: BECSimResults_Apr13_0856.mat');
        end
        
        ResultFileName = input('\n\n','s');
    end
    FileContent = load(ResultFileName,'SimParam','SimState');
    SimParam = FileContent.SimParam;
    InitialTrials = sum(FileContent.SimState.Trials);
    fprintf('\n');
end

BECLink = BECLinkSimulation( SimParam );
BECLink.RunMode = 0;    % Running Mode: 0=Local, 1=Cluster.

if( ResumeFlag == 1 ), BECLink.SimStateInit(FileContent.SimState); end
BECLink.Save(); % Save the Object.

EpsilonDEThreshStar = BECLink.EpsilonThresholdStar;
fprintf('The maximum channel erasure probability for your given parity-check matrix is EpsilonStar = %.6f.\n',EpsilonDEThreshStar);
CodeRate = BECLink.CodeRate;
fprintf('The rate of your given code is CodeRate = %.4f.\n',CodeRate);
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
fprintf('\nThe largest value of Epsilon (channel erasure probability) for which the BER is less than 1e-2 after %d decoding iterations is \n%.6f.\n\n', ...
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