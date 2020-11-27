%% Jacobian of dynamic model
function G = jacG(x, dt)
% TODO (iii)
theta_curr = x(3);
v_curr = x(4);
G = eye(size(x,1));
G(1:2, 3:4) = [-dt*v_curr*sin(theta_curr), dt*cos(theta_curr);
                dt*v_curr*cos(theta_curr), dt*sin(theta_curr)];
end