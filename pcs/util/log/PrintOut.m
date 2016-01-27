function PrintOut(Msg, vqFlag, LogFileName, AppendTimeFlag)
% Calling Syntax: PrintOut(Msg [,vqFlag] [,LogFileName] [,AppendTimeFlag])
%
% Inputs
%   Msg: A 2-by-1 CELL array of STRINGs containing the log messages for the Verbose or Quiet logging modes, respectively.
%        If Msg is a SINGLE STRING, it will be counted as the Verbose message and the Quiet message is set to empty.
%   vqFlag: A binary flag indicating which one of the two log messages in Msg cell array to be printed out.
%           0 verbose mode: The first message in the cell array Msg is printed out (Default).
%           1 quiet mode: The second message in the cell array Msg (if exists) is printed out.
%   LogFileName: The name of the log file in which the Msg is printed out.
%                It should be a STRING. If it is a number, the Msg is printed out in the standard output (Default).
%   AppendTimeFlag: A binary flag indicating whether or not the TIME should be appended to the printed Msg.
%                   0 Do NOT append the time to the end of the Msg (Default).
%                   1 Do     append the time to the end of the Msg.
%
%	Copyright (C) 2012, Mohammad Fanaei and Matthew C. Valenti.
%	For full copyright information see the bottom of this file.


if( ~iscellstr(Msg) && ischar(Msg) ), Msg = {Msg ; ''}; end
if( nargin<2 || isempty(vqFlag) ), vqFlag = 0; end                  % Default Verbose mode.
if( nargin<3 || isempty(LogFileName) ), LogFileName = 0; end        % Default Standard Output.
if( nargin<4 || isempty(AppendTimeFlag) ), AppendTimeFlag = 0; end  % Default do NOT append the time to the end of the Msg.

% Determine which one of the two messages in Msg should be printed out.
if vqFlag == 0      % Verbose mode.
    MsgPrint = Msg{1};
elseif vqFlag == 1  % Quiet mode.
    MsgPrint = Msg{2};
end

% Add the timing information at the end of the selected message if required.
if( AppendTimeFlag == 1 && ~isempty(MsgPrint) )
    MsgPrint = [MsgPrint, ' @ ', datestr(clock, 'dddd, dd-mmm-yyyy HH:MM:SS PM')];
    if ischar(LogFileName)
        MsgPrint = [MsgPrint, '.\r\n'];
    else
        MsgPrint = [MsgPrint, '.\n'];
    end
end

% Print out the constructed message either in the log file or in the standard output.
if ~isempty(MsgPrint)
    if ischar(LogFileName)
        FID_LogFile = fopen( LogFileName, 'a+');
        fprintf( FID_LogFile, MsgPrint );
        fclose(FID_LogFile);
    else
        fprintf( MsgPrint );
    end
else
    return;
end
end


%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
