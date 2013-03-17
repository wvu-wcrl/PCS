classdef OutageNakagamiDR < handle
    
    % Computes average outage probability with diversity reception
    
    % by S. Talarico
    
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
        C                 % Number of cooperative transmitters
        Omega_j           % Power of each transmitter
        Xi                % coefficients X_i
        li                % terms used to compute X_i
        TableDir
    end
    
    properties (GetAccess='private' , SetAccess='private')
        % These are private so that they hopefully won't get stored when doing a save command
        
    end
    
    methods
        % constructor
        function obj = OutageNakagamiDR( varargin )
            
            
            obj.Omega_i = varargin{1};
            obj.m = varargin{2};
            obj.m_i = varargin{3};
            obj.C = varargin{4};
            obj.Omega_j  = varargin{5};
            
            % determine the number of networks and interferers
            [obj.N obj.M] = size( obj.Omega_i );
            
            % distinction between the two cases:
            % 1- The normalized received powers are the same for all the
            % transmitters;
            % 2- The normalized received powers are all different for the
            % transmitters;
            
            if length(unique(obj.Omega_j))==1 || obj.C==1
                obj.Omega_j=obj.Omega_j(1);
                obj.m=obj.m(1);
            elseif length(unique(obj.Omega_j))==obj.C
                obj.ComputeXi();
            else
                fprintf('Error');
                return;
            end
            
            obj.TableDir = varargin{6};
            
            if length(unique(obj.Omega_j))==1 || obj.C==1
                IndexTable = [obj.TableDir 'IndicesEM' int2str( obj.M ) 'm' int2str(obj.m) 'mi' int2str(obj.m_i) '.mat'];
            elseif length(unique(obj.Omega_j))==obj.C && length(unique(obj.m))==1
                IndexTable = [obj.TableDir 'IndicesM' int2str( obj.M ) 'm' int2str(obj.m(1)) 'mi' int2str(obj.m_i) '.mat'];
            end
            
            if length(unique(obj.m))==1
                % either create or load the file
                try
                    % try to load the file
                    load( IndexTable, 'indices','coefficients' );
                    
                    % it loaded, assign results to indices
                    obj.indices = indices;
                    obj.coefficients = coefficients;
                catch
                    
                    % distinction between the two cases:
                    % 1- The normalized received powers are the same for all the
                    % transmitters;
                    % 2- The normalized received powers are all different for the
                    % transmitters;
                    
                    if length(unique(obj.Omega_j))==1 || obj.C==1
                        obj.ComputeIndicesE( );
                    elseif length(unique(obj.Omega_j))==obj.C && length(unique(obj.m))==1
                        obj.ComputeIndices( );
                    end
                    
                    indices = obj.indices;
                    coefficients = obj.coefficients;
                    save( IndexTable, 'indices','coefficients' );
                    
                end
            end
            
            
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
            obj.coefficients{1} = ones( 1, obj.M );
            
            for r=1:(obj.m-1)
                % initialize this member of the cell arrays
                obj.indices{r+1} = allVL1(obj.M,r);
                obj.coefficients{r+1} = ones( length(unique(obj.indices{r+1})),obj.M );
                for ell=1:r
                    if ( size( obj.m_i ) == 1)
                        % all m_i are the same
                        this_coef = gamma( ell + obj.m_i )/factorial(ell)/gamma( obj.m_i );
                        % the following line requires m_i to be integer valued
                        % this_coef = nchoosek( ell + obj.m_i - 1, obj.m_i - 1);
                        obj.coefficients{r+1}( ell,: ) = this_coef*ones(1,obj.M);
                    else
                        for node=1:obj.M
                            this_coef = gamma( ell + obj.m_i(node) )/factorial(ell)/gamma( obj.m_i(node) );
                            % the following line requires m_i to be integer valued
                            % this_coef = nchoosek( ell + obj.m_i(node) - 1, obj.m_i(node) - 1);
                            obj.coefficients{r+1}( ell,node ) = this_coef;
                        end
                    end
                end
            end
        end
        
        
        
        function obj = ComputeIndicesDM( obj,mDM )
            % create the indices structure
            % for r+1=1, the only set of indices is all zeros
            obj.indices{1} = zeros( 1, obj.M );
            obj.coefficients{1} = ones( 1, obj.M );
            
            for r=1:(mDM-1)
                % initialize this member of the cell arrays
                obj.indices{r+1} = allVL1(obj.M,r);
                obj.coefficients{r+1} = ones( length(unique(obj.indices{r+1})),obj.M );
                for ell=1:r
                    if ( size( obj.m_i ) == 1)
                        % all m_i are the same
                        this_coef = gamma( ell + obj.m_i )/factorial(ell)/gamma( obj.m_i );
                        % the following line requires m_i to be integer valued
                        % this_coef = nchoosek( ell + obj.m_i - 1, obj.m_i - 1);
                        obj.coefficients{r+1}( ell,: ) = this_coef*ones(1,obj.M);
                    else
                        for node=1:obj.M
                            this_coef = gamma( ell + obj.m_i(node) )/factorial(ell)/gamma( obj.m_i(node) );
                            % the following line requires m_i to be integer valued
                            % this_coef = nchoosek( ell + obj.m_i(node) - 1, obj.m_i(node) - 1);
                            obj.coefficients{r+1}( ell,node ) = this_coef;
                        end
                    end
                end
            end
        end
        
        
        function obj = ComputeIndicesE( obj )
            % create the indices structure
            % for r+1=1, the only set of indices is all zeros
            obj.indices{1} = zeros( 1, obj.M );
            obj.coefficients{1} = ones( 1, obj.M );
            
            for r=1:(obj.C*obj.m-1)
                % initialize this member of the cell arrays
                obj.indices{r+1} = allVL1(obj.M,r);
                obj.coefficients{r+1} = ones( length(unique(obj.indices{r+1})),obj.M );
                for ell=1:r
                    if ( size( obj.m_i ) == 1)
                        % all m_i are the same
                        this_coef = gamma( ell + obj.m_i )/factorial(ell)/gamma( obj.m_i );
                        % the following line requires m_i to be integer valued
                        % this_coef = nchoosek( ell + obj.m_i - 1, obj.m_i - 1);
                        obj.coefficients{r+1}( ell,: ) = this_coef*ones(1,obj.M);
                    else
                        for node=1:obj.M
                            this_coef = gamma( ell + obj.m_i(node) )/factorial(ell)/gamma( obj.m_i(node) );
                            % the following line requires m_i to be integer valued
                            % this_coef = nchoosek( ell + obj.m_i(node) - 1, obj.m_i(node) - 1);
                            obj.coefficients{r+1}( ell,node ) = this_coef;
                        end
                    end
                end
            end
        end
        
        
        function obj = GenerateTable(obj,k,mi)
            
            % generate the index of the vector l that we will use to compute Xi
            
            A1=[];
            l=k*ones(1,(obj.C-2));
            A1=[A1;l];
            stop=sum(l==mi);
            while stop~=(obj.C-2)
                [~,index]=min(l);
                
                if (obj.C-2)==2
                    if  length(unique(l))==1
                        l(1)=l(1)+1;
                        l(2:(obj.C-2))=k;
                    elseif (length(unique(l(1:1:(obj.C-2))))==1 && sum(l(1:1:(obj.C-2))~=1)==3 )&& length(unique(l))~=1
                        if l(index)+1==l(index-1)
                            l(index)=l(index)+1;
                            l((obj.C-2)-1:1:(obj.C-2))=k;
                        else
                            l(index)=l(index)+1;
                            l((obj.C-2)-1:1:(obj.C-2))=k;
                        end
                    else
                        l(index)=l(index)+1;
                        if index==(obj.C-2)-1
                            l((obj.C-2))=k;
                        end
                    end
                else
                    if  length(unique(l))==1
                        l(1)=l(1)+1;
                        l(2:(obj.C-2))=k;
                    elseif (length(unique(l((obj.C-2)-2:1:(obj.C-2))))==1 && sum(l((obj.C-2)-2:1:(obj.C-2))~=1)==3 )&& length(unique(l))~=1
                        if l(index)+1==l(index-1)
                            l(index)=l(index)+1;
                            l((obj.C-2)-1:1:(obj.C-2))=k;
                        else
                            l(index)=l(index)+1;
                            l((obj.C-2)-1:1:(obj.C-2))=k;
                        end
                    else
                        l(index)=l(index)+1;
                        if index==(obj.C-2)-1
                            l((obj.C-2))=k;
                        end
                    end
                end
                stop=sum(l==mi);
                A1=[A1;l];
            end
            obj.li=A1;
            
        end
        
        
        function obj =ComputeXi(obj)
            % compute the set of Xi
            Ti=zeros(1,obj.C*sum(obj.m));
            
            u=obj.Omega_j'./(obj.m)';
            if obj.C==1
                Ti=[zeros(1,obj.m-1),1];
            else
                for i=1:obj.C
                    for k=1:obj.m(i)
                        if obj.C==2
                            T=((-1)^(sum(obj.m)-obj.m(i)))*u(i)^k*factorial(obj.m(1)+obj.m(2)-k-1)*(1/u(i)-1/u(1+((1-i)>=0)))^(k-obj.m(1)-obj.m(2))/(u(1)^obj.m(1)*u(2)^obj.m(2)*factorial(obj.m(1+((1-i)>=0))-1)*factorial(obj.m(i)-k));
                            Ti(k+sum(obj.m(1:i-1))*(i>1))=T;
                        elseif obj.C==3
                            T=0;
                            for l1=k:obj.m(i)
                                D= factorial(l1+obj.m(2+((2-i)>=0))-k-1)*(1/u(i)-1/u(2+((2-i)>=0)))^(k-l1-obj.m(2+((2-i)>=0)))/(factorial(obj.m(2+((2-i)>=0))-1)*factorial(l1-k));
                                T=T+((-1)^(sum(obj.m)-obj.m(i)))*u(i)^k*factorial(obj.m(i)+obj.m(1+((1-i)>=0))-l1-1)*(1/u(i)-1/u(1+((1-i)>=0)))^(l1-obj.m(i)-obj.m(1+((1-i)>=0)))/(u(1)^obj.m(1)*u(2)^obj.m(2)*u(3)^obj.m(3)*factorial(obj.m(1+((1-i)>=0))-1)*factorial(obj.m(i)-l1))*D;
                            end
                            Ti(k+sum(obj.m(1:i-1))*(i>1))=T;
                        elseif obj.C>3
                            T=0;
                            obj.GenerateTable(k,obj.m(i));
                            [N1,M1]=size(obj.li);
                            for lk=1:N1
                                F=1;
                                for s=1:obj.C-3
                                    F= factorial(obj.li(lk,s)+obj.m(s+1+((s+1-i)>=0))-obj.li(lk,s+1)-1)*(1/u(i)-1/u(s+1+((s+1-i)>=0)))^(obj.li(lk,s+1)-obj.li(lk,s)-obj.m(s+1+((s+1-i)>=0)))/(factorial(obj.m(s+1+((s+1-i)>=0))-1)*factorial(obj.li(lk,s)-obj.li(lk,s+1)))*F;
                                end
                                D= factorial(obj.li(lk,M1)+obj.m(obj.C-1+((obj.C-1-i)>=0))-k-1)*(1/u(i)-1/u(obj.C-1+((obj.C-1-i)>=0)))^(k-obj.li(lk,M1)-obj.m(obj.C-1+((obj.C-1-i)>=0)))/(factorial(obj.m(obj.C-1+((obj.C-1-i)>=0))-1)*factorial(obj.li(lk,M1)-k))*F;
                                T=T+((-1)^(sum(obj.m)-obj.m(i)))*u(i)^k*factorial(obj.m(i)+obj.m(1+((1-i)>=0))-obj.li(lk,1)-1)*(1/u(i)-1/u(1+((1-i)>=0)))^(obj.li(lk,1)-obj.m(i)-obj.m(1+((1-i)>=0)))/(prod(u'.^obj.m)*factorial(obj.m(1+((1-i)>=0))-1)*factorial(obj.m(i)-obj.li(lk,1)))*D;
                            end
                            Ti(k+sum(obj.m(1:i-1))*(i>1))=T;
                        end
                    end
                end
            end
            obj.Xi=Ti;
        end
        
        
        
        function epsilon = ComputeSingleOutage( obj, Gamma, Beta, p)
            % computes the outage for a single set of beta, gamma, and p
            % averaged over the N networks
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            
            % determine how many SNR points
            NumberBeta = length( Beta );
            
            % initialize epsion
            epsilon = zeros(1,NumberBeta);
            
            % loop over the N networks
            if length(unique(obj.Omega_j))==1 || obj.C==1
                
                % loop over the N networks
                for trial=1:obj.N
                    sum_s = zeros(1,NumberBeta);
                    for s=0:obj.C*obj.m-1
                        sum_r = zeros(1,NumberBeta);
                        for r=0:s
                            sum_ell = zeros(1,NumberBeta);
                            for ellset=1:size( obj.indices{r+1}, 1)
                                elli = obj.indices{r+1}(ellset,:); % the vector of indices
                                [L,~]=size(obj.coefficients{r+1});
                                index=((1:obj.M)-1)*L+(elli+1);
                                coef = obj.coefficients{r+1}(index); % the multinomial coefficients
                                factors = (repmat(coef.*obj.Omega_i_norm(trial,:).^elli,length(Beta),1))./(((repmat(Beta,obj.M,1))'.*repmat(obj.m*obj.Omega_i_norm(trial,:)/obj.Omega_j,length(Beta),1)+1).^(repmat(elli+obj.m_i,length(Beta),1)));
                                sum_ell = sum_ell + prod( (p*factors + (1-p)*repmat((elli==0),length(Beta),1))' );
                            end
                            sum_r = sum_r + z.^(-r)*sum_ell/factorial(s-r);
                        end
                        sum_s = sum_s + ((Beta./obj.Omega_j*obj.m*z).^s).*sum_r;
                    end
                    epsilon = epsilon + 1 - sum_s.*exp(-Beta./obj.Omega_j*obj.m*z);
                end
            elseif length(unique(obj.Omega_j))==obj.C
                for trial=1:obj.N
                    for j=1:obj.C
                        
                        if length(unique(obj.m))~=1
                            IndexTable = [obj.TableDir 'IndicesM' int2str( obj.M ) 'm' int2str(obj.m(j)) 'mi' int2str(obj.m_i) '.mat'];
                            % either create or load the file
                            try
                                % try to load the file
                                load( IndexTable, 'indices','coefficients' );
                                
                                % it loaded, assign results to indices
                                obj.indices = indices;
                                obj.coefficients = coefficients;
                            catch
                                                                
                                obj.ComputeIndicesDM(obj.m(j));
                                
                                indices = obj.indices;
                                coefficients = obj.coefficients;
                                save( IndexTable, 'indices','coefficients' );

                            end
                        end

                        for n=1:obj.m(j)
                            sum_n = zeros(1,NumberBeta);
                            for u=0:n-1
                                sum_k = zeros(1,NumberBeta);
                                for k=0:u
                                    sum_ell = zeros(1,NumberBeta);
                                    for ellset=1:size( obj.indices{k+1}, 1)
                                        elli = obj.indices{k+1}(ellset,:); % the vector of indices
                                        [L,~]=size(obj.coefficients{k+1});
                                        index=((1:obj.M)-1)*L+(elli+1);
                                        coef = obj.coefficients{k+1}(index); % the multinomial coefficients
                                        factors = (repmat(coef.*obj.Omega_i_norm(trial,:).^elli,length(Beta),1))./(((repmat(Beta,obj.M,1))'.*repmat(obj.m(j)*obj.Omega_i_norm(trial,:)/obj.Omega_j(j),length(Beta),1)+1).^(repmat(elli+obj.m_i,length(Beta),1)));
                                        sum_ell = sum_ell + prod( (p*factors + (1-p)*repmat((elli==0),length(Beta),1))' );
                                    end
                                    sum_k = sum_k + z.^(-k)*sum_ell/factorial(u-k);
                                end
                                sum_n=sum_n+((Beta.*obj.m(j).*z/obj.Omega_j(j)).^u).*sum_k;
                            end
                            T=obj.Xi(n+sum(obj.m(1:j-1))*(j>1));
                            epsilon = epsilon + T.*ones(1,NumberBeta)- T.*exp(-Beta.*obj.m(j).*z/obj.Omega_j(j)).*sum_n;
                        end
                    end
                end
            else
                fprintf('Error');
                return;
            end
            
            epsilon = epsilon/obj.N;
            
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

