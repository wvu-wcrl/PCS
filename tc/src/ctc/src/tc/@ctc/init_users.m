% init_users.m
%
% initialize user state
%
% Version 1
% 12/7/2011
% Terry Ferrett


function init_users(obj)

% named constants
HOME_ROOT = '/home';
CFG_FILENAME = '.ctc_cfg';


usrdirs = dir(HOME_ROOT);   % perform a directory listing in home to list users

n = length(usrdirs);       % number of directories found
usr_cnt = 1;                   % counter to track number of users
for k = 1:n,
    
	  cur_path = strcat(HOME_ROOT, '/', usrdirs(k).name);  % find .ctc file
	  cur_file = strcat(cur_path, '/', CFG_FILENAME);
    file_exists = length( dir(cur_file) );
    
    if file_exists ~= 0, % if .ctc exists, read it
        
        % add this user to active users
        users{usr_cnt} = usrdirs(k).name
           


        % read input directory
        heading = '[paths]';
        key = 'input';
        out = util.fp(cur_file, heading, key);
        iq{usr_cnt} = out{1};
        
        % read running directory
        key = 'active';
        out = util.fp(cur_file, heading, key);
        rq{usr_cnt} = out{1};
        
        % read output directory
        key = 'output';
        out = util.fp(cur_file, heading, key);
        oq{usr_cnt} = out{1};
        
        usr_cnt = usr_cnt + 1;    
    end
    
end



n = length(users);   % number of users
for k = 1:n,         % add users to queue
    tmp.username = users{k};
    tmp.iq = iq{k};
    tmp.rq = rq{k};
    tmp.oq = oq{k};
    tmp.aw = 0;
    obj.users{k} = tmp;
end



end










