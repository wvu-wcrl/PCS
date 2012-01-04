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
        
	    [au fl] = scan_user_inputs(obj);   % scan input directories for new .mat inputs
    
    [users_srt fl_srt] = schedule(obj, au, fl); % decide which user to service
    
    place_user_input_in_queue(obj, users_srt, fl_srt);   % move input files to cluster input queue
    
    update_user_active_status(obj, users_srt, fl_srt); % place status file in user's active directory
    
    calculate_active_workers(obj); % scan the global running queue and count the active workers for each user
    
    consume_output(obj);             % scan global output queue and place completed work in user output directory
    
    pause(5);    % pause for 5 seconds before making another pass
    
    
end


end










function [au fl] = scan_user_inputs(obj)


nu = length(obj.users);           % number of users
na = 0;        % users having input files
au ={};
fl = {};
for k = 1:nu,
    srch = strcat(obj.users{k}.iq, '/*.mat');      % form full dir string
    sfl{k} = dir( srch{1} );    % get list of .mat files in input queue directory
    
%    obj.users{2}.iq

    if length( sfl{k} ) > 0,
        na = na + 1;
        au{na} = obj.users{k};
        nf(na) = length(sfl{k});  % how many input files does this user have?
        fl{na} = sfl{k};
    end
    
end
end







function [users_srt fl_srt] = schedule(obj, au, fl)   % sort the users by number of active workers in use

ntu = length(obj.users);
nau = length(au);           % number of users
nw = [];
users_srt = {};
fl_srt = {};

for k =1:nau,
    for l = 1:ntu,
        if strcmp(au{k}.username, obj.users{l}.username)
            nw(k) = obj.users{k}.aw;
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

if ~isempty(users_srt)
    avw = obj.nw - obj.aw;   % available number of workers
    nf = length( fl_srt{1} );
    
    cnt = 1;
    while avw > 0 & nf > 0,
        path1 = strcat(users_srt.iq, '/', fl_srt{1}(cnt).name);  % path to input file
        path2 = obj.gq.iq;
        
        % append username to file
        afn = [users_srt.username '_' fl_srt{1}(cnt).name];

        % copy user file into input queue
        cmd_str = ['cp' ' ' path1{1} ' ' path2{1} '/' afn];
        system(cmd_str);
        
        avw = avw - 1;
        nf = nf - 1;
        cnt = cnt + 1;
    end
    
    
end

end






function update_user_active_status(obj, users_srt, fl_srt) % move input file to user's active directory


if ~isempty(users_srt)
    liq = users_srt.iq{1};
    lrq =  users_srt.rq{1};  % form path name
    
    
    nf = length( fl_srt{1} );     % determine number of input files
    
    for k = 1:nf,
        af = strcat(fl_srt{1}(k).name); % form active filename
        cmd_str = ['sudo mv' ' ' liq '/' af ' ' lrq '/' af ];
        system(cmd_str);
    end
end

end





function calculate_active_workers(obj) % scan the global running queue and count the active wrkers for each user

srch = strcat(obj.gq.rq{1}, '/*.mat');      % form full dir string

fl = dir( srch );    % get list of .mat files in input queue directory
nf = length(fl);

nu = length(obj.users); % loop over all active users


for k = 1:nu, % for all users
    nw = 0;        % count number of occupied workers
    name = obj.users{k}.username;
    
    for m = 1:nf, % loop over all files and correlate
        isuser = findstr(fl(m).name, name);
        if isempty(isuser),
        elseif isuser == 1, % pattern matches. add user.
            nw = nw + 1;
        end
        
    end
    obj.users{k}.aw = nw;  % update active user count
end

end







function consume_output(obj)

path1 = obj.gq.oq{1};

srch = strcat(path1, '/*.mat');      % form full dir string
fl = dir( srch );    % get list of .mat files in input queue directory
nf = length(fl);
nu = length(obj.users);


for k = 1:nf,
    for m = 1:nu,
        name = obj.users{m}.username;
        if findstr( fl(k).name, name )
            [beg on] = strtok(fl(k).name, '_'); on = on(2:end);
            path2 = obj.users{m}.oq{1};
            cmd_str = ['sudo mv' ' ' path1 '/'  fl(k).name ' ' path2 '/' on];
            system(cmd_str);
        end
    end
end

end
