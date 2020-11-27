%% Question 1: Kalman Filter

function apply()

    % Exercise a): simply run the code for the next four sections, to get
    % an understaning of the data and the task.

    %% Load data
    data = load('detections.mat');
    
    %% Play input video
    play_video(data.video);          % Original input video
    
    %% Play Intensity thresholded video
    play_video(data.video_filtered); % Intensity thresholded video (this is where the detections come from)
    
    %% Display detections for a particular frame
    % Note: change frame_id here to view a different frame's detecitons
    frame_id = 12;
    det_frame = data.detections{frame_id};
    imshow(data.video(:,:,frame_id), [0 255]);   
    for d=1:size(det_frame, 1)
        drawcross(det_frame(d,:), 'g'); 
    end
    %gca.Visible = 'On';
    set(gca,'position',[0 0 1 1],'units','normalized');
    
    
    %% Select initial position in first frame
    init_frame = 1; % Which frame to start with.    
    %imshow(data.video(:,:,init_frame), [0 255]);
    %axes = gca;
    %axes.Visible = 'On';
    %init_detection = ginput(1)
    init_detection = [174, 87]; % white ball in frame 1
    
    %% Kalman Filter
    % Exercise b) and c): Finish the implementation of the Kalman filter
    % and run it.
    show = 1; % Whether to show the results frame by frame (press enter for next frame)
    trajectory = kalman_filter(data.detections, init_detection, data.video, init_frame, show);
    %detections = data.detections;
    %init_position = init_detection;
    %video = data.video;
    %trajectory = kalman_filter(detections, init_position, video, init_frame, show)
    
    %% Plot returned trajectory
    % Exercise d) and e): Plot the result and understand the results.
    imshow(data.video(:,:,init_frame), [0 255]);
    hold on;
    plot(trajectory(init_frame:end,1),trajectory(init_frame:end,2),'linewidth',1,'color','g');
    set(gca,'position',[0 0 1 1],'units','normalized');
    
    %% Select other (yellow) ball in the sixth frame
    % Exercise f): Try the tracker on a different ball, and a different
    % starting frame.
    init_frame = 6; % Which frame to start with.
    imshow(data.video(:,:,init_frame), [0 255]);
    %init_detection = ginput(1)
    init_detection = [144,100]; % yellow ball in frame 6
    
    %% Run the Kalman Filter for the other ball
    show = 1; % Whether to show the results frame by frame (press enter for next frame)
    trajectory = kalman_filter(data.detections, init_detection, data.video, init_frame, show);
    
    %% Plot returned trajectory
    imshow(data.video(:,:,init_frame), [0 255]);
    hold on;
    plot(trajectory(init_frame:end,1),trajectory(init_frame:end,2),'linewidth',1,'color','g');
    set(gca,'position',[0 0 1 1],'units','normalized');
    
    
    %% Extend to Constanst Acceleration Kalman Filter
    % Exercise g): Extend to 'constant acceleration Kalman filter'. 
    % Finish code.
    show = 1; % Whether to show the results frame by frame (press enter for next frame, hold enter to go through quickly)
    trajectory2 = kalman_filter_acc(data.detections, init_detection, data.video, init_frame, show);
    
     %% Plot returned trajectory (constant accel)
    imshow(data.video(:,:,init_frame), [0 255]);
    hold on;
    plot(trajectory2(init_frame:end,1),trajectory2(init_frame:end,2),'linewidth',1,'color','r');
    set(gca,'position',[0 0 1 1],'units','normalized');
end
