function [ActiveNodes, D_matrix] = ThinNetwork( Xi, arg2 )
% Function ThinNetwork thins a network by removing close points
%
% Usage:
%    [ActiveNodes, D_matrix] = ThinNetwork( Xi, d_min )
%    Xi = the node locations as a complex row vector
%    ActiveNodes = row vector with 1's in elements of active nodes
%                  and 0's in location of nodes that are thinned out.
%    D_matrix = distance matrix
%    This usage will thin nodes until the minimum distance is d_min
%
% Alternate Usage:
%   [ActiveNodes, D_matrix] = ThinNetwork( Xi, ActiveNodes )
%   This usage will thin out just one node

% determine the size of the network
n = length( Xi );

% The initial distance matrix
D_matrix = abs( repmat( Xi.', 1, n ) - repmat( Xi, n, 1 ) );
for i=1:n
    % Diagonal element represents distance to origin
    D_matrix(i,i) = abs(Xi(i));
end

% initialize the minimum distance
current_d_min = min(min(D_matrix));

% Determine if the second argument is scalar or matrix
if isscalar(arg2)
    
    % first argument is the minimum distance
    d_min = arg2;
    
    % preallocate the active nodes
    ActiveNodes = ones(1,n);   

else
    
    % first argument is the set of active nodes
    ActiveNodes = arg2;
    
    % initialize d_min
    epsilon = 1e-3;
    d_min = current_d_min + epsilon;
    
    % Deactivate elements in the d_min matrix
    for Disactive=find(~ActiveNodes)
        D_matrix( Disactive, : ) = NaN;
        D_matrix( :, Disactive ) = NaN;       
    end
end
   
while ( current_d_min < d_min )    
    
    % Find minimum distance of the active nodes
    [i,j] = find( D_matrix == min( min(D_matrix) ) );
    
    % [i,j] may have multiple entries, so pick the first
    i = i(1);
    j = j(1);
    
    % Diagonal element means point is too close to the origin
    if (i==j)
        Disactive = i;        
    else  % Need to decided which of two points to delete
            
        % Distance from point j to all points other than i
        j_dist = min( D_matrix( [1:(i-1) (i+1):n], j ) );
        
        % Distance from point i to all points other than j
        i_dist = min( D_matrix( [1:(j-1) (j+1):n], i ) );
        
        % pick the one with the closer other neighbor
        if (j_dist < i_dist)
            Disactive = j;
        else
            Disactive = i;
        end
        
    end
    
    ActiveNodes( Disactive ) = 0;
    D_matrix( Disactive, : ) = NaN;
    D_matrix( :, Disactive ) = NaN;  
    
    % Determine the new current minimum distance
    current_d_min = min(min(D_matrix));
    
end
                    