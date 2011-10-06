% stub_worker.m
% 
% Stub worker to test cluster CML.
%
% Terry Ferrett
% Version 1
% 2/27/2011
function stub_worker(n,cmlRoot)

TimeToLive = 60;
t1=tic;

InFile  =  [cmlRoot '/input/i' int2str(n)];  
OutFile = [cmlRoot '/output/o' int2str(n)];  

while(toc(t1) < TimeToLive )
    save( InFile, 't1' );
    save( OutFile, 't1' );
    pause(5);
end
    