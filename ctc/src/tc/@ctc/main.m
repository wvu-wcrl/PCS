% main.m
%
% main task controller loop
%
% Version 1
% 11/29/2011
% Terry Ferrett

% outline
% 1. scan user input directories for input files
% 2. decide which user to service
% 3. launch tasks for the user with the least active tasks

function main(obj)

nu = length(obj.users);           % number of users

while(1) %enter primary loop
        
    % scan user task directories for inputs
    clear fl;           % clear previous file listing
    clear nf;           % clear previous number of input files
    
    
    for k = 1:nu,
        srch = strcat(obj.users{k}.iqp, '/*.mat');      % form full dir string
        fl{k} = dir( srch{1} );    % get list of .mat files in input queue directory
        
        nf(k) = length(fl{k});  % how many input files does this user have?
    end
        
    
    %%%% decide which user to service
    % sort the list of number of workers each user is running
    % sort file listing according to user
    
    %%%%
    clear nw;
    for k =1:nu,
        nw(k) = obj.users{k}.aw;
    end
    [l P] = sort(nw);
    
    users_srt = obj.users(P);
    fl_srt = fl(P);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %%%%%%% place user's input files into input queue
    %%%%%%%
    avw = obj.nw - obj.aw;   % available number of workers
    nf = length( fl_srt{1} );
    
    cnt = 1;
    while avw > 0 & nf > 0,
        path1 = strcat(users_srt{1}.iqp, '/', fl_srt{1}(cnt).name);  % path to input file
        path2 = obj.cfg.qp;
        
        % copy user file into input queue
        cmd_str = ['cp' ' ' path1{1} ' ' path2{1}];
        system(cmd_str);
        
        avw = avw - 1;
        nf = nf - 1;
        cnt = cnt + 1;
    end
    
    pause(5);    % pause for 5 seconds before making another pass
end




end
