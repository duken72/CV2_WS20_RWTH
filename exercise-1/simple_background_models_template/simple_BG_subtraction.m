function simple_BG_subtraction(image_path, threshold)
%SIMPLE_BG_SUBTRACTION Performs simple BG subtraction
%   Given the image_path, this function takes the first image as as BG model
%   and performs simple BG subtration, i.e., subtracts the first image from
%   each other image of the sequence. Pixels are labeled as foreground if
%   the difference exceeds the given threshold.
%
%   author: Stefan Breuers

% setup filelist and output figure
filelist = dir([image_path '*.jpg']);
h = figure('name','1a - Simple background subtraction', 'Position', [10 10 1400 700]);

% use first image as BG
%% TODO
BG_img = im2double(imread('0001.jpg'));

% go through remaining images
for i=100:length(filelist)
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
        
    %% TODO
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
    figure(h), subplot(2,2,1), imshow(BG_img); title('Image for Background Model');
    figure(h), subplot(2,2,2), imshow(nextim); title(sprintf('Current Image %d',i));
    figure(h), subplot(2,2,3), imshow(thresh_img); title(sprintf('Thresh. Image %d',i));
    figure(h), subplot(2,2,4), imshow(overlayed); title('Overlayed Mask');
    
    figure(h), sgtitle(sprintf('Simple Background Model (T=%f)',threshold));
    
end

end
