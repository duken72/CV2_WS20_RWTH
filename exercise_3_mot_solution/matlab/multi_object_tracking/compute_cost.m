function [ cost ] = compute_cost( x1,y1,x2,y2 )
%COMPUTE_COST 
%   Here we compute the cost between a track and a detection.
%   Modify the parameters as needed.
dx = (x1-x2);
dy = (y1-y2);
cost = dx*dx+dy*dy;
end
