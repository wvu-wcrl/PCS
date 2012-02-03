% plot_job_time.m
%
% plot the per-node and overall time spent computing a job using the
% cluster 
%
% syntax
%    plot_job_time( data, time, nodelist )
%
%    data is a matrix
%           each column represents a timestep
%           each row represents a node
%
%   time is a vector
%           every entry represents time elapsed since time 0
%
%   nodelist is a cell array of strings encoding the node names

function plot_job_time(data, time, nodelist)

mrk_array = ['-o' ; '-x' ; '-+' ; '-*' ; '-s' ; '-d' ; '-v' ; '-^' ; '-<'];

timefig = figure;           % create a figure


[n m] = size( data );      % get the number of nodes and timesteps


for k = 1:n,                   % plot the computation times for each node
   plot( time, data(k,:), mrk_array(k,:) );
   hold on;    
end

nodelist{end+1} = 'cluster';   % add legend entry for cluster

legend(nodelist);           % add legend


xlabel('Time (s)');           % label axes
ylabel('Trials');


fmt_fig(timefig);            % increase font sizes,
end