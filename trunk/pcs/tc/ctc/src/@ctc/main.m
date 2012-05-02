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
	    sprintf('hi')
    [au fl] = scan_user_inputs(obj);                     % scan user input directories for new .mat inputs

    
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















% sort the users by number of active workers possessed by each
%  user 
function [users_srt fl_srt] = schedule(obj, au, fl)  

ntu = length(obj.users);    % total number of users

nau = length(au);           % number of users having input files (active users)

nw = [];                    % number of workers occupied by active users

users_srt = {};             % users sorted by number of active users

fl_srt = {};                % sorted list


for k =1:nau,

    for l = 1:ntu,

        USER_MATCH = strcmp(au{k}.username, obj.users{l}.username);
        LOCATION_MATCH = strcmp(au{k}.user_location, obj.users{l}.user_location);

        if USER_MATCH & LOCATION_MATCH,
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
	fn = fl_srt{1}(cnt).name;
        afn = [users_srt.username '_' users_srt.user_location '_' fn];


        % copy user input file into user running queue
        cmd_str = ['sudo cp' ' ' puif{1} ' ' purq{1} '/' fn];
        system(cmd_str);


        % change ownership to pcs user
        cmd_str = ['sudo chown' ' ' PCSUSER ':' PCSUSER ' ' puif{1}]
        system(cmd_str);   % change ownership back to user      

        % move user file into input queue
        cmd_str = ['sudo mv' ' ' puif{1} ' ' pgiq{1} '/' afn];
        system(cmd_str);
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



%%%%%%%% get list of files in running and input queues %%%
%% read the files in the global running queue%%%
srch = strcat(obj.gq.rq{1}, '/*.mat');
rqf = dir( srch ); 

%% read the files in the global input queue
srch = strcat(obj.gq.iq{1}, '/*.mat');  
iqf = dir( srch ); 

%% concatenate the two file lists
bqf = struct_cat(rqf,iqf);  % file list concatenated from both queues


%% calculate the resulting length
nf = length(bqf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% read files in global running queue %%
%srch = strcat(obj.gq.rq{1}, '/*.mat');  
%nf = length(fl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



nu = length(obj.users);                % loop over all users

for k = 1:nu, 

    nw = 0;                            % set the number of workers to 0

    %name = obj.users{k}.username;      % shorter notation for this user
    name = [obj.users{k}.username '_' obj.users{k}.user_location];      % shorter notation for this user, include location
    


    for m = 1:nf,                      % loop over all files and determine the user

        isuser = findstr(bqf(m).name, name);  % find the username embedded in the filename and compare

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

        % names for file ownership
	if( strcmp(obj.users{m}.user_location, 'web') )
	ownership_name = 'tomcat55';
	ownership_group = 'tomcatusers';
        elseif( strcmp(obj.users{m}.user_location, 'local') )
        ownership_name = obj.users{m}.username;           % shorten the name
	ownership_group = obj.users{m}.username;
        end



                   %%%% form name string 
	% name for task ownership
	% name = obj.users{m}.username;
        un_loc = [obj.users{m}.username '_' obj.users{m}.user_location];      % shorter notation for this user, include location
	len_un_loc = length(un_loc);
        


        if findstr( fl(k).name, un_loc )

	% remove username from filename         %%%%%%
            %[beg on] = strtok(fl(k).name, '_'); on = on(2:end);    % cut the username off of the filename
            on = fl(k).name(len_un_loc+2:end);

            puoq = obj.users{m}.oq{1};                             % path to user output queue


            cmd_str = ['sudo chown' ' ' ownership_name ':' ownership_group ' ' pgoq '/' fl(k).name]; system(cmd_str);   % change ownership back to user


            cmd_str = ['sudo mv' ' ' pgoq '/'  fl(k).name ' ' puoq '/' on];  system(cmd_str); % move file to user output queue

	    purq = obj.users{m}.rq{1};


%%%%%%% functionalize %%%
        % remove 'failed' from filename, if exists	    
	if findstr( on, 'failed')
          prefix = on(1:end-11);
          suffix = '.mat';
          on = [prefix suffix];
        end
	    cmd_str = ['sudo rm' ' ' purq '/'  on]; system(cmd_str); % remove file from user running queue
%%%%%%%%%%%%%%%%%%%%%%%%%

	    
        end
    end
end

end




% concatenate two structs having identical fields
function bqf = struct_cat(rqf,iqf)

% get the length of both structs
l1 = length(rqf);
l2 = length(iqf);

% concatenate the structs
bqf = rqf;

for k = 1:l2,
bqf(l1+k) = iqf(k);
end



end
