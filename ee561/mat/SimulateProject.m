function LinkObjGlobal = SimulateProject( S, varargin)
% Simulates the matrix S
%
% Usage: LinkObjGlobal = SimulateProject( S, [FileName], ['resume'] )
%
% Where S is the K by M signal matrix
%       FileName is an optional filename (default is 'SimResult.mat').  Must be a string (enclosed in single quotes).
%       'resume' is a flag telling the simulator to read in saved values from the File and resume the simulation.

epsilon = 1e-3; % a small number used for SNR checking.

if (nargin > 1)
    % first optional argument is the filename
    FileName = varargin{1};
else
    FileName = 'SimResult.mat';
end

if (nargin > 2)
    % second optional argument is the resume flag
    ResumeStr = varargin{2};
    resume = strcmpi( ResumeStr, 'resume' );
else
    resume = 0;
end

% determine the size of the signal constellation
[K,M] = size( S );

% create a modulation object with equally-likely symbols
SymbolProb = ones(1,M);
ModObj = CreateModulation( S, SymbolProb );

% create channel object @ 0 dB (SNR = 1)
ChannelObj = AWGN( ModObj, 1 );

% create CM obj
BlockLength = 1000;  % number of symbols per block.
CodedModObj = UncodedModulation( M, SymbolProb, BlockLength );

% Deterine the SNR vector
FirstSNR = InversePsUB( S, 1 );
LastSNR = InversePsUB( S, 1e-6 );
SNRperdB = 2;
SNRdB = 1/SNRperdB*[ round( SNRperdB*FirstSNR):ceil( SNRperdB*LastSNR) ];
SNRdB = [10 SNRdB];

% Create Simulation Parameters
SimParamGlobal = struct(...
    'CodedModObj', CodedModObj, ...    % Coded modulation object.
    'ChannelObj', ChannelObj, ...     % Channel object (Modulation is a property of channel).
    'SNRType', 'Es/N0 in dB', ...
    'SNR', SNRdB, ...            % Row vector of SNR points in dB.
    'MaxTrials', 15000*ones( size(SNRdB) ), ...      % A vector of integers (or scalar), one for each SNR point. Maximum number of trials to run per point.
    'FileName', FileName, ...
    'SimTime', 30, ...       % Simulation time in Seconds.
    'CheckPeriod', 5, ...    % Checking time in number of Trials.
    'MaxBitErrors', 1000*ones( size(SNRdB) ), ...
    'MaxSymErrors', 150*ones( size(SNRdB) ), ...
    'minBER', 1e-5, ...
    'minSER', 1e-5 );

% Create the Link Object
LinkObjGlobal = LinkSimulation(SimParamGlobal);

% Load the Object if it was previously saved and resume flag set; otherwise save it
if resume
    % danger: File must exist and needs to have exactly the same size SNR vector
    load( FileName );     
    InitialTrials = sum( SimState.Trials );
    
    % determine if saved and new SNR points match
    ChangedSNR = 0;
    if ( length( SimParam.SNR ) ~= length( SimParamGlobal.SNR ) )
        ChangedSNR = 1;
    elseif sum( abs( SimParam.SNR - SimParamGlobal.SNR ) > epsilon )
        ChangedSNR = 1;
    end
    
    if ChangedSNR
        fprintf( '  SNR vector does not matched saved vector\n' );
        
        % restore saved state, one element at a time
        NumberSNRPoints = length( SimParamGlobal.SNR );
        
        for j=1:NumberSNRPoints
            % See if this point exists
            index = find( abs( SimParam.SNR  - SimParamGlobal.SNR(j) ) <=  epsilon); 
            if (length( index ) > 1)
                error( 'Duplicate SNR points in saved sim' );
            elseif (length(index) == 1)
                % update each element of SimParam
                LinkObjGlobal.SimState.Trials(j) = SimState.Trials(index);
                LinkObjGlobal.SimState.SymbolErrors(j) = SimState.SymbolErrors(index);
                LinkObjGlobal.SimState.BitErrors(j) = SimState.BitErrors(index);
                LinkObjGlobal.SimState.BER(j) = SimState.BER(index);
                LinkObjGlobal.SimState.SER(j) = SimState.SER(index);
            end
        end

    else
        % simply set it to the stored value
        LinkObjGlobal.SimState = SimState; 
    end
    
else
    % Save the Object
    LinkObjGlobal.Save();
    InitialTrials = 0;
end

% Create a Local Sim Param Structure
SimParamLocal = SimParamGlobal;
SimParamLocal.FileName = 'temp.mat'; % a dummy save file

% start a timer
stime = tic;

