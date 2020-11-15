function lucas_kanade_tracking(image_path, win2track)

% Width and height of win2track
%% TODO

% Computing relative position of each pixel inside the win2track with respect to centre of win2track
%% TODO

% Centre of win2track
%% TODO

%% Absolute position of each pixel inside template
%% TODO

figure(1);

%% Iterate over images 
filelist = dir (strcat(image_path,'*.jpg'));
for i=1:length(filelist)
            
    %% Read pair of images
    path1 =  strcat(image_path, filelist(i).name);
    path2 =  strcat(image_path, filelist(i + 1).name);
    im1 = imread(path1);
    im2 = imread(path2);
    previm = double(mean(im1,3));
    currim = double(mean(im2,3));
    
    %% TODO
   
    %% Visualization
    clf(1);
    set(gca,'position',[0 0 1 1],'units','normalized')
    imshow(im2);
    hold on;
    rectangle('Position', rect, 'EdgeColor','Red','LineWidth',2);
    title(num2str(i));
    pause(0.02)
    
end