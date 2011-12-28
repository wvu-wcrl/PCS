% gen_test_data.m
%
% create an example input structure for the code loaded by the test 

fcn_param.nnums = 10;                                        % generate 10 uniform random variates
fcn_path = '/home/tferrett/cml2/iscml/wvu_pcs/wc/gw/test/'; % path to entry function
fcn = 'test';                                               % entry function

input_struct.fcn_param = fcn_param; % load input struct
input_struct.fcn_path = fcn_path;
input_struct.fcn = fcn;

output_struct = '';

save('test_task_1.mat', 'input_struct', 'output_struct');
