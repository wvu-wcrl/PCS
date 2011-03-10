% svSt.m
%
% Save the state of the cluster worker controller object.
%
% Version 1
% 3/9/2011
% Terry Ferrett

function svSt(obj)

% Construct the save path.
svPath = strcat(obj.svPath, '/', obj.svFile); 

% Save cluster state.
save(svPath, obj);
