%% Dynamic model (non-linear)
function x_new = g(x, dt)
% TODO (i)
x_curr = x(1);
y_curr = x(2);
theta_curr = x(3);
v_curr = x(4);
x_curr = x_curr + dt * v_curr * cos(theta_curr);
y_curr = y_curr + dt * v_curr * sin(theta_curr);

x_new = [x_curr, y_curr, theta_curr, v_curr]';
end