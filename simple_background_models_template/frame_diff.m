function frame_diff(image_path, threshold, delay)
%FRAME_DIFF Performs frame differencing
%   Given the image_path, this function performs frame differencing by
%   subtracting two images of a certain delay. Pixels are labeled as
%   foreground if the difference exceeds the given threshold.
%
%   author: Stefan Breuers

% setup filelist and output figure
filelist = dir([image_path '*.jpg']);
h = figure('name','1b - Frame differencing', 'Position', [10 10 1900 1000]);

% go through remaining images
for i=100:length(filelist)
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    
    %% TODO
    BG_img = im2double(imread([image_path filelist(i-delay).name]));    
    thresh_img = abs(sum(nextim - BG_img, 3));
    thresh_img(thresh_img>threshold) = 1;
    thresh_img(thresh_img<=threshold) = 0;
    
    % create overlayed mask image
    repeat_thresh_img = repmat(thresh_img, [1 1 3]);
    repeat_thresh_img(:, :, 1) = repeat_thresh_img(:, :, 1) * 0.7;
    repeat_thresh_img(:, :, 2) = repeat_thresh_img(:, :, 1) * 0.;
    repeat_thresh_img(:, :, 3) = repeat_thresh_img(:, :, 1) * 0.;
    
    overlayed = nextim + repeat_thresh_img;
    overlayed(overlayed > 1.0) = 1.0;
    
    % show original image on the left and thresholded on the right
    figure(h), subplot(2,2,1), imshow(BG_img); title(sprintf('BG Model Image %d', i-delay));
    figure(h), subplot(2,2,2), imshow(nextim); title(sprintf('Current Image %d',i));
    figure(h), subplot(2,2,3), imshow(thresh_img); title(sprintf('Thresh. Image %d',i));
    figure(h), subplot(2,2,4), imshow(overlayed); title('Overlayed Mask');
    
    figure(h), sgtitle(sprintf('Simple Frame Differencing Model (T=%.2f, D=%d)',threshold, delay));
    
end

end
