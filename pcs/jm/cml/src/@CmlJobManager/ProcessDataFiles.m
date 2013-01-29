function [ JobParam ] = ProcessDataFiles( obj, JobParam, CurrentUser, JobName )
% Process user data files and convert them to appropriate format for CML workers.

% Iterate over set of fields which specify data files.
% For CML project, this set is only sim_param.parity_check_matrix.
DataFileFields = { 'parity_check_matrix' };

NDF = length( DataFileFields );

for n_df = 1:NDF
    CurDataFileField = DataFileFields{n_df};
    
    switch CurDataFileField
        
        case 'parity_check_matrix'
            [ SuccessFlag, ErrMsg, H_rows, H_cols] = obj.CreatePCM( CurrentUser, JobParam.parity_check_matrix );
            
            % Populate code_param_long.
            code_param_long.H_rows = H_rows;
            code_param_long.H_cols = H_cols;
            
            [ ErrMsg DataPathFile ] = SaveDataFile( obj, code_param_long, CurrentUser, JobName );
            
            % Attach data-file name to JobParam.
            JobParam.code_param_long_filename = obj.RenameLocalCmlHome(DataPathFile);
    end
end
end


function [ ErrMsg DataPathFile ] = SaveDataFile( obj, code_param_long, CurrentUser, JobName )
% Return DataPathFile for appending to JobParam.

% To Do:
% - get data path info.
% - get JobName.
% - get datapath.

% Get path to user data directory.
[JobInDir, JobRunningDir, JobOutDir, TempDir, DataDir] = obj.SetPaths(CurrentUser.JobQueueRoot);

% Form path to user data directory.
DataPath = [ DataDir filesep 'Jm' ];

% Form data filename.
JobNamePrefix = JobName(1:end-4);
DataFile = [ JobNamePrefix '_Data.mat' ]; % <jobname>_Data.mat

% Form full path to data file in user data directory.
DataPathFile = [DataPath filesep DataFile];

% Form full path to JM temporary directory.
JMTempPath = obj.JobManagerParam.TempJMDir;

% Form full path to data file in JM temp directory.
JMTempPathFile = [JMTempPath filesep DataFile];

% Save code_param_long into JM temporary directory.
save(JMTempPathFile, 'code_param_long');

% Move file from JM temp directory to user data directory.
SuccessFlag = obj.MoveFile(JMTempPathFile, DataPathFile, '', ''); % Add success and error messages later.

if SuccessFlag ~= 1
    ErrMsg = ['Error saving DATA file %s.', DataPathFile];
else
    ErrMsg = '';
end

end