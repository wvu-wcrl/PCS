classdef OutageNakagami < handle
    
    % Computes average outage probability for N networks, each of size M
    
    properties
        m                 % Nakagami shape factor for the source link
        m_i               % Nakagami factor for the interfereres (length M vector)
        M                 % Number of nodes
        N                 % Number of networks
        Omega_i           % Power of each interferer, can be N by M, where N is the number of networks 
        indices           % The set of indices summing to r
        coefficients      % The multinomial coefficients used inside the outage probability's product  
        Omega_i_norm      % Power normalized by m_i. (Could become private)
        Omega0            % Power of desired signal, set to indicate shadowing
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
            
            % Set Omega0 by defualt to non-shadowing
            obj.Omega0 = ones(1,obj.N);
                       
        end
        
        function obj = SetShadowing( obj, ShadowStd )
            % Set the shadowing for the desired signal
            fprintf( 'ShadowStd = %f\n', ShadowStd );
            obj.Omega0 = 10.^( sqrt( ShadowStd )*randn(1,obj.N)/10 );            
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
            % computes the outage for a single set of gamma, beta, and p
            % averaged over the N networks
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            
            % determine how many SNR points
            NumberSNR = length( Gamma );
            
            % initialize epsion
            epsilon = zeros(1,NumberSNR);
            
            % loop over the N networks
            for trial=1:obj.N
                % normalize Beta according to the desired-signal's shadowing
                BetaNorm = Beta/obj.Omega0(trial);
                sum_s = zeros(1,NumberSNR);
                for s=0:obj.m-1
                    sum_r = zeros(1,NumberSNR);
                    for r=0:s
                        sum_ell = 0;
                        for ellset=1:size( obj.indices{r+1}, 1)
                            elli = obj.indices{r+1}(ellset,:); % the vector of indices
                            coef = obj.coefficients{r+1}(ellset,:); % the multinomial coefficients
                            factors = coef.*obj.Omega_i_norm(trial,:).^elli./( (BetaNorm*obj.m*obj.Omega_i_norm(trial,:)+1).^(elli+obj.m_i) );
                            sum_ell = sum_ell + prod( p*factors + (1-p)*(elli==0) );
                        end
                        sum_r = sum_r + z.^(-r)*sum_ell/factorial(s-r);
                    end
                    sum_s = sum_s + ((BetaNorm*obj.m*z).^s).*sum_r;
                end
                epsilon = epsilon + 1 - sum_s.*exp(-BetaNorm*obj.m*z);
            end
            
            epsilon = epsilon/obj.N;
                        
        end
        
        function epsilon = ComputeSingleOutageSplatter( obj, Gamma, Beta, p, Fibp )
            % computes the outage for a single set of beta, gamma, p, and Fibp
            % averaged over the N networks
            % Accounts for adjacent-channel interference due to spectral splatter
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            
            % determine how many SNR points
            NumberSNR = length( Gamma );
            
            % initialize epsion
            epsilon = zeros(1,NumberSNR);
            
            % fprintf( 'Fibp = %f\n', Fibp );
            
            % loop over the N networks
            for trial=1:obj.N
                % normalize Beta according to the desired-signal's shadowing
                BetaNorm = Beta/obj.Omega0(trial);
                sum_s = zeros(1,NumberSNR);
                for s=0:obj.m-1
                    sum_r = zeros(1,NumberSNR);
                    for r=0:s
                        sum_ell = 0;
                        for ellset=1:size( obj.indices{r+1}, 1)
                            elli = obj.indices{r+1}(ellset,:); % the vector of indices
                            coef = obj.coefficients{r+1}(ellset,:); % the multinomial coefficients
                            factors = coef.*(obj.Omega_i_norm(trial,:)*Fibp).^elli./( (BetaNorm*obj.m*obj.Omega_i_norm(trial,:)*Fibp+1).^(elli+obj.m_i) );
                            factors1 = 2*coef.*(obj.Omega_i_norm(trial,:)*(1-Fibp)/2).^elli./( (BetaNorm*obj.m*obj.Omega_i_norm(trial,:)*(1-Fibp)/2+1).^(elli+obj.m_i) );
                            sum_ell = sum_ell + prod( p*(factors + factors1) + (1-3*p)*(elli==0) );
                        end
                        sum_r = sum_r + z.^(-r)*sum_ell/factorial(s-r);
                    end
                    sum_s = sum_s + ((BetaNorm*obj.m*z).^s).*sum_r;
                end
                epsilon = epsilon + 1 - sum_s.*exp(-BetaNorm*obj.m*z);
            end
            
            epsilon = epsilon/obj.N;
                       
        end
        
        function epsilon = ComputeOutage( obj, Gamma, Beta, p, varargin )
            % computes the outage for vector Beta, Gamma, and p
            % Gamma = Average signal-to-noise ratio(SNR) at unit distance (Vector)
            % Beta  = SINR threshold
            % p     = Probability of collisions
            
            % output will be a 3-D matrix
            %   dimension 1 is Gamma
            D1 = length( Gamma );
            %   dimension 2 is Beta
            D2 = length( Beta );
            %   dimension 3 is p
            D3 = length( p );
            
            % if defined, the fourth dimension is the fraction of inband power
            if (nargin==5)
                Fibp = varargin{1}; % fraction of inband power
                D4 = length( Fibp );
                epsilon = zeros( D1, D2, D3, D4 ); % preallocate
            else
                epsilon = zeros(D1,D2,D3);  % preallocate
            end
            
            % compute outage for each value of beta, p, and Fibp
            for j=1:D2
                for k=1:D3
                    if (nargin==5)
                        for q=1:D4
                            epsilon(:,j,k,q) = obj.ComputeSingleOutageSplatter( Gamma, Beta(j), p(k), Fibp(q) );
                        end
                    else
                        epsilon(:,j,k) = obj.ComputeSingleOutage( Gamma, Beta(j), p(k) );
                    end
                end
            end
            
        end
    end
    
end

