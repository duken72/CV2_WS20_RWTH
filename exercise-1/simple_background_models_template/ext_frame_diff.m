function ext_frame_diff(image_path, threshold, delay)
%EXT_FRAME_DIFF Performs frame differencing
%   Given the image_path, this function performs frame differencing by
%   subtracting two images of a certain delay. Pixels are labeled as
%   foreground if the difference exceeds the given threshold.
%   Additionaly this function provides the MHS (Motion History Image).
%
%   author: Stefan Breuers

% setup filelist and output figure
filelist = dir([image_path '*.jpg']);
h = figure('name','1d - Motion History Image', 'Position', [10 10 1900 1000]);

H = zeros(576,768);

% go through remaining images
for i=100:length(filelist)
    % read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));    

    %% TODO Frame Differencing
    BG_img = im2double(imread([image_path filelist(i-delay).name]));    
    thresh_img = abs(sum(nextim - BG_img, 3));
    thresh_img(thresh_img>threshold) = 1;
    thresh_img(thresh_img<=threshold) = 0;
    
    % create motion history image H
    tmp = max(H-10,0);
    H = max(thresh_img.*255,tmp);
        
    % show original image on the left and thresholded on the right
    figure(h), subplot(2,2,1), imshow(BG_img); title(sprintf('BG Model Image %d', i-delay));
    figure(h), subplot(2,2,2), imshow(nextim); title(sprintf('Current Image %d',i));
    figure(h), subplot(2,2,3), imshow(thresh_img); title(sprintf('Thresh. Image %d',i));
    figure(h), subplot(2,2,4), imshow(H,colormap(gray)); title('Motion History');
    
    figure(h), sgtitle(sprintf('Extended Frame Differencing Model (T=%.2f, D=%d)',threshold, delay));    
end

end

