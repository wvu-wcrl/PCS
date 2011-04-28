ClusterStartup
cwc_obj = cwc(cml_home, 'test.cfg', 'outage_worker');
cwc_obj.cSta()

% check on the status
for i=1:length( cwc_obj.nodes )
    command_string = ['ssh ' cwc_obj.nodes{i} ' ps aux|grep -i outage_worker'];
    [~,zz] = system( command_string );
    fprintf( 'Node %s\n', cwc_obj.nodes{i} );
    fprintf( '%s\n', zz );
end