for (pass=1:1e2)
    fprintf( 'Processing work unit %d\n', pass );
    
    % Determine how many trials and errors remain: Assign these to the "local" SimParam structure
    SimParamLocal.MaxTrials    = LinkObjGlobal.SimParam.MaxTrials    - LinkObjGlobal.SimState.Trials;
    SimParamLocal.MaxSymErrors = LinkObjGlobal.SimParam.MaxSymErrors - LinkObjGlobal.SimState.SymbolErrors;
    SimParamLocal.MaxBitErrors = LinkObjGlobal.SimParam.MaxBitErrors - LinkObjGlobal.SimState.BitErrors;    
  
    % Construct the LinkObj with the Local SimParam
    LinkObjLocal = LinkSimulation(SimParamLocal);
    
    % Execute this work unit
    LinkObjLocal.SingleSimulate();
    
    % Update the global SimParam structure
    LinkObjGlobal.SimState.Trials           = LinkObjGlobal.SimState.Trials       + LinkObjLocal.SimState.Trials;
    LinkObjGlobal.SimState.BitErrors        = LinkObjGlobal.SimState.BitErrors    + LinkObjLocal.SimState.BitErrors;
    LinkObjGlobal.SimState.SymbolErrors     = LinkObjGlobal.SimState.SymbolErrors + LinkObjLocal.SimState.SymbolErrors;
    LinkObjGlobal.SimState.BER = LinkObjGlobal.SimState.BitErrors    ./ ( LinkObjGlobal.SimState.Trials * LinkObjGlobal.SimParam.CodedModObj.DataLength  );
    LinkObjGlobal.SimState.SER = LinkObjGlobal.SimState.SymbolErrors ./ ( LinkObjGlobal.SimState.Trials * LinkObjGlobal.SimParam.CodedModObj.BlockLength );
    
    % Save the global structure
    LinkObjGlobal.Save();
    
    % See if the global stopping criteria have been reached
    % first criteria = enough trials
    RemainingTrials = LinkObjGlobal.SimParam.MaxTrials - LinkObjGlobal.SimState.Trials;
    RemainingTrials(RemainingTrials<0) = 0; % force to zero if negative 
    criteria(1) = ~sum( RemainingTrials );
    
    % second criteria = enough symbol errors
    RemainingSymError = LinkObjGlobal.SimParam.MaxSymErrors - LinkObjGlobal.SimState.SymbolErrors;
    RemainingSymError(RemainingSymError<0) = 0;  % force to zero if negative   
    criteria(2) = ~sum( RemainingSymError );
    
    % third criteria = enough bit errors
    RemainingBitError = LinkObjGlobal.SimParam.MaxBitErrors - LinkObjGlobal.SimState.BitErrors;
    RemainingBitError(RemainingBitError<0) = 0;  % force to zero if negative   
    criteria(3) = ~sum( RemainingBitError );

    % fourth criteria = the minBER or minSER is reached
    
    % Determine the position of active SNR points based on the number of remaining symbol errors and trials.
    ActiveSNRPoints = ( (RemainingSymError>0) & (RemainingTrials>0) );
    
    % Check if we can discard SNR points whose BER WILL be less than SimParam.minBER.
    LastInactivePoint = find(ActiveSNRPoints == 0, 1, 'last');

    if ( ~isempty(LastInactivePoint) && ...
            (LinkObjGlobal.SimState.BER(1, LastInactivePoint) ~=0) && (LinkObjGlobal.SimState.BER(1, LastInactivePoint) < LinkObjGlobal.SimParam.minBER) && ...
            (LinkObjGlobal.SimState.SER(1, LastInactivePoint) ~=0) && (LinkObjGlobal.SimState.SER(1, LastInactivePoint) < LinkObjGlobal.SimParam.minSER) )
        fprintf( '  Ending simulation because the error rate curve is below the required threshold\n' );
        criteria(4) = 1;
    end
    
    % determine progress
    RequiredTrials = sum( (ActiveSNRPoints==1).*RemainingTrials + (ActiveSNRPoints == 0).*LinkObjGlobal.SimState.Trials );
    CompletedTrials = sum( LinkObjGlobal.SimState.Trials );
    
    fprintf( '  Progress update: %d trials completed, %d trials remain, %2.4f percent complete\n', CompletedTrials, RequiredTrials, 100*CompletedTrials/RequiredTrials );
       
    % halt if any criteria is reached
    if sum( criteria )
        break;
    end

end

duration = toc( stime );
fprintf( 'Simulation complete.  Took %f seconds at a rate of %f trials/second\n', duration, (CompletedTrials-InitialTrials)/duration );