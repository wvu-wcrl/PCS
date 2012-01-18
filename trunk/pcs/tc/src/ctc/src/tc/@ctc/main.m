% main.m
%
% main task controller loop
%
% Version 2
% 12/16/2011
% Terry Ferrett

% outline
% 1. scan user input directories for input files
% 2. decide which user to service
% 3. launch tasks for the user with the least active tasks

function main(obj)


nu = length(obj.users);           % number of users


while(1) %enter primary loop

    [au fl] = scan_user_inputs(obj);                     % scan input directories for new .mat inputs

    
    [users_srt fl_srt] = schedule(obj, au, fl);          % decide which user to service

    
    place_user_input_in_queue(obj, users_srt, fl_srt);   % move input files to cluster input queue

    
    calculate_active_workers(obj);                       % scan the global running queue and count the active workers for each user

    
    consume_output(obj);                                 % scan global output queue and place completed work in user output directory

    
    pause(5);                                            % pause for 5 seconds before making another pass
    
    
end


end









function [au fl] = scan_user_inputs(obj)

nu = length(obj.users);           % number of users

na = 0;                           % users having input files 

au ={};

fl = {};

for k = 1:nu,

    srch = strcat(obj.users{k}.iq, '/*.mat');      % form full dir string

    sfl{k} = dir( srch{1} );                       % get list of .mat files in input queue directory
    
    if length( sfl{k} ) > 0,

        na = na + 1;

        au{na} = obj.users{k};

        nf(na) = length(sfl{k});                   % how many input files does this user have?

        fl{na} = sfl{k};

    end
   

end

end
















function [users_srt fl_srt] = schedule(obj, au, fl)   % sort the users by number of active workers in use

ntu = length(obj.users);    % total number of users

nau = length(au);           % number of users having input files (active users)

nw = [];                    % number of workers occupied by active users

users_srt = {};             % users sorted by number of active users

fl_srt = {};                % sorted list

for k =1:nau,

    for l = 1:ntu,

        if strcmp(au{k}.username, obj.users{l}.username)

            nw(k) = obj.users{k}.aw;      % number of workers for this user

        end

    end

end


if ~isempty(nw)

    [l P] = sort(nw);

    users_srt = au{P};

    fl_srt = fl(P);
end

end














function place_user_input_in_queue(obj, users_srt, fl_srt)

PCSUSER = 'pcs';

if ~isempty(users_srt)
    avw = obj.nw - obj.aw;   % available number of workers
    nf = length( fl_srt{1} );
    cnt = 0;
    while avw > 0 & nf > 0,   % add files to queue until the queue is full or no more files exist
        avw = avw - 1;
        nf = nf - 1;
        cnt = cnt + 1;

        puif = strcat(users_srt.iq, '/', fl_srt{1}(cnt).name)  % path to input file
        pgiq = obj.gq.iq;
	purq = users_srt.rq;

        % append username to file
        afn = [users_srt.username '_' fl_srt{1}(cnt).name];

        % copy user file into running queue
        cmd_str = ['cp' ' ' puif{1} ' ' purq{1} '/' fl_srt{1}(cnt).name];
        system(cmd_str);


        % move user file into input queue
        cmd_str = ['sudo mv' ' ' puif{1} ' ' pgiq{1} '/' afn];
        system(cmd_str);
        % change ownership to pcs user
        cmd_str = ['sudo chown' ' ' PCSUSER ':' PCSUSER ' ' path2{1} '/' afn]
        system(cmd_str);   % change ownership back to user      
    end
    
obj.aw = obj.aw + cnt;
    
end

end



















function update_user_active_status(obj, users_srt, fl_srt) % move input file to user's active directory


if ~isempty(users_srt)

    puiq = users_srt.iq{1};

    purq =  users_srt.rq{1};
    
    nf = length( fl_srt{1} ); 
    
    for k = 1:nf,

        af = strcat(fl_srt{1}(k).name);

        cmd_str = ['sudo mv' ' ' puiq '/' af ' ' purq '/' af ];

        system(cmd_str);

    end

end

end




















function calculate_active_workers(obj) % scan the global running queue and count the active workers for each user

%% read files in global running queue %%
srch = strcat(obj.gq.rq{1}, '/*.mat');  
fl = dir( srch ); 
nf = length(fl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nu = length(obj.users);                % loop over all users

for k = 1:nu, 

    nw = 0;                            % set the number of workers to 0

    name = obj.users{k}.username;      % shorter notation for this user

    for m = 1:nf,                      % loop over all files and determine the user

        isuser = findstr(fl(m).name, name);  % find the username embedded in the filename and compare

        if isempty(isuser),
        elseif isuser == 1,            % pattern matches. add user.
            nw = nw + 1;
        end

     end

    obj.users{k}.aw = nw;  % update active user count

end

nw = 0;         % add up all active workers for all users
for k = 1:nu,
nw = nw + obj.users{k}.aw;
end


obj.aw = nw;    % the killing blow. update the global count of active users
end







function consume_output(obj)

%% get files in output queue %%
pgoq = obj.gq.oq{1};
srch = strcat(pgoq, '/*.mat');      % form full dir string
fl = dir( srch );    % get list of .mat files in output queue
nf = length(fl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nu = length(obj.users);

for k = 1:nf,

    for m = 1:nu,

        name = obj.users{m}.username;           % shorten the name

        if findstr( fl(k).name, name )

            [beg on] = strtok(fl(k).name, '_'); on = on(2:end);    % cut the username off of the filename

            puoq = obj.users{m}.oq{1};                             % path to user output queue

            cmd_str = ['sudo mv' ' ' pgoq '/'  fl(k).name ' ' puoq '/' on];  system(cmd_str); % move file to user output queue

            cmd_str = ['sudo chown' ' ' name ':' name ' ' puoq '/' on]; system(cmd_str);   % change ownership back to user

	    purq = obj.users{m}.rq{1};

	    cmd_str = ['sudo rm' ' ' purq '/'  on]; system(cmd_str); % remove file from user running queue

	    
        end
    end
end

end


