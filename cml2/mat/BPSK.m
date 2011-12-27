classdef BPSK < CreateModulation
    
    methods
        function obj = BPSK(SignalProb)
        % Calling Syntax: obj = BPSK( [SignalProb] )
            if( nargin<1 ), SignalProb = []; end
            Constellation = [1 -1];
            SignalSet = Constellation;
%           MappingVector = 0:1;
            obj@CreateModulation(SignalSet, SignalProb);
            obj.Type = 'BPSK';
        end
    end
end