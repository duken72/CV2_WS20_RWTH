%% Question: Extended Kalman Filter

function apply()

    %% Parameters
    dt = 1/25;  % 25 FPS
    T = 200;    % max. number time steps
    sigma_d = eye(4) * 0.001;  % Uncertainty of the dynamics model
    sigma_m = eye(2) * 0.05;   % Uncertainty of the observation model
    
    %% Initialize sate
    x_init = 0;
    y_init = 0;
    theta_init = 0;
    v_init = 1;
    state_init = [x_init; y_init; theta_init; v_init];
    
    %% Simulate measurements with Gaussian noise
    trajectory = zeros(T,2);
    measurements = zeros(T,2);
    state_prev = state_init;
    for j=1:T
        if j>0 && j<10
            state_prev(4,1) = state_prev(4,1) + 0.1;
        end
        if j>20 && j<30
            state_prev(3,1)= state_prev(3,1)+0.3;
        elseif j>40 && j<100
            state_prev(3,1)= state_prev(3,1)-0.05;
        elseif j>140 && j<170
            state_prev(3,1)= state_prev(3,1)+0.15;
        end
        [x_curr, y_curr, theta_curr, v_curr] = g(state_prev,dt);
        state_curr = [x_curr; y_curr; theta_curr; v_curr];
        y = h(state_prev);
        trajectory(j,:) = y';
        measurements(j,1) = y(1,1) + normrnd(0,sigma_m(1,1));
        measurements(j,2) = y(2,1) + normrnd(0,sigma_m(2,2));
        state_prev = state_curr;
    end
    
    %% Plot true trajectory and noisy measurements
    if(1)
      figure;
      scatter(measurements(:,1), measurements(:,2),'xr');
      hold on
      plot(trajectory(:,1), trajectory(:,2),'b','LineWidth',2);
      axis([-1 6 -1 5]);
      xlabel('x');
      ylabel('y');
      title('Original trajectory with noisy measurements');
      pause;
    end

    %% Do filtering
    I = eye(4); % Identity
    trajectory_filtered = zeros(T,2);

    x_pred = state_init;
    sigma_pred = eye(4) * 0.5;
    trajectory_filtered(1,:) = h(x_pred);
    
    for t=1:T
      
      %% Association Step
      % Here we assume the correct measurement is known since we get one per
      % time steps.
      y = measurements(t,:)';
      
      %% Correction Step
      % TODO (v)
      K = sigma_pred * jacH(x_pred, dt)' / (jacH(x_pred, dt) * sigma_pred * jacH(x_pred, dt)' + sigma_m);
      x_corr = x_pred + K * (y - h(x_pred));
      sigma_corr = (I - K * jacH(x_pred, dt)) * sigma_pred;
        
      %% Predict Step for next frame
      % TODO (vi)
      x_pred = g(x_corr, dt);
      sigma_pred = jacG(x_corr, dt) * sigma_corr * jacG(x_corr, dt)' + sigma_d;
      
      trajectory_filtered(t,:) = x_corr(1:2,:)';
    end
    
    %% Plot true trajectory and noisy measurements
    figure(1);
    clf(1);
    hold on
    scatter(measurements(:,1), measurements(:,2),'xr');
    plot(trajectory(:,1), trajectory(:,2),'b','LineWidth',2);
    plot(trajectory_filtered(:,1), trajectory_filtered(:,2),'g','LineWidth',2);
    axis([-1 6 -1 5]);
    title('Filtered trajectory from noisy measurements');
end
