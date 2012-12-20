% plot_time_trials.m
%
%  plot trials versus time for cluster and stand-alone CML simulation
%
%  inputs
%   cmlroot - path to cml
%
%   job_fn  - name pcs job in jobout
%
%   scenario- cml scenario
%
%   record  - cml record
%
%   fontsize - fontsize to use for figure plotting
%
%   fig_out_dir - directory to store .fig output


function plot_time_trials(cmlroot, job_fn, scenario, record, fontsize, fig_out_dir)

[ tss trss ] = load_timing_data_local(cmlroot, scenario, record);
 % tss - time sample standalone
 % trss - trial sample standalone


[ tsc trsc ni ] = load_timing_data_cluster( job_fn );
 % tsc - time sample cluster
 % trsc - trial sample cluster

 create_table_data_flat_text(ni, fig_out_dir, scenario, record);
 

[ fig_time ax_time ] = plot_timing_data( tss, trss, tsc, trsc );


label_figure();
format_figure( fig_time, ax_time, fontsize );
export_figure( fig_time, scenario, record, fig_out_dir );

end



function [tss trss] = load_timing_data_local( cmlroot, scenario, record )
cd(cmlroot);
CmlStartup;
[sim_param sim_state] = CmlPlot(scenario, record);
tss = sim_state.timing_data.time_samples;
trss = sim_state.timing_data.trial_samples;
end


function [ tsc trsc ni ] = load_timing_data_cluster( job_fn );

load(job_fn); % JobInfo struct in workspace

SP = JobInfo.JobID.SpeedProfile;

tsc = SP.ActualTime;
trsc = SP.NumProcessUnit;

ni = SP.NodeInfo;

end


function create_table_data_flat_text(ni, fig_out_dir, scenario, record)

[DataFileName] = [fig_out_dir filesep scenario '_' record '.dat'];

% extract timing info from job file
N = length(ni);

dfd = fopen(DataFileName, 'w');

for k = 1:N,

NodeName = ni{k}.NodeName;


TotalTrials = sum(ni{k}.NumProcessUnit);    % compute trials/sec
ElapsedTime = ni{k}.ProcessDuration(end) - ni{k}.ProcessDuration(1);
TrialsSec = TotalTrials/ElapsedTime;


fprintf(dfd, '%s,%f\n', NodeName, TrialsSec);

end


end



function [ fig_time ax_time ] = plot_timing_data( tss, trss, tsc, trsc )
fig_time = figure;
plot(tss,trss, tsc, trsc);
ax_time = gca;
end


function label_figure()
xlabel('Time (s)');
ylabel('Trials');
legend('Cluster', 'Single core');
end


function format_figure(fig_in, ax_in, fontsize)
fig_h = findall(fig_in);
text_h = findall(fig_h,'Type','text');
set(text_h,'FontSize', fontsize);

set(ax_in, 'FontSize', fontsize);
end


function export_figure(fig_in, scenario, record, fig_out_dir)
fig_filename = [fig_out_dir '/' scenario '_' int2str(record) '.fig'];
saveas( fig_in, fig_filename, 'fig' )
end
