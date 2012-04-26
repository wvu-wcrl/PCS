function [r_rec erasures_count] = DecBEC( r_rec, HStruct, max_iter )
% Performs erasures decoding of a linear code.
%
% Inputs
%      r_rec:	The decoder input. Must be a length-n vector with "-1" indicating erasure, "0" indicating data 0, and "1" indicating data 1.
%      HStruct: A structure array corresponding to the parity-check matrix.
%               In particular, H(j).loc_ones gives the location of the ones in the jth row of H.
%      max_iter:Maximum number of decoder iterations.
%
% Outputs
%      r_rec:	The decoded codeword.
%      erasures_count: A vector of length max_iter giving the number of uncorrected erasures after each iteration.
%
% Written by Matthew C. Valenti for WVU's EE 567, Spring 2012.

% initialize the erasures count.
erasures_count = zeros( max_iter, 1 );

% determine the number of rows in H.
num_rows_H = length( HStruct );

% loop through each iteration
for iter=1:max_iter
    % echo message (feel free to comment this out).
    % fprintf( 'Iteration %d\n', iter );

    % keep track of how many erasures were corrected in this iteration.
    num_corrections = 0;

    % loop through each check node (row of H).
    for row=1:num_rows_H
        % identify which variable nodes are connected to this check node.
        variable_nodes = HStruct( row ).loc_ones;

        % which variable nodes connected to this check nodeare erased?
        erased_edges = find( r_rec( variable_nodes) < 0 );

        % if exactly one variable node is erased, then correct it.
        if (length( erased_edges ) == 1)
            % determine which variable node was erased.
            erased_variable_node = HStruct(row).loc_ones(erased_edges);

            % determine the other variable nodes (the unerased ones).
            unerased_variable_nodes = setdiff( variable_nodes, erased_variable_node );

            % set the value of the erased variable node equal to the xor of the unerased variable nodes.
            r_rec( erased_variable_node ) = mod( sum( r_rec( unerased_variable_nodes ) ), 2);

            % update the count of the number of corrections.
            num_corrections = num_corrections + 1;

            % echo message (feel free to comment this out).
            % fprintf( '\tCheck node %d has corrected variable node %d, which is %d.\n', row, erased_variable_node, r_rec( erased_variable_node ) );
        end
    end

    % count remaining erasures.
    erasures_count( iter ) = sum( r_rec < 0 );

    % check for halting condition.
    if ~num_corrections
        % echo message (feel free to comment this out).
        % fprintf( 'No erasures could be corrected in this iteration. Halting\n' );

        erasures_count(iter:max_iter) = erasures_count( iter );

        % break out of the loop, since no more erasures can be corrected.
        break;
    end
end