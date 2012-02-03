% JM_Append.m
%
% Function to write data to results.txt
%
% inputs
%
%   data           string to write to file
%   resultsfile  full path to results file
%   user           username of user owning results file

function JM_Append(data, resultsfile, user)

% append data to results file
cs = ['sudo bash -c "echo '];
cs = [cs data];
cs = [cs ' >> ' resultsfile '"'];
system(cs);


% change ownership of file to user
cs = ['sudo chown ' user ':' user ' ' resultsfile];
system(cs);

end

