% main.m
%
% main task controller loop
%
% Version 1
% 11/2016
% Terry Ferrett
%
% outline
% 1. scan user input directories for input files
% 2. decide which user to service
% 3. launch tasks for the user with the least active tasks
%
%     Copyright (C) 2016, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.
%
%  POTENTIAL CAVEAT
%   Added '&' to end of all system() commands in an attempt to
%       prevent hanging.
%  Keep an eye on this one, for example, spawing zombies or leaking memory.
%   Added pause at end of every system command for flow control.
% next attempt - copy operation needs more delay than move
% future impl
%  only use moves
%  group permissions
%
%  Notes
%   removed logic to check for user existence in function
%   consume_output
%   if needed, bring back from main_bak.m


function main(obj, ss)

%%% main-specific initialization
% task controller running states
IS_START = strcmp(ss, 'start');
IS_RESUME = strcmp(ss, 'resume');
IS_SHUTDOWN = strcmp(ss, 'shutdown');

% timers
timer_users = tic;       % user list update timer
timer_heartbeat = tic;   % heartbeat timer
heartbeat_oneshot=1;     % touch the heartbeat file
 

% initialize previously executing user file so that the task controller
%  begins execution from the user who was executing tasks prior to
%  the last task controller shutdown
%
%  outline of functionality
%    at top of main
%       move ceu file to peu file
%    in scheduler function
%       restore peu file and delete
%       save currently executing user in every user loop iteration
init_peu( obj );
% AWS ignore for now

% primary execution loop
while(1)
    
    if IS_START || IS_RESUME
        
        % get user priorities
        obj = get_user_priorities(obj);
        
        % iterate over all users scheduling tasks in a round-robin fashion
        schedule_tasks_rr(obj);
        
    end
    
    % scan global output queue and place completed tasks in user output
    %  directory
    if IS_START || IS_RESUME || IS_SHUTDOWN
        consume_output(obj);
    end
    
    % Pause for tsp seconds before making another pass
    pause(obj.tsp);
    
    % get .mat files in global running and output queues
    mat_ext = '/*.mat';
    [fl nfoq] = get_files_in_dir(obj.gq.oq{1}, mat_ext);
    [fl nfrq] = get_files_in_dir(obj.gq.rq{1}, mat_ext);
    
    % if no files are left in the output queue and the tc is in shutdown mode,
    %  break out of main control loop
    Q_EMPTY = (nfoq == 0)&&(nfrq == 0);
    if IS_SHUTDOWN && Q_EMPTY,  break;   end
    
    % check for new users every 2 minutes
    if toc(timer_users) > 120,
        obj.init_users();
        timer_users = tic;
    end
    
    % touch heartbeat file to indicate that TC has not crashed
    c1 = heartbeat_oneshot;
    c2 = toc(timer_heartbeat) > obj.hb_period;
    if c1 | c2,
        heartbeat(obj);
        timer_heartbeat = tic;
        heartbeat_oneshot = 0;
    end
    
end

end


% initialize previously executing user file so that the task controller
%  begins execution from the user executing while the task controller
%  was shut down
function init_peu( obj, k )

% move currently executing user file to previously executing user file
op = ['sudo mv' ' ' obj.ceu{1} ' ' obj.peu{1} '&'];

perform_fs_op(op);

end


% get user priorities from file
function obj = get_user_priorities(obj)

% open file containing user priorities
pf_fid = fopen(obj.upfp{1});

% if no priority file found, return from function.
if pf_fid == -1,
    fprintf('ERROR: Priority file\n');
    fprintf('  %s', obj.upfp{1});
    fprintf('not found. Using default priorities.');
    return;
end

% loop over priority file reading usernames and assigning priorities
%  to user structures
EOF = -1;  % the function fgets() represents the end of a file as -1

% read first line from user priority file
[cur_line] = fgets(pf_fid);

while cur_line ~= EOF,
    % tokenize line read from file
    %  username
    %  priority
    [un pr_string] = strtok(cur_line);
    
    % find user having this username
    ui = get_user_index(obj, un);
    
    % if user not found,
    %  skip priority assignment
    %  output error message
    %  read next line
    if ui == -1,
        fprintf('Priority file contains username which does not');
        fprintf(' exist in user structure: %s.\n', un);
    else
        % if user found, assign priority to data structure
        
        % convert string-form priority to integer-form
        pr_dbl = str2double(pr_string);
        
        % assign priority
        obj.users{ui}.pr = pr_dbl;
    end
    
    %  read next line from priority file
    [cur_line] = fgets(pf_fid);
    
end

% close priority file
fclose(pf_fid);

end



% perform round-robin task scheduling
function schedule_tasks_rr(obj)

