% CreatePCM converts parity check matrices uploaded by web users
% to the format expected by CML.
%
% The calling syntax is:
%     [SuccessFlag, ErrMsg, H_rows, H_cols] = CreatePCM( obj, CurrentUser, pcm )
%
%     Inputs
%       obj         CmlJobManager object.
%       CurrentUser Current user selected by CmlJobManager.
%       pcm         parity check matrix argument loaded from sim_param.parity_check_matrix.
%
%     Outputs
%       SuccessFlag      0 if no error, 1 if error.
%       ErrMsg           Empty if no error, string if error.
%       H_rows
%       H_cols
%
%     Copyright (C) 2013, Terry R. Ferrett, Mohammad Fanaei, and Matthew C. Valenti.
%     Last updated on 1/25/2013.

   %%% TODO: check for existence of data file by extension, try-catch

function [SuccessFlag ErrMsg H_rows H_cols] = CreatePCM( obj, CurrentUser, pcm )

SuccessFlag = 0;  % Assume successful operation.

hmat_type = GetHmatType( pcm );

cml_home = CurrentUser.CodeRoot;

switch hmat_type
    case 'pchk'
        pcm_prefix = pcm(1:end-5);
        [ H_rows, H_cols, ErrMsg ] = cnv_pchk_hr_hc( obj, pcm, CurrentUser, cml_home );
        
        if ~isempty(ErrMsg)
            SuccessFlag = 1;
            return;
        end
        
        % [ErrMsg] = save_hrows_hcols( obj, CurrentUser, pcm_prefix, H_rows, H_cols );
        
    case 'alist'
        pcm_prefix = pcm(1:end-6);
        [JobInDir, JobRunningDir, JobOutDir, TempDir JobDataDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
        [H_rows, H_cols] = CmlAlistToHrowsHcols( JobDataDir, pcm_prefix );
        ErrMsg = '';  % add error checking later.
        % [ErrMsg] = save_hrows_hcols( obj, CurrentUser, pcm_prefix, H_rows, H_cols );
    case 'mat'
        %
        [JobInDir, JobRunningDir, JobOutDir, TempDir JobDataDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
    JobDataFileMat = [ JobDataDir filesep pcm ];
    load(JobDataFileMat);
    ErrMsg = '';   % nothing to be done. empty error message
    case 'cml_dvbs2'
        %
    H_rows = 0;
    H_cols = 0;
    ErrMsg = '';   % nothing to be done. empty error message
    case 'not_supported';
        %
    ErrMsg = '';   % nothing to be done. empty error message
    otherwise
        %
    ErrMsg = '';   % nothing to be done. empty error message
end

if ~isempty(ErrMsg)
    SuccessFlag = 1;
    return;
end

end



function [ H_rows H_cols ErrMsg ] = cnv_pchk_hr_hc( obj, pcm, CurrentUser, cml_home )

LdpcCodeGenP = crp_codegen_cl( cml_home );

tmp_path = obj.JobManagerParam.TempJMDir;

[JobInDir, JobRunningDir, JobOutDir, TempDir JobDataDir] = obj.SetPaths(CurrentUser.JobQueueRoot);

[ErrMsg] = cnv_pchk_alist_cl(LdpcCodeGenP, JobDataDir, tmp_path, pcm);

pcm_prefix = pcm(1:end-5);

[H_rows, H_cols] = CmlAlistToHrowsHcols( tmp_path, pcm_prefix );

end


function LdpcCodeGenP = crp_codegen_cl( cml_home )

p1 = cml_home;
p2 = 'module';
p3 = 'chan_code';
p4 = 'ldpc';
p5 = 'code_gen';

LdpcCodeGenP = [p1 filesep p2 filesep p3 filesep p4 filesep p5];

end


function [ErrMsg] = cnv_pchk_alist_cl(LdpcCodeGenP, DataPath, TmpPath, pchk_file)

% Create alist creation command string.
sp = ' ';
p1 = 'pchk-to-alist'; % command name.
p2 = [DataPath filesep pchk_file]; % Temporary filename.
p3 = [TmpPath filesep pchk_file(1:end-5) '.alist'];

if ~exist([LdpcCodeGenP filesep p1], 'file')
    ErrMsg1 = 'pchk-to-alist executable file does not exist.\n';
    ErrMsg2 = 'Please compile the LDPC code generation functions.';
    ErrMsg = [ErrMsg1 ErrMsg2];
else
    ErrMsg = '';
end

% Invoke external command to generate alist file.
cmd = [LdpcCodeGenP filesep p1 sp p2 sp p3];
system(cmd);
end


% function [ErrMsg] = save_hrows_hcols( obj, CurrentUser, pcm_prefix, H_rows, H_cols)
% PcmMat = [ pcm_prefix '.mat' ];
%
% PcmMatTmpP = fullfile(obj.JobManagerParam.TempJMDir, PcmMat);
%
% save( PcmMatTmp, 'H_rows', 'H_cols');
%
% [JobInDir, JobRunningDir, JobOutDir, TempDir] = obj.SetPaths(CurrentUser.JobQueueRoot);
%
% PcmMatDataP = [ JobDataDir filesep PcmMat ];
%
% % Error check.
% SuccessFlag = MoveFile(obj, PcmMatTmpP, PcmMatDataP, SuccessMsg, ErrorMsg);
% if SuccessFlag ~= 0,
%     ErrMsg = ['Error saving DATA file %s.', PcmMatDataP];
% else
%     ErrMsg = [''];
% end
% end


%     Function CmlCreateHmatCluster is part of the Iterative Solutions Coded Modulation
%     Library (ISCML).
%
%     The Iterative Solutions Coded Modulation Library is free software;
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
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
