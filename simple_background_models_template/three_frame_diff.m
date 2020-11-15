function three_frame_diff(image_path, threshold, delay)
%THREE_FRAME_DIFF Performs 3-frame differencing
%   Given the image_path, this function performs frame differencing by
%   subtracting two images of a certain delay. Pixels are labeled as
%   foreground if the difference exceeds the given threshold. After that,
%   the thresholded image is logically ANDed with the thresholded image of
%   the same delay in the future. 
%
%   author: Stefan Breuers

% setup filelist and output figure
filelist = dir([image_path '*.jpg']);
h = figure('name','1c - Three-frame differencing', 'Position', [10 10 1900 1000]);

% go through remaining images
for i=100:length(filelist)
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    
    %% TODO
    
    % create overlayed mask image
    repeat_thresh_img = repmat(thresh_img, [1 1 3]);
    repeat_thresh_img(:, :, 1) = repeat_thresh_img(:, :, 1) * 0.7;
    repeat_thresh_img(:, :, 2) = repeat_thresh_img(:, :, 1) * 0.;
    repeat_thresh_img(:, :, 3) = repeat_thresh_img(:, :, 1) * 0.;
    
    overlayed = nextim + repeat_thresh_img;
    overlayed(overlayed > 1.0) = 1.0;
    
    % show original image on the left and thresholded on the right
    figure(h), subplot(3,3,1), imshow(BG_img); title(sprintf('BG Model Img Past %d', i-delay));
    figure(h), subplot(3,3,2), imshow(nextim); title(sprintf('Current Image %d',i));
    figure(h), subplot(3,3,3), imshow(BG_img_ft); title(sprintf('BG Model Img Future %d',i+delay));
    figure(h), subplot(3,3,4), imshow(thresh_img_past); title('Past <-> Current');
    figure(h), subplot(3,3,5), imshow(thresh_img); title('Thresholded Image (AND)');
    figure(h), subplot(3,3,6), imshow(thresh_img_ft); title('Current <-> Future');
    figure(h), subplot(3,3,8), imshow(overlayed); title('Overlayed Mask');
    
    figure(h), sgtitle(sprintf('Three Frame Differencing Model (T=%.2f, D=%d)',threshold, delay));    
end

end

