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
CFG_FILENAME = '.ctc';


usrdirs = dir(HOME_ROOT);   % perform a directory listing in home to list users

n = length(usrdirs);       % number of directories found
usr_cnt = 1;                   % counter to track number of users
for k = 1:n,
    
    cur_path = strcat(HOME_ROOT, '/', usrdirs(k).name);  % find .ctc file
    cur_file = strcat(cur_path, '/', CFG_FILENAME);
    file_exists = length( dir(cur_file) );
    
    if file_exists ~= 0, % if .ctc exists, read it
        
        % add this user to active users
        users{usr_cnt} = usrdirs(k).name;
        
        % read input directory
        heading = '[paths]';
        key = 'input';
        out = util.fp(cur_file, heading, key);
        iqp{usr_cnt} = out{1};
        
        % read running directory
        key = 'running';
        out = util.fp(cur_file, heading, key);
        rp{usr_cnt} = out{1};
        
    end
    
end



n = length(users);   % number of workers
for k = 1:n,
    tmp.username = users{k};
    tmp.iqp = iqp{k};
    tmp.rp = rp{k};
    tmp.aw = 0;
    obj.users{k} = tmp;
end



end










