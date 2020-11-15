function [ p ] = generalized_lucas_kanade(im1,im2,win_2_track,p_initial )
%Input:
% im1,im2
% Output :
% warp parameters p

%% STEP 1: extract template from previous frame
% crop the template with coordinates [x1,y1,x2,y2] from im1 with (x1,y1)
% upper left corner and (x2,y2) lower right corner
%% TODO

%% STEP2: initialize warp parameters
%Initialize the warp paramters and extract the initial template from image2
% p = [tx ,ty ,ang]
%% TODO

%% STEP3 
%Prepare to apply for iterative lucas kanade based on trans + rot
%doing initializations
numiters = 10;     % number of iterations to perform for iterative lucas kanade
accel = 8;         % step paramter for gradient descent 
disp = 0;          % set to 1 if you want to visualize the steps of iterative lucas kanade
fixed_rot = 0;     % do not use rotations in the warp model
[p,warped] = tr_iteration(template,currim,params,accel,numiters,disp,fixed_rot);
end

