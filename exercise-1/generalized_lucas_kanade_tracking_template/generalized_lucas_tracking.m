function generalized_lucas_tracking(image_path, win2track)

%The width and height of win2track
%% TODO

%computing relative position of each pixel inside the win2track with respect to centre of win2track
%% TODO

%traversing through the images 
filelist = dir(strcat(image_path,'/*.jpg'));
path1 = strcat(image_path,filelist(1).name);

h = figure('name','Generalized Lucas Kanade Tracking', 'Position', [10 10 1900 1000]);

%% Initializing the warp parameters
% tx,ty,theta
% translation center of template
%% TODO

old_txs = p_initial(1);
old_tys = p_initial(2);
old_rots = p_initial(3);

%% Iterate over sequence
for i=2:length(filelist)
     
    path2 =  strcat(image_path,filelist(i).name);
    im = imread(path1);
    im2 = imread(path2);
    
    %% Compute generalize LK
    params = generalized_lucas_kanade(im,im2,win2track,p_initial);
    
    % log old rotation parameters
    old_txs = [old_txs params(1)];
    old_tys = [old_tys params(2)];
    old_rots = [old_rots params(3)];
    
    %% TODO
  
    %% Visualize rectangle
    figure(h), subplot(2,2,1), imshow(im2); title('Current Frame');
    
    % unfortunately, we do not rotate the rectangle here ...
    figure(h), subplot(2,2,1), rectangle('Position',[newx,newy,template_width,template_height],'EdgeColor','Red','LineWidth',2);
    
    t=1:size(old_rots, 2);
    figure(h), subplot(2,2,2), plot(t,old_rots), xlabel('Frame'), ylabel('Angle'), title('Warp Rotation');
end


end

