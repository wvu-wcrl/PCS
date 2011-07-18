function ClusterResume( ahfhRoot )
% Resumes the cluster by moving files in /running to /input

% build directories
InDir = [ahfhRoot '/input/' ];
RunningDir = [ahfhRoot '/running/' ];

% look to see if there is a file for this worker in the Running Directory
D = dir( [RunningDir 'Worker*.mat'] );

PauseTime = 1;

if ~isempty(D)   
    for i=1:length(D)
        % Strip worker out of the name
        period_locs = findstr( D(i).name, '.' );  % location of periods
        start_ind = period_locs(1) + 1;
        InputFileName = D(i).name( start_ind:end );
        
        % Move the file to the input directory
        system( ['mv ' RunningDir D(i).name ' ' InDir InputFileName] );
        system( ['chmod 666 ' InputFileName ] );
        
        % pause before continuing
        pause( PauseTime );
    end
end