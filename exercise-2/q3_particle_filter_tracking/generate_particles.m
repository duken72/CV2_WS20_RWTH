function [ samples_x,samples_y ] = generate_particles(mean_x, mean_y, sigma_x, sigma_y, nsamples)
%function to sample  from a  two dimensional gaussian distribution

%Inputs:
%mean_x 
%mean_y
%sigma_x
%sigma_y
%nsamples

if size(size(mean_x),2) == 2
    samples_x = round(mean_x + randn(1,nsamples)*sigma_x);
    samples_x = max(samples_x,0);
    samples_x = min(samples_x,720);
    
    samples_y = round(mean_y + randn(1,nsamples)*sigma_y);
    samples_y = max(samples_y,0);
    samples_y = min(samples_y,576);  
    
    
elseif size(size(mean_x),2) == 1
    % For object near edge, need to crop x and y, within 0 to 572 x 572
    x = round(max(0,-3*sigma_x+mean_x):min(3*sigma_x+mean_x,720));
    y = round(max(0,-3*sigma_y+mean_y):min(3*sigma_y+mean_y,576));    
    cdf_x = normcdf(x,mean_x,sigma_x);
    cdf_y = normcdf(y,mean_y,sigma_y);

    samples_x = zeros(1,nsamples);
    samples_y = zeros(1,nsamples);

    for i=1:nsamples
        %idx = rand(1,2);
        idx_x = find(cdf_x-rand>0, 1);
        idx_y = find(cdf_y-rand>0, 1);
        samples_x(i) = x(idx_x);
        samples_y(i) = y(idx_y);
    end

end

%Outputs:
%samples_x
%samples_y

end