nu = length(obj.users);           % number of users in system

% if this is the first scheduling iteration after starting the task
%  controller, determine the index of the last user to execute during
%  the task controller's previous run

% the purpose of this function is to set the first user and task to execute
% in the event that
%   1. the task controller was interrupted
%   2. a user was blocked from executing tasks from lack of workers
[fu tu] = get_user_state( obj );

% iterate over all users launching tasks as appropriate
for k = fu:nu,
    
    % determine if user has tasks to launch
    mat_ext = '/*.mat';
    [tl nt] = get_files_in_dir(obj.users{k}.iq{1}, mat_ext);

    % if the user has no task files to launch, continue to next user
    if nt == 0, continue; end
    
    % if the user has launched as many or more tasks than
    %  allowed by the task threshold, continue to next user
    [ ite ] = is_thresh_exceeded( obj, k );
    if ite, continue; end    
    % The task threshold is defined as the maximum number of tasks
    %  which this user can execute.
    %  The maximum number is determined by the user's priority,
    %   all other user priorities in the system, and the number
    %   of workers
    %  Tu = ceil( Nw * Pu/sum_m=1^Na Pm )
    %   where
    %  Tu - threshold
    %  Nw - total number of workers in the system
    %  Pu - Priority value for this user
    %  Na - number of active users
    %  Pm - Priority value for the m-th user
    
    % save the name of the currently executing user so that the
    % task controller can return to the user in the event of a crash
    save_cur_exec_user( obj, k );
    
    % determine the number of queue slots available to execute user tasks
    %wa = get_workers_available(obj);
    qslots = get_queue_slots_available(obj);
    % AWS possible change
    
    % iterate over tasks and launch as workers become available
    for m = 1:tu(k),
        
        % if user has no tasks remaining, continue to next user
        if nt == 0, break; end
        
        % if no queue slots available, pause and wait until workers become free
        if (qslots <= 0)
            % save the index of the user's currently executing task
            %  and return to this task when a worker becomes available
            obj.bu.tu = tu(k) - m + 1;
            
            % save username of blocked user
            obj.bu.username = obj.users{k}.username;
            
            % set blocked state to 1
            obj.bu.isbl = 1;
            
            fprintf('Waiting for workers to become free\n');
            fprintf('to launch tasks for user \n %s.', obj.users{k}.username);
            
            % return to main loop
            return;
        end
        
        % for the k-th user in
        %   obj.users,
        % launch the m-th available task in task list
        %   tl
        % AWS: modify task transfer
        launch_user_tasks(obj, k, tl, m);
        
        % decrement number of user tasks available
        nt = nt - 1;
        
        % decrement workers available
        qslots = qslots - 1;
        
    end
    
    % for all subsequent users after the first, we are guaranteed to
    %  want to start from the first task
    ft = 1;
    
end

end


% determine if the current user has exceeded the
%  maximum number of tasks permitted for execution
%  simultaneously
function ite = is_thresh_exceeded( obj, k )

%%% outline
% 1. compute number of tasks user has in iq and rq
% 2. compute list of unique users in iq and rq
% 3. get list of priorities for all unique users
% 4. get priority for current user
% 5. compute user maximum tasks - proportion of workers user is allotted
% 6. determine if user has exceeded maximum tasks

%%% 1. compute number of tasks user has in iq and rq
cur_user = obj.users{k}.username;

% iq
pgiq = obj.gq.iq{1};
cmd = [ 'ls' ' ' pgiq '|' 'grep -i' ' ' cur_user '|' 'wc' ];
[DC iqt_str] = system(cmd);
iqt_dbl = str2double(strtok(iqt_str));

% rq
pgrq = obj.gq.rq{1};
cmd = [ 'ls' ' ' pgrq '|' 'grep -i' ' ' cur_user '|' 'wc' ];
[DC rqt_str] = system(cmd);
rqt_dbl = str2double(strtok(rqt_str));

% total number of active tasks in input and running queues
uat = iqt_dbl + rqt_dbl;

% if the user has no tasks in either queue, clearly
%  they are under the threshold. break.
if uat == 0; ite = 0; return; end


%%% 2. compute list of unique users in iq and rq
cmd = [ 'ls' ' ' pgiq ' ' pgrq ...
    '|sort |fgrep -i .mat |' 'cut -d ''_'' -f1 |uniq' ];
[ DC users_str ] = system(cmd);

% break out of the function if the queue is empty,
%  indicating that user has not exceeded the threshold
if isempty(users_str); ite = 0; return; end

% form a cell array of strings where each string is a username
users_cell = textscan(users_str, '%s');

% get number of unique users
Nau = length(users_cell{1});


