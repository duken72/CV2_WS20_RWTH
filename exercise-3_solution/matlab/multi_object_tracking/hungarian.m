% As observations, we will use the ground truth bounding 
% box information provided with the VS-PETS soccer dataset
% to simulate a (very accurate) person detector.
% observations
load('../../data/soccer/soccerboxes.mat')
colormatrix = randi(255,50,3);
% allocate
c = cell(2,3);
% read/write element
c{2,2} = 1;

tracks = cell(20,4); % active_track {0,1}, (t,x,y), image_path, histogram

frame_first = 1;
frame_last = 501;
%% Iterate over frames
for fnum=(frame_first:1:frame_last)
    
    %% Get image frame and draw it
    fname = sprintf('../../data/soccer/frames/Frame%04d.jpg', fnum);
    imrgb = imread(fname);
    clf;
    figure(1); imagesc(imrgb);

    %% Find all boxes in frame number fnum and draw each one on image
    % Extract detections
    
    inds = find(allboxes(:,1)==fnum);
    num_detections = length(inds);
    detections = cell(num_detections,2); % [2D tuple position, image_patch] 
    
    hold on
    for iii=1:num_detections
       box = allboxes(inds(iii),:);
       objnum = box(2);
       col0 = box(3);
       row0 = box(4);
       dcol = box(5)/2.0;
       drow = box(6)/2.0;
       h = plot(col0+[-dcol dcol dcol -dcol -dcol],row0+[-drow -drow drow drow -drow],'y-');
       set(h,'LineWidth',2);
       
       %% Build matrix of detections
       detections{iii, 1} = [row0, col0];
       detections{iii, 2} = imrgb(row0-drow:row0+drow, col0-dcol:col0+dcol, :);
    end
    hold off
    
    %% Init tracks with detections from first frame
    if fnum==frame_first
        %% iterate over detections
        for d=1:num_detections
            % detections{iii, 2}
            % (x,y,t), image_path, histogram
            tracks{d,1} = 1;
            tracks{d,2} = cat(2, frame_first, detections{d, 1});
            tracks{d,3} = detections{d, 2};
        end
    elseif fnum>frame_first % perform data association
        sz = size(tracks);
        num_tracks = sz(1,1);
        cost_matrix = zeros(num_tracks,num_detections);
        
        % Iterate over cost matrix, compute cost for each possible 
        % combination track <-> detection
        for det_curr_id=1:num_detections
            for track_curr_id=1:num_tracks
                track_curr_traj = tracks{track_curr_id, 2};
                track_curr_pos = track_curr_traj(end,:);
                detection_curr_pos = detections{det_curr_id, 1};
                % compute cost
                cost = compute_cost(track_curr_pos(1,2), track_curr_pos(1,3),...
                                    detection_curr_pos(1,1), detection_curr_pos(1,2));
                % assign cost
                cost_matrix(track_curr_id, det_curr_id)=cost;
            end
        end
        
        %% Solve assignment problem
        % here the magic happens
        [assignments, cost] = munkres(cost_matrix);
        
        % Iterate over tracks to assign new detections
        for track_curr_id=1:num_tracks
            det_curr_id = assignments(track_curr_id);
            if det_curr_id > 0
                detection_curr_pos = detections{det_curr_id, 1};
                tracks{track_curr_id, 1} = 1; % active_track {0,1} 
                x = detection_curr_pos(1,1);
                y = detection_curr_pos(1,2);
                tracks{track_curr_id, 2} = cat(1,tracks{track_curr_id, 2},[fnum,x,y]); % (t,x,y)\
            else
                % no detections for this track so set to inactive
                tracks{track_curr_id, 1} = 0;
            end
            %tracks{track_curr_id, 3} = 2; % image_path
            %tracks{track_curr_id, 4} = 0; % histogram
        end
    end
    
    %% Visualization
    sz = size(tracks); num_tracks = sz(1,1);
    for track_id=[1:num_tracks]
        trajectory = tracks{track_id,2}; % (x,y,t)
        last_frame = trajectory(end,1);
        % if last added deteection is form this frame then we plot
        if last_frame==fnum
            trajectory = trajectory(:,2:3);
            line(trajectory(:,2), trajectory(:,1),'LineWidth',5,'Color',colormatrix(track_id,:)/255);%, ...
        end
    end
    pause(0.2);
    %output_name = sprintf('soccer_result/Frame%04d.jpg', fnum);
    %saveas(gcf,output_name);
    
end

