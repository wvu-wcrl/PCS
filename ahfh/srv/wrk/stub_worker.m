% stub_worker.m
% 
% Stub worker to test cluster CML.
%
% Terry Ferrett
% Version 1
% 2/27/2011
function stub_worker(n)

TimeToLive = 30;
t1=tic;

while(toc(t1) < TimeToLive )
    filename = ['dummy' int2str(n)];  
    save( filename, 't1' );
    pause(5);
end
    