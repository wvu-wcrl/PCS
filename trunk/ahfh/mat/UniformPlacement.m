function Xi = UniformPlacement( n, r_min, r_max )

Xi = zeros(1,n);
counter = 0;
while (counter<n)
    node = unifrnd(-r_max,r_max) + 1i*unifrnd(-r_max,r_max);
    if ( (abs(node) > r_min) && (abs(node) < r_max) )
        counter = counter+1;
        Xi(counter) = node;
    end
end


                    