%%% 3. get a list of priorities for all unique users
pr_au = zeros(1,Nau);
for m = 1:Nau,
    % get index for current user
    uind = get_user_index( obj, users_cell{1}{m} );

    % get user priority
    pr_au(m) = obj.users{uind}.pr;
end


%%% 4. get priority for current user
cind = get_user_index( obj, cur_user );
pr_cu = obj.users{cind}.pr;


%%% 5. compute user maximum tasks -
%%%    proportion of workers user is allotted
umt = ceil( obj.nw * pr_cu / sum( pr_au ) );

%%% 6. determine if user has exceeded maximum tasks
ite = uat > umt;

end


% get index of user executing tasks during previous task controller run
function [fu tu] = get_user_state( obj )

% restore user execution state in the event that
%  user was interrupted by task controller stoppage - peu
%  user was blocked because no cores were available - bu


% check for previous user execution file existence
if exist(obj.peu{1}, 'file')
    
    % if file exists, open and read the username contained in the file
    user_fid=fopen(obj.peu{1});
    username = fgetl(user_fid);
    fclose(user_fid);
    
    % get user structure index corresponding to this username
    fu = get_user_index(obj, username);
    
    % delete previous user execution file
    op = ['sudo rm' ' ' obj.peu{1} ' ' '&'];
    perform_fs_op(op);
    
    % start executing task index from beginning
    tu = get_tasks_per_user(obj);
    
    % check for existence of blocked user
elseif obj.bu.isbl == 1,
    
    % get user structure index corresponding to blocked user's username
    fu = get_user_index(obj, obj.bu.username);
    
    % start executing tasks from the index of the last task to execute
    %  before blocking
    tu = get_tasks_per_user(obj);
    tu(fu) = obj.bu.tu;
    
    % user is no longer blocked
    obj.bu.isbl = 0;
    
else
    
    % If the previously executing user file does not exist, start from
    % first user
    fu = 1;
    
    tu = get_tasks_per_user(obj);
    
end

end


% get the number of tasks to launch per user during each execution
% round
function tu = get_tasks_per_user(obj)
% set tasks to launch per user based on priority
nu = length(obj.users);    % iterate over all users
for k = 1:nu
    % number of tasks to launch is equal to user priorty
    tu(k) = obj.users{k}.pr;
end
end

% save to file the username of user currently executing tasks
function save_cur_exec_user( obj, k )

user_fid=fopen(obj.ceu{1}, 'w+');

fprintf(user_fid, '%s', obj.users{k}.username);

fclose(user_fid);

end


% for the k-th user in
%   obj.users,
% launch the m-th available task in task list
%   tl
function launch_user_tasks(obj, k, tl, m)

% define PCS system user
PCSUSER = 'pcs';

% path to user input task file
puif = strcat(obj.users{k}.iq, '/', tl(m).name);

% path to user running task file
purf = strcat(obj.users{k}.rq, '/', tl(m).name);

% path to global (AWS) input queue
pgiq = obj.gq.iq;
% AWS: set input queue path in configuration file to global AWS input queue

% append username to task file
fn = tl(m).name;
afn = [obj.users{k}.username '_' obj.users{k}.user_location '_' fn];

%REMOVED AMPERSAND
% copy user input file into user running queue
op = ['sudo cp' ' ' puif{1} ' ' purf{1}];
perform_fs_op(op);

%REMOVED AMPERSAND
% change user running queue file ownership from root to user
op = ['sudo chown' ' ' obj.users{k}.username ':' ...
    obj.users{k}.username ' ' purf{1}];
perform_fs_op(op);

%REMOVED AMPERSAND
% change user input file ownership to pcs user
% op = ['sudo chown' ' ' PCSUSER ':' PCSUSER ' ' puif{1} ' ' '&'];
op = ['sudo chown' ' ' PCSUSER ':' PCSUSER ' ' puif{1}];
perform_fs_op(op);

%REMOVED AMPERSAND
% move user file into input queue
op = ['sudo mv -f' ' ' puif{1} ' ' pgiq{1} '/' afn];
perform_fs_op(op);

% AWS: possibly copy tasks to AWS instance queue
end


% execute shell command to manipulate filesystem
function perform_fs_op(op)

% log operation being executed
%fprintf('%s\n', op);

[st res] = system(op);

%fprintf('\n');

pause(0.05);

end


% calculate the number of queue slots available
%  to execute tasks
function qslots = get_queue_slots_available(obj)

% perform directory listing in global running and input queues,
% and count the number of files in each
ext_in = '/*.mat';
[fl nfrq] = get_files_in_dir(obj.gq.rq{1}, ext_in);
[fl nfiq] = get_files_in_dir(obj.gq.iq{1}, ext_in);

