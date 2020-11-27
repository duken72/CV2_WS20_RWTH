function trajectory = kalman_filter_acc(detections, initial_position, video, init_frame, show)
% Input:
%     detections: a Tx1 cell array of detected points. each entry is a nx2 array of 2d point positions.
%     y0:         the initial position of the object to track
%     video:      the original video (for visualization purposes)
% Output:
%     trajectory: a Tx2 array of tracked object positions
  
    %% Set up
    if nargin<4
        init_frame = 1;
        show=0;
    end

    if nargin<5
        show=0;
    end

    frames = size(detections,1);
    trajectory = zeros(frames, 2);
    dt = 1/25; % 25 FPS
    
    %% Dynamics model update matrix
    % TODO (vi): Setup the dynamics model matrix and uncertainty matrix
    % This time for the constant acceleration model
    D = eye(6);
    D(1:4,3:6) = D(1:4,3:6) + eye(4) * dt;
    D(1:2,5:6) = D(1:2,5:6) + eye(2) * dt^2 / 2;
    sigma_d = eye(6) * 1.78;
    
    %% Observation conversion matrix/ measurement matrix
    % TODO (vii): Setup the measurement model matrix and uncertainty matrix
    % This time for the constant acceleration model
    M = zeros(2, 6);
    M(:,1:2) = eye(2);
    sigma_m = eye(2) * 0.11;    
 
    %% Initialize Kalman filter
    x_pred = [initial_position(1) initial_position(2) 0 0 0 0]'; % Initial state vector
    sigma_pred = eye(6) * 1.77; % Initial state uncertainty (should be high)
    
    %% Iterate over frames
    trajectory(init_frame,:) = x_pred(1:2,:)';
    I = eye(6); % Identity (for use later)
    for f=init_frame+1:frames
        
        %% Associate:
        % Select the observation with the highest prediction posterior,
        % i.e. the observation with the lowest mahalanobis distance to the
        % predicted position.
        % TODO (viii): can be copied from 'kalman_filter.m'
        Maha_dist = zeros(size(detections{f},1), 1);
        rt = detections{f} - trajectory(f-1,:);
        for i=1:size(detections{f},1)        
            Maha_dist(i) = sqrt((rt(i,:)/(sigma_pred(1:2,1:2)))*rt(i,:)');
        end    
        y = detections{f}(Maha_dist==min(Maha_dist),:)';
        
        %% Correct
        % TODO (ix): can be copied from 'kalman_filter.m'
        K = sigma_pred * M' / (M * sigma_pred * M' + sigma_m);
        x_corr = x_pred + K * (y - M*x_pred);
        sigma_corr = (I - K * M) * sigma_pred;
        
        %% show
            % Blue: prediction state x_t^-
            % Red: measurement y_t
            % Green: correted state x_t^+
        if show
            imshow(video(:,:,f),[0 255]); hold on;
            
            drawcross(x_pred,'b'); % predicted state
            drawellipse(sigma_pred(1:2,1:2),x_pred(1),x_pred(2),'b');
            
            drawcross(y,'r'); % measurement
            drawellipse(sigma_m(1:2,1:2),y(1),y(2),'r');
            
            drawcross(x_corr,'g'); % corrected state
            drawellipse(sigma_corr(1:2,1:2),x_corr(1),x_corr(2),'g');
            pause;
        end
        
        %% Predict for next frame
        % TODO (x): can be copied from 'kalman_filter.m'
        x_pred = D * x_corr;
        sigma_pred = D * sigma_corr * D' + sigma_d;
        
        trajectory(f,:) = x_corr(1:2,:)';
    end

end
