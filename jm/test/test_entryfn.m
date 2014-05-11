% test.m
% 
% code to test the generic worker
%
%

function out_struct = test_entryfn(in_struct)

nnums = in_struct.nnums;   % read the number of variates from the input structure

pause(300);                  % sleep for 30 seconds

out_struct.nums = rand(1,nnums);  % write the variates to the output structure

end
