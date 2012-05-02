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
WEB_ROOT = '/home/web_users';


% read the user configuration filename from the ctc config file
heading = '[cfg]';
key = 'user';
out = util.fp(obj.cfp, heading, key);
obj.ucfg = out{1}{1};

CFG_FILENAME = obj.ucfg;






obj = scan_user_dirs(obj, CFG_FILENAME, HOME_ROOT);
obj = scan_user_dirs(obj, CFG_FILENAME, WEB_ROOT);


end





function obj = scan_user_dirs(obj, CFG_FILENAME, USR_ROOT)

usrdirs = dir(USR_ROOT);   % perform a directory listing in home to list users
n = length(usrdirs);       % number of directories found


usr_cnt = length(obj.users);


cur_usr_cnt = 1;

for k = 1:n,
    
	  cur_path = strcat(USR_ROOT, '/', usrdirs(k).name);  % find .ctc file
	  cur_file = strcat(cur_path, '/', CFG_FILENAME);
          file_exists = length( dir(cur_file) );
    
    if file_exists ~= 0, % if .ctc exists, read it
        
        % add this user to active users
      users{cur_usr_cnt} = usrdirs( k ).name;




        % read input directory
        heading = '[paths]';
        key = 'input';
        out = util.fp(cur_file, heading, key);
        iq{cur_usr_cnt} = out{1};
        
        % read running directory
        key = 'active';
        out = util.fp(cur_file, heading, key);
        rq{cur_usr_cnt} = out{1};
        
        % read output directory
        key = 'output';
        out = util.fp(cur_file, heading, key);
        oq{cur_usr_cnt} = out{1};


% specify whether this is a web or cluster user
if( strcmp(USR_ROOT, '/home/web_users') )
  user_location = 'web';
 elseif ( strcmp(USR_ROOT, '/home') )
  user_location = 'local';
end

        tmp.username = users{cur_usr_cnt};
        tmp.iq = iq{cur_usr_cnt};
        tmp.rq = rq{cur_usr_cnt};
        tmp.oq = oq{cur_usr_cnt};
        tmp.user_location = user_location;
        tmp.aw = 0;
       
        obj.users{usr_cnt+cur_usr_cnt} = tmp;
        cur_usr_cnt = cur_usr_cnt + 1;

%obj.users
%pause
 
    end
    
end



end







