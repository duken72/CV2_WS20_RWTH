function [ gridxx,gridyy ] = crop_win2track( win_2_track )
%Input
%the window around the template : win_2_track
%Output
%returns the relative coordinates of all the pixels inside the window inthe
%form of 2d grid : gridxx,gridyy
x1 = win_2_track(1);
x2 = win_2_track(3);
y1 = win_2_track(2);
y2 = win_2_track(4);
mid_X = round((x2-x1)/2);
mid_Y = round((y2-y1)/2);
[gridxx,gridyy] = meshgrid(-mid_X:mid_X,-mid_Y:mid_Y);
end

