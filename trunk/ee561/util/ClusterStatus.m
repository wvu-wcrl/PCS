function NumberWorkers = ClusterStatus( hosts, worker_name )
% checks the status of the cluster, giving the number of workers per host

% preallocate
NumberWorkers = zeros(1,length(hosts));

for i=1:length( hosts )
    command_string = ['ssh ' hosts{i} ' ps aux|grep -i ' worker_name];
    [~,zz] = system( command_string );
    hits = findstr( zz, woerker_name );
    NumberWorkers( i ) = length( hits );
end

end

