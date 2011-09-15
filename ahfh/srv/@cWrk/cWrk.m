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
        ws
    end
    
    methods
        function obj = cWrk(hostname, pid, wrkCnt, ws)
            obj.hostname = hostname;
            obj.pid = pid;
            obj.wrkCnt = wrkCnt;
	    obj.ws = ws;
        end
    end
    
end
