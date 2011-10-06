function ClusterTime( hosts )
% echoes the system time on each node of the cluster

% get the local hostname
command_string = ['hostname'];
[~,ThisHost] = system( command_string );

% get local time
command_string = ['date'];
[~,zz] = system( command_string );

fprintf( ' %s Returns: %s\n', ThisHost, zz );

for i=1:length( hosts )
    command_string = ['ssh ' hosts{i} ' date'];
    [~,zz] = system( command_string );
    
    fprintf( 'Node %s Returns: %s\n', hosts{i}, zz );
end

end

