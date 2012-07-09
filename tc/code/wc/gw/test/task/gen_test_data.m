% gen_test_data.m
%
% create an example input structure for the code loaded by the test 

InputParam.nnums = 10;                                        % generate 10 uniform random variates
FunctionPath = '/rhome/tferrett/cml2/iscml/pcs/tc/code/wc/gw/test/task'; % path to entry function
FunctionName = 'test';                                               % entry function

TaskParam.InputParam = InputParam; % load input struct
TaskParam.FunctionPath = FunctionPath;
TaskParam.FunctionName = FunctionName;

output_struct = '';

save('test_task_1.mat', 'TaskParam', 'output_struct');
