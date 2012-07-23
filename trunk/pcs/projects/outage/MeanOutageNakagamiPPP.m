classdef MeanOutageNakagamiPPP < handle
    
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
        integral          % Computation of the integral
        Omega_i_norm      % Power normalized by m_i. (Could become private)
        alpha             % path loss exponent
        radius                 % radius of the circular area
        delta             % inner radius
        iterations        % number of iterations that are used for the pmf 
        lambda            % density of interferer
    end
    
    properties (GetAccess='private' , SetAccess='private')
        % These are private so that they hopefully won't get stored when doing a save command
        
    end
    
    methods
        % constructor
        function obj = MeanOutageNakagamiPPP( varargin )
            
          
            obj.radius = varargin{1};
            obj.delta  = varargin{2};
            obj.alpha = varargin{3};
            obj.m = varargin{4};
            obj.m_i = varargin{5};
            obj.Beta = varargin{6};
            obj.iterations= varargin{7};
            obj.lambda= varargin{8};
            
            obj.M=obj.iterations;

            TableDir = varargin{9};
            
            % build the name of the index table
            IndexTable = [TableDir 'Indices_' 'm' int2str(obj.m) 'Beta' num2str(10*log10(Beta)*1000) '.mat'];
            
            % either create or load the file
            try
                % try to load the file
                load( IndexTable, 'indices' );
                
                % it loaded, assign results to indices, integral and coefficients
                obj.indices = indices;
                obj.integral= integral;
                obj.coefficients= coefficients;
                
            catch
                % it did not load, so create the index tables
                obj.ComputeIndices( );
                
                % save it
                if TableDir~=[]
                    indices = obj.indices;
                    integral=obj.integral;
                    coefficients=obj.coefficients;
                    save( IndexTable, 'indices', 'integral','coefficients' );
                end
            end
            
            
            
            
            
        end
        
        function obj = ComputeIndices( obj )
            % create the indices structure
            % for r+1=1, the only set of indices is all zeros
            
            for i=1:obj.iterations
                obj.indices{i,1} = zeros( 1, i );
                obj.coefficients{i,1} = ones( 1, i );
                
                numInt=unique(obj.indices{i,1});
                this_integral=obj.indices{i,1};
                
                for ind=1:length(numInt)
                    this_integral(find((this_integral-numInt(ind))==0))=(obj.m_i^obj.m_i)/((obj.Beta*obj.m)^(obj.m_i+numInt(ind)))*(functionI(obj.m_i,obj.m,numInt(ind),obj.Beta,obj.alpha,obj.radius^obj.alpha)-functionI(obj.m_i,obj.m,numInt(ind),obj.Beta,obj.alpha,obj.delta^obj.alpha));
                end
                
                obj.integral{i,1} =this_integral;
                
                
                for r=1:(obj.m-1)
                    % initialize this member of the cell arrays
                    if i==1
                        obj.indices{i,r+1} = r;
                    else
                    obj.indices{i,r+1} = allVL1(i,r);
                    end
                    obj.coefficients{i,r+1} = ones( size( obj.indices{i,r+1} ) );
                    
                    numInt=unique(obj.indices{i,r+1});
                    this_integral=obj.indices{i,r+1};
                    
                    for ind=1:length(numInt)
                        this_integral(find((this_integral-numInt(ind))==0))=(obj.m_i^obj.m_i)/((obj.Beta*obj.m)^(obj.m_i+numInt(ind)))*(functionI(obj.m_i,obj.m,numInt(ind),obj.Beta,obj.alpha,obj.radius^obj.alpha)-functionI(obj.m_i,obj.m,numInt(ind),obj.Beta,obj.alpha,obj.delta^obj.alpha));
                    end
                    
                    obj.integral{i,r+1}=this_integral;
                    
                    for ell=1:r
                        if ( size( obj.m_i ) == 1)
                            % all m_i are the same
                            this_coef = gamma( ell + obj.m_i )/factorial(ell)/gamma( obj.m_i );
                            %                         % the following line requires m_i to be integer valued
                            %                         % this_coef = nchoosek( ell + obj.m_i - 1, obj.m_i - 1);
                            obj.coefficients{i,r+1}( obj.indices{i,r+1} == ell ) = this_coef;
                        else
                            for node=1:obj.M
                                this_coef = gamma( ell + obj.m_i(node) )/factorial(ell)/gamma( obj.m_i(node) );
                                % the following line requires m_i to be integer valued
                                % this_coef = nchoosek( ell + obj.m_i(node) - 1, obj.m_i(node) - 1);
                                obj.coefficients{i,r+1}( (obj.indices{i,r+1}(:,node) == ell), node ) = this_coef;
                            end
                        end
                    end
                    
                end

            end
        end
        
        function epsilon = ComputeSingleOutage( obj, Gamma, p )
            % computes the outage for a single set of gamma, and p
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            % determine how many SNR points
            NumberSNR = length( Gamma );
            
            % initialize epsilon
            epsilon = zeros(1,NumberSNR);
            sum_s = zeros(1,NumberSNR);
            
            for s=0:obj.m-1
                sum_r = zeros(1,NumberSNR);
                for r=0:s
                    sum_ppp=0;
                    for num_ppp=1:obj.iterations
                        sum_ell = 0;
                        for ellset=1:size( obj.indices{num_ppp,r+1}, 1)
                            elli = obj.indices{num_ppp,r+1}(ellset,:); % the vector of indices
                            coef = obj.coefficients{num_ppp,r+1}(ellset,:);% the multinomial coefficients
                            coef_integral = obj.integral{num_ppp,r+1}(ellset,:);
                            factors = coef.*coef_integral;
                            
                            sum_ell = sum_ell + prod( (repmat(p',1,num_ppp).*repmat(factors*(2/(obj.alpha*(obj.radius)^2)),length(p),1).*(1-(obj.delta/obj.radius)^2)^-1 + repmat((1-p)',1,num_ppp).*repmat((elli==0),length(p),1))') ;
                        end
                        sum_ppp=sum_ppp+ sum_ell*poisspdf(num_ppp,obj.lambda.*pi*(obj.radius^2-obj.delta^2)); % Poisson's pmf
                    end
                    
                    sum_r = sum_r + z.^(-r)*sum_ppp/factorial(s-r);
                end
                sum_s = sum_s + ((obj.Beta*obj.m*z).^s).*sum_r;
            end
            epsilon = 1 - sum_s.*exp(-obj.Beta*obj.m*z);
            
            
        end
        
        function epsilon = ComputeOutage( obj, Gamma, p )
            % computes the outage for vector Gamma, and p
            
            % output will be a 2-D matrix

            D1 = length( Gamma );
            D2 = length( p );
            
            epsilon = zeros(D1,D2);  % preallocate
            
            for j=1:D1
                
                epsilon(j,:) = obj.ComputeSingleOutage( Gamma(j), p );
                
            end
            

        end
    end
    
end