function SaveSignalSet(SignalSet, JobFileName)
% SaveSignalSet generates a .mat file called 'JobFileName' that contains two structures called JobParam and JobState based on its inputs.
% The generated .mat file is suitable for being uploaded to WCRL web interface to complete the Monte-Carlo simulation of an uncoded simulation
% with the given signal constellation (SignalSet) for EE561 course project at WVU.
%
% Calling syntax: SaveSignalSet([SignalSet] [,JobFileName])
%
% Inputs (both OPTIONAL)
%       SignalSet       K by Order REAL Signal Constellation (K is the dimensionality of the signal space. There are Order points in the signal space.)
%       JobFileName     Name of the .mat job file that the user wants this function to generate.

if( nargin<1 || isempty(SignalSet) )
    ParamName = {'S', 'SignalSet', 'S_matrix'};
    try
        SignalSet = evalin('base',ParamName{1});
    catch
        try
            SignalSet = evalin('base',ParamName{2});
        catch
            try
                SignalSet = evalin('base',ParamName{3});
            catch
                Msg1 = 'You should either give your signal constellation as the first input to this function or \n';
                Msg2 = 'have your signal constellation under one of the names "S", "SignalSet", or "S_matrix" in Matlab workplace!\n\n';
                fprintf([Msg1 Msg2]);
                return;
            end
        end
    end
end
if( nargin<2 || isempty(JobFileName) )
    % JobFileName = ['UncodedModProject_Ver' num2str(round(100*rand)) '_' datestr(clock,'mmmdd_HHMM') '.mat'];
    JobFileName = ['Project_' datestr(clock,'mmmdd_HHMM') '.mat'];
end

JobParam = struct('SignalSet',SignalSet);
JobState = [];
save(JobFileName,'JobParam','JobState');

end