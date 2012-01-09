% Test the file parser by reading an example
%   data file.
%
% Version 1
% 2/27/2011
% Terry Ferrett

% Data file name.
data_example = 'test.dat';


% Heading and key to read from data file.
heading = '[Heading_1]';
key = 'key_1';
% Call to file reader.
out = util.fp(data_example, heading, key);


% Heading and key to read from data file.
heading = '[Heading_1]';
key = 'key_2';
% Call to file reader.
out = util.fp(data_example, heading, key);


% Heading and key to read from data file.
heading = '[Heading_2]';
key = 'key_1';
% Call to file reader.
out = util.fp(data_example, heading, key);