% total number of workers available
nw = obj.nw;

% Queue buffer. specifies number of tasks which may be placed
%  in the input queue beyond the number of workers.
% The purpose of this buffer is to maintain sufficient tasks
%  in the input queue such that the workers always have tasks
%  available to execute.
qbuf = obj.qbuf;

% to determine the number of queue slots available,
%  add the number of workers to the queue buffer and
%  subtract the number of tasks in the global running
%  and input queues
qslots = ( nw + qbuf ) - ( nfrq + nfiq );

end

% touch heartbeat file indicate that TC has not crashed
function heartbeat(obj)

% path to heartbeat file
hb_file = [ obj.hb_path filesep 'tc_' obj.gq_name ];

% touch implemented as file opening and closing
fid = fopen(hb_file, 'w+'); fclose(fid);

end

% Move completed tasks from the global output queue to the owning user's
%  output queue
function consume_output(obj)

% get files in global output queue
ext_in = '/*.mat';
[fl nf] = get_files_in_dir(obj.gq.oq{1}, ext_in);

% iterate over all files in output queue, moving to owning user output
% queue
for k = 1:nf,
    
    % username of the owning user is part of the task filename - read it
    [username location] = get_username_location_from_file( fl(k).name );
    
    % get user structure index corresponding to this username
    user_ind = get_user_index(obj, username);
    
    % perform move operation
    consume_output_file(obj, fl(k).name, user_ind);
    
end

end


% Get username and location from task filename.
function [username location] = get_username_location_from_file( name );

% username is first field
[username suffix] = strtok(name, '_');

% location is second field
[location suffix] = strtok(suffix, '_');

end


% All users existing in the system are stored in cell array
%   obj.users
% Get the array index of the user having the same name as the input name
%   username
function user_ind = get_user_index(obj, username)

% total number of users
nu = length( obj.users );

% default index if no user found - should cause error
user_ind = -1;

% iterate over all users and find a structure name that matches
%  the given name
for k = 1:nu,
    
    user_match = strcmp( obj.users{k}.username, username );
    
    if user_match,  user_ind = k; break;  end
    
end


end

% move completed task file from global to user output queue
function consume_output_file(obj, output_task_filename, user_ind)

[ownership_name ownership_group] = ...
    get_file_ownership( obj.users{user_ind}.username,...
    obj.users{user_ind}.user_location );

% username and location are no longer needed as part of filename -
%  moving back to user's own output queue
[on] = remove_username_loc_from_filename( output_task_filename );

% get paths to output queues
[ puoq ] = get_path_user_output_queue( obj.users{user_ind}.oq{1});
[ pgoq ] = get_path_global_output_queue( obj.gq.oq{1} );

% return ownership of task file to user
op = ['sudo chown' ' ' ownership_name ':' ownership_group ...
    ' ' pgoq '/' output_task_filename ' ' '&'];
perform_fs_op(op);

% move task file from global output queue to user output queue
op = ['sudo mv -f' ' ' pgoq '/'  output_task_filename ' ' puoq '/' on ' ' '&'];
perform_fs_op(op);

% remove task file from user's running queue - execution complete
[ purq ] = get_path_user_running_queue( obj.users{user_ind}.rq{1} );
clear_from_user_running_queue( on, purq );

end

% this code is deprecated, only one location exists. web users directory is gone
function [ownership_name ownership_group] = get_file_ownership( username, ...
    user_location )
ownership_name = username;           % shorten the name
ownership_group = username;

end

% remove username and location from task filename
function [on] = remove_username_loc_from_filename( name )

[username suffix] = strtok(name, '_');

[location suffix] = strtok(suffix, '_');

on = suffix(2:end);

end

% get path to user output queue
function puoq = get_path_user_output_queue( oq )

puoq = oq;

end

% get path to user running queue
function purq = get_path_user_running_queue( oq )

purq = oq;

end


% get path to global output queue
function pgoq = get_path_global_output_queue( oq )

pgoq = oq;

end


% clear task file from user running queue
function clear_from_user_running_queue( on, purq )

if findstr( on, 'failed')
    prefix = on(1:end-11);
    suffix = '.mat';
    on = [prefix suffix];
end

op = ['sudo rm' ' ' purq '/'  on ' ' '&'];
perform_fs_op(op);

end

% Get a list of files in the given path having the given extension
%  dir_in: Linux filesystem path of form
%      /n1/n2/...
%    where n1, n2 ... are directory names
%  note that dir_in must not be terminated with '/'
function [fl nf] = get_files_in_dir(dir_in, ext_in)

% form full search string
srch = strcat(dir_in, ext_in);

% perform file search
fl = dir( srch );

% number of files found
nf = length(fl);

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
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
%     USA