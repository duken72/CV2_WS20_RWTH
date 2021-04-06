%% Setup
image_path = '../../data/eth/frames/';
start_frame = 1;
end_frame = 150;
num_frames = round(end_frame-start_frame) + 1;
filelist = dir([image_path '*.png']);
h = figure('name','Multi Object Tracking: Data Association','units','normalized','position',[0.2,0.2,0.5,0.5]);
clf;
%% Read observations and cut to observed frames
load('../../data/eth/annotations.mat');
load('../../data/eth/observations.mat');
data_points = annotations; % obs | annos
colormatrix = randi(255,50,3);

%% Iterate over frames
for i=1:length(filelist)
    if(i>1)
        prev_obs = all_obs;
    end
    
    %% Current observations in this frame
    curr_obs = data_points(data_points(:,1)==i,:);
    all_obs = curr_obs(:,2:3); % vector of current 2d observations
    
    %% Read next image
    imname = [image_path filelist(i).name];
    nextim = im2double(imread(imname));
    
    %% Show original image with detections (left) and tracks (right)    
    figure(h);
    subplot(1,2,1), imshow(nextim), title('Current and previous detections');
    subplot(1,2,2), imshow(nextim), title( sprintf('Frame %d', i) );
    
    %% Plot current observations as DOT (left)
    subplot(1,2,1), hold on, plot(all_obs(:,1),all_obs(:,2),'r*','LineWidth',1);
    
    if(i>1)
        %% Plot previous observations as PLUS (left)
        subplot(1,2,1), hold on, plot(prev_obs(:,1),prev_obs(:,2),'r+','LineWidth',1);
        
        %% Data association step + save in track-matrix
        temp_all_obs = all_obs;
        
        %% Until there are still current and previous observations:
        while(size(all_obs,1)>0 && size(prev_obs,1)>0)
            
            %% Perform knn matching
            [nn_idx, nn_d] = knnsearch(all_obs, prev_obs);
            % nn_idx - id of new obs selected
            % nn_d   - distance between prev_obs and closest curr_obs
            
            [d_min, d_idx] = min(nn_d);
            % d_min - minimum distance between prev_obs and curr_obs
            % d_idx - id of prev_obs which was assigned
            
            %% Constant gating area 50px
            if(d_min < 50)
                % save tracking result in track_x and track_y matrix to
                % directly plot the trajectories (size: [frames x targets])
                % 0 for non-existant in this frame
                id = find(track_x(i-1,:) == prev_obs(d_idx,1));
                if(isempty(id)) % add new track
                    track_x = [track_x, zeros(num_frames,1)]; % fill up previous frames with zeros
                    track_y = [track_y, zeros(num_frames,1)]; % fill up previous frames with zeros
                    track_x(i,end) = all_obs(nn_idx(d_idx),1);% add new observation
                    track_y(i,end) = all_obs(nn_idx(d_idx),2);% add new observation
                else
                    track_x(i,id) = all_obs(nn_idx(d_idx),1); % add measurement to existing track
                    track_y(i,id) = all_obs(nn_idx(d_idx),2); % add measurement to existing track
                end
            end
            
            %% Delete already assigned observations - greedy approach
            all_obs(nn_idx(d_idx),:) = [];
            prev_obs(d_idx,:) = [];
        end

        all_obs = temp_all_obs;
    else %% frame one, allocate space for all detections and add first one
        track_x = [all_obs(:,1)'; zeros(num_frames-1, size(all_obs,1))];
        track_y = [all_obs(:,2)'; zeros(num_frames-1, size(all_obs,1))];
    end
    
    %% Plot trajectories (right)
    for n = 1: size(track_x,2)
        to_plot = find(track_x(:,n)~=0);
        to_plot = to_plot(to_plot>i-7);
        subplot(1,2,2), 
        line(track_x(to_plot,n), track_y(to_plot,n), 'LineWidth', 2, 'Color', colormatrix(n,:)/255);
    end
    drawnow;
    pause(0.02);
    %output_name = sprintf('eth_result/Frame%04d.jpg', i);
    %saveas(gcf,output_name);
end

hold off;