% process user data files and convert to appropriate format for CML workers
% every keyword clause must set SuccessFlag and ErrMsg
function [ JobParam SuccessFlag ErrMsg] =...
   ProcessDataFiles( obj, JobParam, CurrentUser, JobName, CodeRoot )

% specify keywords indicating simulation conditions requiring data files
%   1. parity_check_matrix   - simulation requires an LDPC parity check matrix
data_file_contents = { 'parity_check_matrix' };



N_df = length( data_file_contents );
for n_df = 1:N_df
    cur_content = data_file_contents{n_df};
    
    switch cur_content
        
        case 'parity_check_matrix'
            
            % cml defines the parameter 'parity_check_matrix' regardless
            %  of simulation type
            % determine action based on parameter value,
            %  if no action necessary, do nothing
            if ~isempty(JobParam.parity_check_matrix)
                hmat_type = GetHmatType( JobParam.parity_check_matrix );
                
                switch hmat_type,
                 case { 'pchk', 'alist', 'mat', 'cml_dvbs2', 'cml_wimax' }
                        % convert parity check matrix to H_rows, H_cols
		  [ SuccessFlag, ErrMsg, H_rows, H_cols, H_rows_no_eira, H_cols_no_eira] =...
		  obj.CreatePCM( CurrentUser, JobParam.parity_check_matrix, ...
				 JobParam, CodeRoot );
                        
                        % return if error
                        if SuccessFlag == 0,
                            return;
                        end
                        
                        
                        code_param_long.H_rows = H_rows;
                        code_param_long.H_cols = H_cols;
                        code_param_long.H_rows_no_eira = H_rows_no_eira;
                        code_param_long.H_cols_no_eira = H_cols_no_eira;
                        
                        % save data file to user data directory
                        [ ErrMsg DataPathFile ] = ...
                            SaveDataFile( obj, code_param_long, CurrentUser, JobName );
                        
                        if ~isempty(ErrMsg)
                            SuccessFlag = 0;
                            return;
                        end
                        
                        
                        
                        % attach data file name to code_param
                        JobParam.code_param_long_filename = obj.RenameLocalCmlHome(DataPathFile);
                    case {'noldpc'}
                        % nothing to do
                        SuccessFlag = 1;
                        ErrMsg = '';
                        
                    otherwise
                        SuccessFlag = 0;
                        ErrMsg = 'Unsupported parity check matrix type.';
                end
            else
                % nothing to do
                SuccessFlag = 1;
                ErrMsg = '';
            end
    end
end
end


% save data file to user data directory
function [ ErrMsg DataPathFile ] = ...
    SaveDataFile( obj, code_param_long, CurrentUser, JobName )
% return DataPathFile for appending to JobParam.

% get path to user data directory.
[JobInDir, JobRunningDir, JobOutDir, JobFaileDir,...
    SuspendedDir, TempDir, JobDataDir] = ...
    obj.SetPaths(CurrentUser.JobQueueRoot);

% form path to user data directory.
DataPath = [ JobDataDir filesep 'Jm' ];

% form data filename.
JobNamePrefix = JobName(1:end-4);
DataFile = [ JobNamePrefix '_Data.mat' ]; % <jobname>_Data.mat

% form full path to data file in user data directory.
DataPathFile = [DataPath filesep DataFile];

% form full path to JM temporary directory.
JMTempPath = obj.JobManagerParam.TempJMDir;

% form full path to data file in JM temp directory.
JMTempPathFile = [JMTempPath filesep DataFile];

% save code_param_long into JM temporary directory.
save(JMTempPathFile, 'code_param_long');

% move file from JM temp directory to user data directory.
SuccessFlag = obj.MoveFile(JMTempPathFile, DataPathFile, '', ''); % Add success and error messages later.

if SuccessFlag ~= 1
    ErrMsg = ['Error saving DATA file %s.', DataPathFile];
else
    ErrMsg = '';
end

end
