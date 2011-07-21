function NumberWorkers = ClusterTime( hosts )
% echoes the system time on each node of the cluster

% preallocate
NumberWorkers = zeros(1,length(hosts));

for i=1:length( hosts )
    command_string = ['ssh ' hosts{i} ' date'];
    [~,zz] = system( command_string )
end

end

