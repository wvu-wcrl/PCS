function Xi = UniformPlacement( M, varargin )
% places n points uniformly in a circle of radius r_max
%
% Usage:
%   Xi = UniformPlacement( M, [r_max], [r_min], [d_min], [N], [d_min_tx], [rx_loc] )
%   Xi = the node locations as a complex row vector
%   M =  number of nodes in the network
%   r_max = radius of the circle (default = 1)
%   r_min = guard zone around receiver (default = 0)
%   d_min = minimum spacing between interferers (default = 0) 
%   N = number of networks to generate (default = 1)
%   d_min_tx = radius of guard zone around desired transmitter (at location 1)
%   rx_loc = rx_location
 
% determine radius of the circle
if (nargin > 1)
    r_max = varargin{1};
else
    r_max = 1;
end

% determine guard zone around the receiver
if (nargin > 2)
    r_min = varargin{2};
else
    r_min = 0;
end

% determine guard zone around the interferers
if (nargin > 3)
    d_min = varargin{3};
else
    d_min = 0;
end

% determine the number of networks to generate
if (nargin > 4)
    N = varargin{4};
else
    N = 1;
end

% radius of guard zone around desired transmitter
if (nargin > 5)
    d_min_tx = varargin{5};
else
    d_min_tx = 0;
end

% location of the receiver
if (nargin > 6 )
    rx_loc = varargin{6};
else
    rx_loc = 0;
end

% transmitter is one unit away from the receiver
tx_loc = rx_loc - 1;

% initialize (preallocate)
Xi = zeros( N, M );

maxtries = 1e6;

net = 0;
while (net < N)
    counter = 0;
    this_net = zeros(1,M);
    
    for i=1:maxtries;
        node = unifrnd(-r_max,r_max) + 1i*unifrnd(-r_max,r_max);
        
        % check to make sure it is inside the annulus and not too close to desired transmitter
        if ( (abs( node-rx_loc ) > r_min) && (abs(node) < r_max) && (abs( node-tx_loc ) >= d_min_tx) )
            if ~counter
                % first node, always add to the set
                counter = counter+1;
                this_net(1,counter) = node;
            elseif ( min(abs( this_net(1,1:counter) - node ))  >= d_min )               
                % now make sure it is not too close to the other nodes in this network
                counter = counter+1;
                this_net(1,counter) = node;
            end
        end
        
        % done with this net
        if (counter == M)
            net = net + 1;
            % fprintf( 'done with net %d\n', net );
            Xi( net, : ) = this_net;
            break;
        end
        
    end
    
end

% shift the network so it is centered about the desired transmitter
Xi = Xi - rx_loc;

end


                    