function indices = inverse_transform_sampling(weights)
% Input:
% weights: unnormalized weights of particles from previous part
% Output:
% indices: indices of resampled particles

N = size(weights,2);
cdf = zeros(1,N);
indices = zeros(1,N);

cdf(1) = weights(1);
for i=2:N
    cdf(i) = cdf(i-1) + weights(i);
end

i = 1;
u = - rand / N;

for j=1:N
    uj = u + (j-1) / N;
    while uj > cdf(i)
        i = i+1;
    end
    indices(j) = i;
    
end

return