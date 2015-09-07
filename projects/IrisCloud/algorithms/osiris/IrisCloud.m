% IrisCloud.m
%  IrisCloud task implementation.  This task selects the algorithm
%  to execute based on the specified algorithm type.


function OutputParam = IrisCloud(InputParam)

% Set path to IrisCloud task code.
IrisCloudCodeRoot='/rhome/pcs/projects/IrisCloud';


% Select task execution style based on user type.
switch InputParam.UserType
    
    case 'EndUser'
        
        % Perform error checking on AlgorithmParams structure.
        rs = error_check_AlgorithmParams( InputParam );     
        % rs - return status - 0 if success, otherwise failure
        % exit task if rs not equal to 0
        if rs ~= 0, return, end
                
        
        % Select specific task to execute based on algorithm type.
        switch(InputParam.AlgorithmParams.AlgorithmType)
            
            case('osiris')
                OutputParam=OsirisTask(InputParam,IrisCloudCodeRoot);
          
            case('HOG')
                OutputParam=HOGTask(InputParam);
            
            otherwise
                msg = sprintf( 'Unknown AlgorithmType specified.\n' );
                fprintf( msg );
                return;
                
        end
               
        
    otherwise
        fprintf('User type not recognized.');
        return;
        
end

end





% Function to error check contents of AlgorithmParams structure.
function rs = error_check_AlgorithmParams( InputParam )

if isfield(InputParam, 'AlgorithmParams')

    if isfield(InputParam.AlgorithmParams, 'AlgorithmName')
        rs = 0;
    else
        msg = sprintf( 'Algorithm name not found.\n' );
        fprintf( msg );
        rs = 1;
        return;
    end
    
    if isfield(InputParam.AlgorithmParams,'AlgorithmType')
        rs = 0;
    else
        msg = sprintf( 'Algorithm type not found \n' );
        fprintf( msg );
        rs = 1;
        return;
    end
    
else
    msg = sprintf( 'Algorithm parameters not found. \n' );
    fprintf( msg );
    rs = 1;
    return;
end

rs = 0;
end

