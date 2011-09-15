% stub_worker2.m
% 
% Stub worker to test multiple workers per simulation instance.
%
% Terry Ferrett
% Version 1
% 9/14/2011
function stub_worker2(n,cmlRoot)

TimeToLive = 60;
t1=tic;

InFile  =  [cmlRoot '/input/i2' int2str(n)];  
OutFile = [cmlRoot '/output/o2' int2str(n)];  

while(toc(t1) < TimeToLive )
    save( InFile, 't1' );
    save( OutFile, 't1' );
    pause(5);
end
    
