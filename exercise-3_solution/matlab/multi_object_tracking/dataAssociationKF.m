close all;
clc; clear;

%% Setup filelist, output figure, ...
image_path = '../../data/eth/frames/';
start_frame = 1;
end_frame = 150;
num_frames = round(end_frame-start_frame) + 1;
filelist = dir([image_path '*.png']);
h = figure('name','Multi Object Tracking: Data Association - Kalman Filter','units','normalized','position',[0.14,0.14,0.72,0.72]);
clf;

%% Read observations and cut to observed frames
load('../../data/eth/annotations.mat');
load('../../data/eth/observations.mat');
data_points = annotations; % obs | annos
%load('H.mat');
colormatrix = randi(255,200,3);
D = [1 0.04;0 1];

%% loop through images
for i=1:length(filelist)
    if(i>1)
        prev_obs = all_obs;
        velos_old = velos_new;
    end
    %% current observations in this frame
    curr_obs = data_points(data_points(:,1)==i,:);
    all_obs = curr_obs(:,2:3);
    
    %% read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    %% show original image with dets on the left and with tracks right
    
    figure(h);
    subplot(1,2,1), imshow(nextim); title('Current and previous detections');
    subplot(1,2,2), imshow(nextim); title( sprintf('Frame %d', i) );
    
    %% plot current observations
    subplot(1,2,1), hold on, plot(all_obs(:,1),all_obs(:,2),'r*','LineWidth',2);
    
    if(i>1)
        %% plot previous observations
        subplot(1,2,1), hold on, plot(prev_obs(:,1),prev_obs(:,2),'r+','LineWidth',2);
        
        %% data association step + save in track-matrix
        velos_new = zeros(size(all_obs));
        temp_all_obs = all_obs;
        
        %% until there are still current and previos obs:
        while(size(all_obs,1)>0 && size(prev_obs,1)>0)
            %% perform knn matching
            if((size(all_obs,1)>1 && size(prev_obs,1)>1))
                [nn_idx,nn_d] = knnsearch(all_obs,prev_obs+velos_old,'Distance','mahalanobis','Cov',eye(2) * 1.77);
%                 [nn_idx,nn_d] = knnsearch(all_obs,prev_obs+velos_old);
            else
                [nn_idx,nn_d] = knnsearch(all_obs,prev_obs+velos_old);
            end
            [d_min, d_idx] = min(nn_d);
            
            %% constant gating area 50px (alternative via rangesearch above)
            if(d_min < 50)
                % save tracking result in track_x and track_y matrix to
                % directly plot the trajectories (size: [frames x targets])
                % 0 for non-existant in this frame
                id = find(track_x(i-1,:)==prev_obs(d_idx,1));
                if(isempty(id))
                    id = size(track_x,2)+1; % id = end
                    track_x = [track_x, zeros(num_frames,1)];
                    track_y = [track_y, zeros(num_frames,1)];
                    track_x(i,end) = all_obs(nn_idx(d_idx),1);
                    track_y(i,end) = all_obs(nn_idx(d_idx),2);
                else
                    track_x(i,id) = all_obs(nn_idx(d_idx),1);
                    track_y(i,id) = all_obs(nn_idx(d_idx),2);
                    %save speed
                    velos_new(nn_idx(d_idx),:) = [track_x(i,id)-track_x(i-1,id) ...
                        track_y(i,id)-track_y(i-1,id)];
                end
                
                %% plot prediction
                subplot(1,2,1), hold on, plot(temp_all_obs(nn_idx(d_idx),1)+velos_new(nn_idx(d_idx),1),temp_all_obs(nn_idx(d_idx),2)+velos_new(nn_idx(d_idx),2),'b+','LineWidth',1);
            end
            
            %% delete already assigned observations
            all_obs(nn_idx(d_idx),:) = [];
            prev_obs(d_idx,:) = [];
            velos_old(d_idx,:) = [];
        end
        all_obs = temp_all_obs;
    else
        track_x = [all_obs(:,1)';zeros(num_frames-1,size(all_obs,1))];
        track_y = [all_obs(:,2)';zeros(num_frames-1,size(all_obs,1))];
        velos_new = zeros(size(all_obs));
        
    end
    
    %% plot trajectories
    for n = 1: size(track_x,2)
        to_plot = find(track_x(:,n)~=0);
        to_plot = to_plot(to_plot>i-7);
        subplot(1,2,2), line(track_x(to_plot,n), track_y(to_plot,n), ...
            'LineWidth',2,'Color',colormatrix(n,:)/255,'EraseMode','none');
    end
    drawnow;
    pause(0.2);
end

hold off;
