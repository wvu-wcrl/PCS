% SpPlot.m
% Plot and format speed profiler results.
%
% Inputs
%  p_sfig    Path to speed profile .fig file.
%  nc        Number of cores used in simulation.
%  fs        Font size to use in plot.
%  ac        Cell containing strings for annotation.
%  ap        Annotation position on plot.
%  axl       Axis limits for plot.
%  ep        Path for exporting .eps file of plot.
%
% Usage example
%  p_sfig = '/home/pcs/util/sp/output/SpeedProfile_2.fig';
%  nc = 384;      
%  fs = 16;       
%  mod = ['BPSK'];
%  code = ['Uncoded'];
%  chan = ['Rayleigh Fading'];
%  minber = ['BER threshold -- 1e-7'];
%  snr = ['E_b/N_0 -- 0:0.5:70 dB'];
%  ac = {mod, code, chan, minber, snr};       
%  ap = [ 0.8 0.43 0.4 0.4 ];
%  axl = [ 0 1000 10^(4) 10^(11) ];      
%  ep  = '/home/pcs/util/sp/output/SpeedProfile_2.eps';      
%
%  StPlot( p_sfig, nc, fs, ac, ap, axl, ep )
%
%     Last updated on 2/5/2013
%
%     Copyright (C) 2013, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function StPlot( p_sfig, nc, fs, ac, ap, axl, ep )

open(p_sfig);                % open speed test figure

fhd = gcf;                   % current figure handle

set(gca, 'YScale', 'log');   % set to log scale

axis(axl);                   % set meaningful axis values

plss(fhd);                   % set figure size to 1024x768

setzoom(fhd, axl);           % set axis limits

plfmt(fhd, fs);              % set font sizes and line widths

grid on;                     % enable grid

legend('Location', 'best');              % place legend out of the way of data

titlestr = sprintf('Trial Computation Rate - Single-core vs Cluster CML, %d cores', nc);
title(titlestr);

AnnotateStPlot( ac, ap, fs );  % annotate plot

print(fhd, '-depsc', '-r600', ep );   % export figure to eps

end


function AnnotateStPlot( ac, ap, fs )

a = annotation('textbox',ap);

set(a, 'String', ac)
set(a, 'FontSize', fs, 'FontWeight', 'bold')
set(a, 'LineStyle', 'none')

end


function plfmt(fhd, fs)

% Get axis handle
ah = get(fhd, 'CurrentAxes');

% Set size of all text to 18.
%c = findall(fig_handle_in);
set(ah, 'FontSize', fs);

d = findall(fhd,'Type','text');
set(d,'FontSize', fs);

%c = findall(axis_handle);
d = findall(ah,'Type','text');
set(d,'FontSize', fs);

% Set linewidth to 2.
line_handle = get(ah, 'Children');
set(line_handle,'LineWidth', 2);

grid on;
end


function plss(fhd)

% Blow up the figure
set(fhd, 'Position', [1 1 1024 768]);

% Printed size the same as on-screen size
set(fhd,'PaperPositionMode','auto')

end


function setzoom(fhd,zoom)
figure(fhd);
axis(zoom);
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
