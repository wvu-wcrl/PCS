% init_users.m
%
% initialize user state
%
% Version 3
% 5/2014
% Terry Ferrett
%
%     Copyright (C) 2014, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.


function init_users(obj)

% root directory of user home directories
heading = '[paths]';
key = 'users';
user_dirs = util.fp(obj.cfp, heading, key);

% user configuration filename
heading = '[cfg]';
key = 'user';
out = util.fp(obj.cfp, heading, key);
obj.ucfg = out{1}{1};

% Initialize user state
obj.users = [];

% Iterate over root directories determining
%  which users are configured to use the
%  task controller
for k = 1:length(user_dirs)
    
    obj = scan_user_dirs(obj, obj.ucfg, user_dirs{k}{1});
    
end

end


% Scan all home directories in a given root directory
%  for users configured to use the task controller
function obj = scan_user_dirs(obj, CFG_FILENAME, USR_ROOT)

usrdirs = dir(USR_ROOT);   % perform a directory listing to list all users

n = length(usrdirs);       % number of directories found

new_usr_cnt = 1;           % count of new active users

cur_usr_cnt = length(obj.users);  % count of existing users


% iterate over all home directories in this root
for k = 1:n,
    
    cur_usr_path = strcat(USR_ROOT, '/', usrdirs(k).name);  % find .ctc file
    
    cur_file = strcat(cur_usr_path, '/', CFG_FILENAME);
    
    file_exists = length( dir(cur_file) );
    
    
    % if .ctc exists, read it
    if file_exists ~= 0,
        
        % add this user to active users
        users{new_usr_cnt} = usrdirs( k ).name;
        
        % read input directory
        heading = '[paths]';
        key = 'input';
        out = util.fp(cur_file, heading, key);
        iq{new_usr_cnt} = out{1};
        
        % read running directory
        key = 'active';
        out = util.fp(cur_file, heading, key);
        rq{new_usr_cnt} = out{1};
        
        % read output directory
        key = 'output';
        out = util.fp(cur_file, heading, key);
        oq{new_usr_cnt} = out{1};
        
        % always local user
        user_location = 'local';
        
        % construct new user structure
        tmp.username = users{new_usr_cnt};
        tmp.iq = iq{new_usr_cnt};
        tmp.rq = rq{new_usr_cnt};
        tmp.oq = oq{new_usr_cnt};
        tmp.user_location = user_location;
        tmp.aw = 0;   % possibly remove
        
        % add user to list
        obj.users{cur_usr_cnt + new_usr_cnt} = tmp;
        
        % increment new user count
        new_usr_cnt = new_usr_cnt + 1;
       
    end
    
    % sort the user structure alphabetically according to username
    [DC I]    = sort(obj.users.username);
      % where 
      %   DC is the sorted list of usernames which are not needed
      %   I is the permutation vector used to sort
    
      % Apply permutation vector to user structure.
      obj.users = obj.users(I);
    
end

end


%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA