% gen_test_data.m
%
% create an example input structure for the code loaded by the test 

SimulationParam.nnums = 10;                                        % generate 10 uniform random variates
FunctionPath = '/rhome/tferrett/cml2/iscml/wvu_pcs/wc/gw/test/'; % path to entry function
FunctionName = 'test';                                               % entry function

input_struct.SimulationParam = SimulationParam; % load input struct
input_struct.FunctionPath = FunctionPath;
input_struct.FunctionName = FunctionName;

output_struct = '';

save('test_task_1.mat', 'input_struct', 'output_struct');
