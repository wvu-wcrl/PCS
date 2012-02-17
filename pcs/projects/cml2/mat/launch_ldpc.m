% launch_ldpc.m
%
% function to launch the ldpc_dvbs2 simulation via the cluster task controller.

function SimState = launch_ldpc(DVBS2Param)

cd('/rhome/pcs/cml2/iscml/cml2');
CmlStartup;

SimState = TestLDPC_DVBS2(DVBS2Param);

end