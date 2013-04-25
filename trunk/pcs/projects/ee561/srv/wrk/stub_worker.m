% stub_worker.m
% 
% Stub worker to test cluster CML.
%
% Terry Ferrett
% Version 1
% 2/27/2011
function stub_worker(n)

while(1)
    sprintf('I am sleeping for %d seconds. \n', n)
    pause(n);
end
    