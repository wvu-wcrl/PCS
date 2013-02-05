% expr_sp2.m
%  Plot results of performing speed profiling using
%   scenario - SpeedProfile, record - 2

addpath('/home/pcs/util/sp/supp');

p_sfig = '/home/pcs/util/sp/output/SpeedProfile_2.fig';
nc = 384;
fs = 16;
mod = ['BPSK'];
code = ['Uncoded'];
chan = ['Rayleigh Fading'];
minber = ['BER threshold -- 1e-7'];
snr = ['E_b/N_0 -- 0:0.5:70 dB'];
ac = {mod, code, chan, minber, snr};
%%%
ap = [0.5 0.5 0.4 0.4];
axl = [0  1000 10^(4) 10^(11)];
ep = '/home/pcs/util/sp/output/SpeedProfile_2_1.eps'; 

SpPlot(p_sfig, nc, fs, ac, ap, axl, ep);



ap = [0.5 0.5 0.4 0.4];
axl = [0  5000 10^(4) 10^(11)];
ep = '/home/pcs/util/sp/output/SpeedProfile_2_2.eps'; 
SpPlot(p_sfig, nc, fs, ac, ap, axl, ep);


