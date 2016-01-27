% format_figures.m
% Script to increase line and text sizes.
%
% Input - Figure handle
% Output - Figure handle after font and line size adjustments

function fmt_fig(fig_handle_in)

% Get axis handle
axis_handle = get(fig_handle_in, 'CurrentAxes');

% Set size of all text to 18.
%c = findall(fig_handle_in);
set(axis_handle, 'FontSize', 26);

d = findall(fig_handle_in,'Type','text');
set(d,'FontSize', 26);

%c = findall(axis_handle);
d = findall(axis_handle,'Type','text');
set(d,'FontSize', 26);

% Set linewidth to 2.
line_handle = get(axis_handle, 'Children');
set(line_handle,'LineWidth', 2);

grid on;
