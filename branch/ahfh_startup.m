% ahfh_startup.m
% script to create a cluster worker controller object using the ahfh
% project.
%
% Inputs:
% 1. configuration file 
%
% Outputs:
% 1. cluster worker controller object.
function cwc_obj = ahfh_startup(cfg)

  % set paths to cluster worker controller objects
   ClusterStartup;
  
   % create cluster worker controller object
   cwc_obj = cwc([pwd '/srv'], [pwd '/ahfh'], cfg);
end
