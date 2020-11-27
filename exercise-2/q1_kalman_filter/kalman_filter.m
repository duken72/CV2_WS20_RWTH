function trajectory = kalman_filter(detections, init_position, video, init_frame, show)
  % Input:
  %     detections:     Tx1 cell array of detected points, each entry is a nx2 array of 2d point positions
  %     init_position:  initial position of object to track
  %     video:          original video (for visualization purposes)
  % Output:
  %     trajectory:     Tx2 array of tracked object positions
  
  %% Set up
  if nargin<4 % If there is only 3 inputs
    init_frame = 1;
    show=0;
  end
  
  if nargin<5 % If there is only 4 inputs
    show=0;
  end
  
  %%
  frames = size(detections,1);
  trajectory = zeros(frames, 2);
  dt = 1/25; % 25 FPS
    
  %% Dynamics model, matrix + uncertainty
  % TODO (i): Setup the dynamics model matrix and uncertainty matrix
  % xt = [x y vx vy]
  D = eye(4);
  D(1:2,3:4) = eye(2) * dt;
  sigma_d = eye(4) * 1.78;
  
  %% Measurement matrix, matrix + uncertainty
  % TODO (ii): Setup the measurement model matrix and uncertainty matrix
  M = zeros(2, 4);
  M(:,1:2) = eye(2);
  sigma_m = eye(2) * 0.11;
    
  %% Initialize Kalman filter
  x_pred = [init_position(1) init_position(2) 0 0]'; % Initial state vector
  sigma_pred = eye(4) * 1.77;                        % Initial state uncertainty (should be high)
  I = eye(4); % Identity (for use later)
  
  %% Iterate over frames
  trajectory(init_frame,:) = x_pred(1:2,:)';
  for f=init_frame+1:frames
      
    %% Associate:
    % Select the observation with the highest prediction posterior,
    % i.e. the observation with the lowest Mahalanobis distance to the
    % predicted position.
    % TODO (iii): Find the associated observation
    Maha_dist = zeros(size(detections{f},1), 1);
    rt = detections{f} - trajectory(f-1,:);
    for i=1:size(detections{f},1)        
        Maha_dist(i) = sqrt((rt(i,:)/(sigma_pred(1:2,1:2)))*rt(i,:)');
    end    
    y = detections{f}(Maha_dist==min(Maha_dist),:)';
    
    %% Correct
    % TODO (iv): Calculate the Kalman correction given the observation
    K = sigma_pred * M' / (M * sigma_pred * M' + sigma_m);
    x_corr = x_pred + K * (y - M*x_pred);
    sigma_corr = (I - K * M) * sigma_pred;
        
    %% Show
    % Blue: prediction state x_t^-
    % Red: measurement y_t
    % Green: correted state x_t^+
    if show
      imshow(video(:,:,f),[0 255]);
      hold on;

      drawcross(x_pred,'b');    % predicted state
      drawellipse(sigma_pred(1:2,1:2),x_pred(1),x_pred(2),'b');

      drawcross(y,'r');         % measurement
      drawellipse(sigma_m(1:2,1:2),y(1),y(2),'r');

      drawcross(x_corr,'g');    % corrected state
      drawellipse(sigma_corr(1:2,1:2),x_corr(1),x_corr(2),'g');

      pause;
    end
    
    %% Predict for next frame
    % TODO (v): Calculate the next frame prediction
    x_pred = D * x_corr;
    sigma_pred = D * sigma_corr * D' + sigma_d;
    
    trajectory(f,:) = x_corr(1:2,:)';
  end
end