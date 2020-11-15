function single_gaussian_BG_model_EMAF(image_path, threshold, alpha)
%SINGLE_GAUSSIAN_BG_MODEL 

close all;
% setup filelist and output figure
filelist = dir([image_path '*.jpg']);
h = figure('name','Single Gaussian Model (EMAF): Results', 'Position', [10 10 1900 1000]);

% learn single Gaussian BG model on first 100 frames for each pixel
% firstly, collect data_points
data_points = zeros(576,768,min(100,length(filelist)));
for i=1:min(100,length(filelist))
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    
    % collect intensity
    data_points(:,:,i) = sum(nextim,3);    
end
% secondly, learn mean and variance for each pixel
%% TODO

% go through remaining images
for i=101:length(filelist)
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    
    % compute intensity image
    %% TODO
    
    % thresholding
    %% TODO
    
    % update mean and variance with Exponential Moving Average filter
    %% TODO
    
    % create overlayed mask image
    repeat_thresh_img = repmat(thresh_img, [1 1 3]);
    repeat_thresh_img(:, :, 1) = repeat_thresh_img(:, :, 1) * 0.7;
    repeat_thresh_img(:, :, 2) = repeat_thresh_img(:, :, 1) * 0.;
    repeat_thresh_img(:, :, 3) = repeat_thresh_img(:, :, 1) * 0.;
    
    overlayed = nextim + repeat_thresh_img;
    overlayed(overlayed > 1.0) = 1.0;
    
    % show original image on the left and thresholded on the right
    figure(h), subplot(2,3,1), imagesc(mean_img); colormap(hot); axis off; axis equal; title('Mean Image');
    figure(h), subplot(2,3,3), imshow(nextim); title(sprintf('Current Image %d', i));
    figure(h), subplot(2,3,4), imagesc(var_img); colormap(hot); axis off; axis equal; title('Variance Image');
    figure(h), subplot(2,3,5), imshow(thresh_img); title(sprintf('Thresholded Image (T=%.2f)', threshold));
    figure(h), subplot(2,3,6), imshow(overlayed); title('Overlayed Mask');
end

end
