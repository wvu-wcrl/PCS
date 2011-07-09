function ActiveNodes = Matern( Xi, d_min, varargin )
% Function Matern thins a network using Ganti 2011.  Nodes are thinned
% until the minimum spacing is d_min
%
% Usage:
%    Acti = ThinNetwork( Xi, d_min, [opts] )
%    Xi = the node locations as a complex row vector
%    ActiveNodes = row vector with 1's in elements of active nodes
%                  and 0's in location of nodes that are thinned out.
%    D_matrix = distance matrix
%    [opts] = 0 no guard zone around reference TX or RX
%             1 guard zone around reference RX (DEFAULT)
%             2 guard zone around reference TX
%             3 guard zone around reference TX and RX
%

% determine the size of the network
n = length( Xi );

% initialize mark matrix
mark = rand(1,n);

% intialize ActiveNodes
ActiveNodes = zeros(1,n);

% default option
opts = 1;

if (nargin == 3)
    opts = varargin{1};
end

% fprintf( 'opts = %d\n', opts );


if (opts == 1)||(opts == 3)
    % place guard zone around receiver
    d_vector = abs( Xi );
    mark( d_vector < d_min ) = 0;
end

if (opts == 2)||(opts == 3)
    % place guard zone around transmitter
    % assumed to be located at 1
    d_vector = abs( Xi - 1 );
    mark( d_vector < d_min ) = 0;
end

% go through each node until they are all marked as 0 or 1
while sum( (mark>0).*(mark<1) )
    % pick a random node not marked 0 or 1
    z_ind = find( (mark>0).*(mark<1) );
    i = z_ind( randi( length(z_ind) ) );
    
    % determine distance to all other nodes
    d_vector = abs( Xi - Xi(i) );
    
    % identify those within distance d_min
    neighborhood =  d_vector < d_min ;
    
    % make active iff this mark greater than all others in neighborhood
    if ~sum( (mark(i) - mark( neighborhood )) < 0 )
        ActiveNodes(i) = 1;
        mark( neighborhood ) = 0;  % all other points deactivated
        mark(i) = 1; % harden this point
    end        
       
end


end

