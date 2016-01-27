function epsilon_star = Threshold(rho, lambda, x_spacing)
% Determines the decoding threshold epsilon_star for an erasure channel.
%
% Inputs
%     rho:          Check-node degree distribution (coefficients in descending order).
%     lambda:       Variable-node degree distribution (coefficients in descending order).
%     x_spacing:	OPTIONAL accuracy of the solution.
%
% Outputs
%      epsilo_star:	Threshold value of the given degree distribution.
%
% Written by Matthew C. Valenti and Xingyu Xiang for WVU's EE 567, Spring 2012.

if( nargin <3 || isempty(x_spacing) )
    x_spacing = 1e-5;
end

initial_value = 1e-3;

x =initial_value:x_spacing:1;

% if abs(sum(lambda)-1)>1e-03
%     error('myApp:argChk', 'The sum of vnodDeg should be 1.');
% end

if abs(sum(rho)-1)>1e-03
    error('myApp:argChk', 'The sum of cnodDeg should be 1.');
end

y=x./polyval(lambda, (1 - polyval(rho, (1-x))));

epsilon_star = min(y(y>=x));