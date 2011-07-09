classdef OutageNakagami < handle
    
    % Computes average outage probability for N networks, each of size M
    
    properties
        Beta              % SINR threshold
        Gamma             % Average signal-to-noise ratio(SNR) at unit distance (Vector)
        p                 % Probability of collisions
        m                 % Nakagami shape factor for the source link
        m_i               % Nakagami factor for the interfereres (length M vector)
        M                 % Number of nodes
        N                 % Number of networks
        Omega_i           % Power of each interferer, can be N by M, where N is the number of networks 
        indices           % The set of indices summing to r
        coefficients      % The multinomial coefficients used inside the outage probability's product  
        Omega_i_norm      % Power normalized by m_i. (Could become private)
    end
    
    properties (GetAccess='private' , SetAccess='private')
        % These are private so that they hopefully won't get stored when doing a save command

    end
    
    methods
        % constructor
        function obj = OutageNakagami( varargin )
            
            % first three arguments are: Omega_i, m, m_i
            obj.Omega_i = varargin{1};
            obj.m = varargin{2};
            obj.m_i = varargin{3};
            
            % determine the number of networks and nodes
            [obj.N obj.M] = size( obj.Omega_i );
            
            % fourth argument is the location of the directory of index tables
            if (nargin == 4)
                TableDir = varargin{4};
                
                % build the name of the index table
                IndexTable = [TableDir 'IndicesM' int2str( obj.M ) 'm' int2str(obj.m) '.mat'];
                
                % either create or load the file
                try
                    % try to load the file
                    load( IndexTable, 'indices' );
                    
                    % it loaded, assign results to indices
                    obj.indices = indices; 
                    
                catch
                    % it did not load, so create the index tables
                    obj.ComputeIndices( );
                    
                    % save it
                    indices = obj.indices;
                    save( IndexTable, 'indices' );                    
                end               
                
            else
                % no directory specified, create the index tables
                obj.ComputeIndices( );
            end

            
            % compute the coefficients
            obj.ComputeCoefficients( );
                
            % normalize by m_i
            if (length( obj.m_i ) == 1)
                obj.Omega_i_norm = obj.Omega_i./repmat( obj.m_i, obj.N, obj.M);
            else
                obj.Omega_i_norm = obj.Omega_i./repmat( obj.m_i, obj.N, 1);
            end       
                       
        end
        
        function obj = ComputeIndices( obj )
            % create the indices structure
            % for r+1=1, the only set of indices is all zeros
            obj.indices{1} = zeros( 1, obj.M );
            
            for r=1:(obj.m-1)
                % initialize this member of the cell arrays
                % note that this is a sparse matrix
                % yet it actually takes more space to save it as a sparse!
                % and also more processing time to compute outage
                % obj.indices{r+1} = sparse( allVL1(obj.M,r) );
                obj.indices{r+1} = allVL1(obj.M,r);
                
            end
        end
        
        function obj = ComputeCoefficients( obj )
            % create the coefficients structure
            obj.coefficients{1} = ones( 1, obj.M );
            
            for r=1:(obj.m-1)
                % initialize this member of the cell arrays
                obj.coefficients{r+1} = ones( size( obj.indices{r+1} ) );
                for ell=1:r
                    if ( size( obj.m_i ) == 1)
                        % all m_i are the same
                        this_coef = gamma( ell + obj.m_i )/factorial(ell)/gamma( obj.m_i );
                        % the following line requires m_i to be integer valued
                        % this_coef = nchoosek( ell + obj.m_i - 1, obj.m_i - 1);
                        obj.coefficients{r+1}( obj.indices{r+1} == ell ) = this_coef;
                    else
                        for node=1:obj.M
                            this_coef = gamma( ell + obj.m_i(node) )/factorial(ell)/gamma( obj.m_i(node) );
                            % the following line requires m_i to be integer valued
                            % this_coef = nchoosek( ell + obj.m_i(node) - 1, obj.m_i(node) - 1);
                            obj.coefficients{r+1}( (obj.indices{r+1}(:,node) == ell), node ) = this_coef;
                        end
                    end
                end
            end
        end
        
        function epsilon = ComputeSingleOutage( obj, Gamma, Beta, p )
            % computes the outage for a single set of beta, gamma, and p
            % averaged over the N networks
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            
            % determine how many SNR points
            NumberSNR = length( Gamma );
            
            % initialize epsion
            epsilon = zeros(1,NumberSNR);
            
            % loop over the N networks
            for trial=1:obj.N
                sum_s = zeros(1,NumberSNR);
                for s=0:obj.m-1
                    sum_r = zeros(1,NumberSNR);
                    for r=0:s
                        sum_ell = 0;
                        for ellset=1:size( obj.indices{r+1}, 1)
                            elli = obj.indices{r+1}(ellset,:); % the vector of indices
                            coef = obj.coefficients{r+1}(ellset,:); % the multinomial coefficients
                            factors = coef.*obj.Omega_i_norm(trial,:).^elli./( (Beta*obj.m*obj.Omega_i_norm(trial,:)+1).^(elli+obj.m_i) );
                            sum_ell = sum_ell + prod( p*factors + (1-p)*(elli==0) );
                        end
                        sum_r = sum_r + z.^(-r)*sum_ell/factorial(s-r);
                    end
                    sum_s = sum_s + ((Beta*obj.m*z).^s).*sum_r;
                end
                epsilon = epsilon + 1 - sum_s.*exp(-Beta*obj.m*z);
            end
            
            epsilon = epsilon/obj.N;
            
            % note that the Gamma, Beta, p properties of the class are never actually set
            
        end
        
        function epsilon = ComputeOutage( obj, Gamma, Beta, p )
            % computes the outage for vector Beta, Gamma, and p
            
            % output will be a 3-D matrix
            %   dimension 1 is Gamma
            D1 = length( Gamma );
            %   dimension 2 is Beta
            D2 = length( Beta );
            %   dimension 3 is p
            D3 = length( p );
            
            epsilon = zeros(D1,D2,D3);  % preallocate
            
            for j=1:D2
                for k=1:D3
                    epsilon(:,j,k) = obj.ComputeSingleOutage( Gamma, Beta(j), p(k) );
                end
            end
            
            % note that the Gamma, Beta, p properties of the class are never actually set
        end
    end
    
end

