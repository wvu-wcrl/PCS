function ResumeCluster( ahfhRoot )
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
        start_ind = length( ['Worker' int2str(n) ] ) + 1;
        InputFileName = D(i).name( start_ind:end );
        
        % Move the file to the input directory
        system( ['mv ' RunningDir D(i).name ' ' InDir InputFileName] );
        system( ['chmod 666 ' InputFileName ] );
        
        % pause before continuing
        pause( PauseTime );
    end
end