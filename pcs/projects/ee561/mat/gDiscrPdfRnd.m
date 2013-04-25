function [] = gDiscrPdfRnd()
%
% Generic Discrete Pdf Random Numbers Generator.
% 
% This function extracts a scalar/vector/matrix of numbers that are randomly distributed over a discrete set of N elements.
% The probability (mass) distribution function is user-defined. This function is implemented within a .mex file.
% 
% syntax:
%   Y = gDiscrPdfRnd(pdf)       % Y is an integer from 1 to length(pdf), randomly generated according to pdf.
%   Y = gDiscrPdfRnd(pdf,n)     % Y is a n-by-n matrix of intergers from 1 to length(pdf), randomly generated according to pdf.
%   Y = gDiscrPdfRnd(pdf,n,m)   % Y is a n-by-m matrix of intergers from 1 to length(pdf), randomly generated according to pdf.
% 
% pdf is a vector; the i-th component of pdf is the probability for the i-th element to be extracted.
% 
% REMARK: sum(pdf) does NOT have to be equal to one. Due to the limited
% precision of double numbers, such condition is often hard to be verified. For this
% reason, THE ONLY CONDITION FOR THE ELEMENTS OF pdf IS TO BE NONNEGATIVE 
% (i.e. pdf(i) >= 0 , for each 1 <= i <= length(pdf)).
%     
% 
% Example 1:
%   gDiscrPdfRnd([1/6 1/6 1/6 1/6 1/6 1/6],3,2)
%   It creates a 3-by-2 matrix of intergers equally distributed from 1 to 6.
%   It is identical to the following:
%   gDiscrPdfRnd([1 1 1 1 1 1],3,2)
%
% Eexample 2:
%   It generates 10000 samples of a triangular pdf and displys the frequencies.
%   ^
%   |
%   |           *
%   |       *   *   *
%   |___*___*___*___*___*______
%       1   2   3   4   5
%
%   pdf = [1/9 2/9 3/9 2/9 1/9];  % or simply pdf = [1 2 3 2 1];
%   Y = gDiscrPdfRnd(pdf,10000,1);
%   hist(Y,[1:length(pdf)]);
% 
% Example 3:
%   t = [1:0.2:3*pi]; pdf = 1 + t.*sin(t); pdf = pdf - min(pdf); % pdf looks sinusoidal.
%   bar(pdf,'r');
%   Y = gDiscrPdfRnd(pdf,100000,1);
%   figure;
%   hist(Y,[1:length(pdf)]);
% 
% Author: Gianluca Dorini (g.dorini@ex.ac.uk)
% For compiling type: mex gDiscrPdfRnd.c
%
%
% For large random arrays, randp seriously surcharges the RAM memory,
% whereas gDiscrPdfRnd limits the memory use. In what follows the details of the comparison are given.
% 
% Speed comparison: randp is faster for large data blocks and gDiscrPdfRnd is faster for smaller ones:
% 
%   K = 200000; N = 100;
%   T_RandP = zeros(K,1);
%   T_gDiscrPdfRnd = zeros(K,1);
%   for m=1:K
%       tic; R = randp([1 3 2],N,1); T_RandP(m) = toc;
%       tic; R = gDiscrPdfRnd([1 3 2],N,1); T_gDiscrPdfRnd(m) = toc;
%   end
%   T_RandP_Avg = mean(T_RandP)
%   T_gDiscrPdfRnd_Avg = mean(T_gDiscrPdfRnd)
%
%   K = 200000; N = 100;
%   T_RandP_Avg =           7.6610e-005
%   T_gDiscrPdfRnd_Avg =    3.1635e-005
% 
%   K = 2000; N = 1000;
%   T_RandP_Avg =           0.00016113
%   T_gDiscrPdfRnd_Avg =    0.00017680
%
%   K = 2000; N = 10000;
%   T_RandP_Avg =           0.0009249
%   T_gDiscrPdfRnd_Avg =    0.0016024


error('gDiscrPdfRnd mex file absent, type mex gDiscrPdfRnd.c to compile.');