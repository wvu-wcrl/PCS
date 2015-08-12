% test_entryfn_long.m

function out_struct = test_entryfn_long(in_struct)

nnums = in_struct.nnums;   % read the number of variates from the input structure

pause(500);                  % sleep for 30 seconds

out_struct.nums = rand(1,nnums);  % write the variates to the output structure

end
