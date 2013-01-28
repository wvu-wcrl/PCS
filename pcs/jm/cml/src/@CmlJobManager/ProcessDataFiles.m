% Process user data files and convert to appropriate format for CML
%  workers
function [ JobParam ] = ProcessDataFiles( obj, JobParamIn,...
    CurrentUser, JobName)

% iterate over set of fields which specify data files
% sim_param.parity_check_matrix
DataFileFields = { 'parity_check_matrix'};

N_df = length( DataFileFields );

for n_df = 1:N_df,
    
    CurDataFileField = DataFileFields{n_df};
    
    switch CurDataFileField
        
        case 'parity_check_matrix'            
            %%%%%%
            [ SuccessFlag ErrMsg H_rows H_cols] = ...
                CreatePCM( obj, CurrentUser, ...
                JobParamIn.parity_check_matrix);
            %%%%%%%%
            
            % populate code_param_long
            code_param_long.H_rows = H_rows;
            code_param_long.H_cols = H_cols;
            
            [ ErrMsg DataPathFile ] = SaveDataFile( obj, code_param_long,...
                                      CurrentUser, JobName );                                  
                                  
            % attach data file name to JobParamIn
            JobParamIn.code_param_long_filename =...
                DataPathFile;
    end
end
end


% return DataPathFile for appending to JobParam
function [ ErrMsg DataPathFile ] =...
    SaveDataFile( obj, code_param_long, CurrentUser, JobName )
%todo: get data path info

%get jobname
% get datapath

% get path to user data directory
[JobInDir, JobRunningDir, JobOutDir, TempDir, DataDir] =...
    obj.SetPaths(CurrentUser.JobQueueRoot);

% form path to user data directory
DataPath = [ DataDir filesep 'Jm' ];

% form data filename
JobNamePrefix = JobName(1:end-4);
DataFile = [ JobNamePrefix '_data.mat' ];  % <jobname>_data.mat

% form full path to data file in user data directory
DataPathFile = [DataPath filesep DataFile];

% form full path to JM temporary directory
JMTempPath = obj.JobManagerParam.TempJMDir;

% form full path to data file in JM temp directory
JMTempPathFile = [JMTempPath filesep DataPathFile];

% save code_param_long into JM temporary directory
save(JMTempPathFile, 'code_param_long');

% move file from temp to user data directory
% error check
SuccessFlag = MoveFile(obj, JMTempPathFile, DataPathFile,...
    SuccessMsg, ErrorMsg);
if SuccessFlag ~= 0,
    ErrMsg = ['Error saving %s.', DataPathFile];
else
    ErrMsg = [''];
end

end
