function [ThresholdStar full_rank rate] = HstructEval( HStruct )
% Evaluates the threshold and checks rank.
%
% Input:
%        HStruct: A structure array corresponding to the parity-check matrix.
%                 In particular, H(j).loc_ones gives the location of the ones in the jth row of H matrix.
%
% Output:
%        ThresholdStar: Threhold value based on the input HStruct.
%        full_rank:     Set to 1 if full rank criteria is met.

row = length(HStruct);
col = max([HStruct(:).loc_ones]);
col_weight = zeros(1,col);
row_weight = zeros(1,row);

for i=1:row
    temp = HStruct(i).loc_ones;
    row_weight(i) = sum(temp~=0); % row_weight for each row.
    col_weight(temp) = col_weight(temp) + 1; % col_weight is keeping counting.
end

edges = sum(row_weight);  % total edges number.
uni_col_weight = unique(col_weight);  % unique col_weight.
uni_col_weight_no = size(uni_col_weight , 2); % unique col_weight number.
lambda = zeros(1, max(uni_col_weight));       % degree distribution in edge perspective.

% This part generates the column degree distribution in descending order.
for i=1:uni_col_weight_no
    temp_index = col_weight == uni_col_weight(i);
    lambda(max(uni_col_weight) - uni_col_weight(i) + 1) = sum(col_weight(temp_index))/edges;
end

% provide degree distribution for rho, to avoid the students generate the matrix with different check node degrees.
uni_row_weight = unique(row_weight);
uni_row_weight_no = size(uni_row_weight , 2);
rho = zeros(1, max(uni_row_weight));

% This part generates the row degree distribution in descending order.
for i=1:uni_row_weight_no
    temp_index = row_weight == uni_row_weight(i);
    rho(max(uni_row_weight) - uni_row_weight(i) + 1) = sum(row_weight(temp_index))/edges;
end

ThresholdStar = Threshold(rho,lambda);

% check rank.
fprintf( 'Checking the rank of the input parity-check matrix.\n' );
full_rank = 1;  % assume it is full rank.

k = col-row;
n = col;

% check all but the first row.
for i=2:row
    % make sure the last m columns contain a diagonal of zeros.
    if ( max( HStruct(i).loc_ones ) ~= i+k )
        full_rank = 0;
        fprintf( 'Rank check failed at row %d.\nInput parity-check matrix is not full-rank.\n', i );
        break;
    end
end

% first row can have a one in the last element (if tailbiting).
if ( max( HStruct(1).loc_ones ) == n )
    weight_row_one = length( HStruct(1).loc_ones );
    % one in last element, so exclude it and check again.
    if ( max( HStruct(1).loc_ones(1:(weight_row_one-1)) ) ~= k+1 )
        full_rank = 0;
    end
end

rate = k/n;
end