classdef MeanOutageNakagamiShad < OutageNakagami
    
    % Computes outage probability averaged over a BPP in the shadowed case, given the size of the
    % annular network arena and the number of nodes placed there
    % by S. Talarico
    
    properties
        Beta              % SINR threshold
        Gamma             % Average signal-to-noise ratio(SNR) at unit distance (Vector)
        p                 % Probability of collisions
        integral          % Computation of the inner integral
        alpha             % path loss exponent
        r_net             % outer radius of the anular area
        r_ex              % inner radius of the anular area
        c_i               % takes into account DS spread-spectrum by c_i=(G/h)*(P_0/P_i), where:
        % - G: processing Gain;
        % - h: Chip factor.
        sigma             % standard deviation
        TableDir          % link to indices tables
        trials            % number of trial used
%%%%%%%%% These properties are inherited from OutageNakagami %%%%%%%%%             
%       m                 % Nakagami shape factor for the source link
%       m_i               % Nakagami factor for the interfereres (length M vector)
%       M                 % Number of nodes
%       indices           % The set of indices summing to r
%       coefficients      % The multinomial coefficients used inside the outage probability's product
%%%%%%%%% %   
    end
    
    properties (GetAccess='private' , SetAccess='private')
        % These are private so that they hopefully won't get stored when doing a save command
    end
    
    methods
        % constructor
        function obj = MeanOutageNakagamiShad( r_net, r_ex, alpha, m, m_i, M , PG, sigma, trials , varargin)
            
            if nargin==9
                TableDir=[];
            else
                TableDir=varargin{1};
            end   
            
            % create indices and coefficients by inheriting from OutageNakagami
            obj@OutageNakagami(zeros(1,M),m,m_i,TableDir);
            
            obj.r_net = r_net;
            obj.r_ex  = r_ex;
            obj.alpha = alpha;
            obj.c_i=PG;
            obj.sigma= sigma;
            obj.trials= trials;
            
            
        end
        
        function obj = ComputeIntegral( obj, Beta )
            
            numInt=unique(obj.indices{1});
            this_integral=obj.indices{1};
            for ind=1:length(numInt)
                syms x;
                zeta1=-erf((obj.sigma^2*(log(10))^2-50*obj.alpha*log(x*obj.c_i*obj.r_net^obj.alpha))/(5*sqrt(2)*obj.alpha*obj.sigma*log(10)));
                zeta2=-erf((obj.sigma^2*(log(10))^2-50*obj.alpha*log(x*obj.c_i*obj.r_ex^obj.alpha))/(5*sqrt(2)*obj.alpha*obj.sigma*log(10)));
                y= ((x/obj.m_i)^numInt(ind))*(zeta1-zeta2)*exp(obj.sigma^2*(log(10))^2/(50*obj.alpha^2))*x^(-(2/obj.alpha+1))/(((x*Beta*obj.m/obj.m_i)+1)^(numInt(ind)+obj.m_i));
                fun=char(y);
                f=inline(vectorize(fun),'x');
                this_integral(find((this_integral-numInt(ind))==0))=quad(f,0,10000);
            end
            obj.integral{1} =this_integral;

            for r=1:(obj.m-1)
                this_integral=obj.indices{r+1};
                for ind=1:length(numInt)
                    syms x;
                    zeta1=-erf((obj.sigma^2*(log(10))^2-50*obj.alpha*log(x*obj.c_i*obj.r_net^obj.alpha))/(5*sqrt(2)*obj.alpha*obj.sigma*log(10)));
                    zeta2=-erf((obj.sigma^2*(log(10))^2-50*obj.alpha*log(x*obj.c_i*obj.r_ex^obj.alpha))/(5*sqrt(2)*obj.alpha*obj.sigma*log(10)));
                    y= ((x/obj.m_i)^numInt(ind))*(zeta1-zeta2)*exp(obj.sigma^2*(log(10))^2/(50*obj.alpha^2))*x^(-(2/obj.alpha+1))/(((x*Beta*obj.m/obj.m_i)+1)^(numInt(ind)+obj.m_i));
                    fun=char(y);
                    f=inline(vectorize(fun),'x');
                    this_integral(find((this_integral-numInt(ind))==0))=quad(f,0,10000);
                end
                obj.integral{r+1}=this_integral;             
            end
        end
        
        function epsilon = ComputeSingleOutage( obj, Gamma, Beta, p )
            
            % evaluate the cdf at Gamma^-1
            z = 1./Gamma;
            % determine how many SNR points
            NumberSNR = length( Gamma );
            
            % initialize epsion
            epsilon = zeros(1,NumberSNR);
            sum_s = zeros(1,NumberSNR);
            
            d=normrnd(0,obj.sigma,1,obj.trials);
            for s=0:obj.m-1
                sum_r = zeros(1,NumberSNR);
                for r=0:s
                    % Evaluate the outer integral by MonteCarlo simulation
                    for t=1:obj.trials
                        sum_ell = 0;
                        obj.ComputeIntegral(Beta./(10.^(d(t)./10)) );
                        for ellset=1:size( obj.indices{r+1}, 1)
                            elli = obj.indices{r+1}(ellset,:); % the vector of indices
                            coef = obj.coefficients{r+1}(ellset,:); % the multinomial coefficients
                            coef_integral = obj.integral{r+1}(ellset,:);
                            factors = coef.*coef_integral;
                            sum_ell = sum_ell + prod( (repmat(p',1,obj.M).*repmat(factors*(1/(obj.alpha*obj.c_i^(2/obj.alpha))),length(p),1).*(obj.r_net^2-obj.r_ex^2)^-1 + repmat((1-p)',1,obj.M).*repmat((elli==0),length(p),1))') ;
                        end
                        sum_r_trial(t)= sum_ell/factorial(s-r).*((Beta./(10.^(d(t)./10))*obj.m*z).^s).*(z).^(-r)*exp(-Beta./(10.^(d(t)./10))*obj.m*z);
                    end
                    sum_r = sum_r+ mean(sum_r_trial); 
                end
                sum_s = sum_s + sum_r;
            end
            epsilon = 1 - sum_s; 
        end
        
        function epsilon = ComputeOutage( obj, Gamma, Beta, p )
            % computes the outage for vector Gamma, Beta and p
            
            % output will be a 3-D matrix
            %   dimension 1 is Gamma
            D1 = length( Gamma );
            %   dimension 2 is Beta
            D2 = length( Beta );
            %   dimension 3 is p
            D3 = length( p );
            
            epsilon = zeros(D1,D2,D3);  % preallocate
            
            for j=1:D1
                for k=1:D2
                    k
                    epsilon(j,k,:) = obj.ComputeSingleOutage( Gamma(j),Beta(k), p );
                end
            end
            
        end
    end
end