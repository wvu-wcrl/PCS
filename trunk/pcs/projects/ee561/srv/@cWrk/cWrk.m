% cWrk.m
%
% Implementation of the cluster worker object,
%
% Version 1
% 2/28/2011
% Terry Ferrett

classdef cWrk < handle
    
    properties
        hostname
        pid
        wrkCnt
    end
    
    methods
        function obj = cWrk(hostname, pid, wrkCnt)
            obj.hostname = hostname;
            obj.pid = pid;
            obj.wrkCnt = wrkCnt;
        end
    end
    
end
