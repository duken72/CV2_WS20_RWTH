% Question 1 : BG subtraction
% @author: Stefan Breuers
% Use this apply.m to test your functions and try out different parameters.
% Write your observations in answers.m
% Make sure that your functions take care of a suitable visualization.

% parameters
image_path = '../sequence-01/';
threshold = 0.7; % e.g. 0.7 (for a-d)
delay = 3; % e.g. 1 (for b,d)
threeway_range = 15; % e.g. 15 (for c)
close all;

% a)
disp('Task 1a - Simple background subtraction');
simple_BG_subtraction(image_path,threshold);
disp('(Press enter)');
pause;
close all;

% b)
% disp('Task 1b - Frame differencing');
% frame_diff(image_path,threshold,delay);
% disp('(Press enter)');
% pause;
% close all;

% c)
%disp('Task 1c - Three-frame differencing');
%three_frame_diff(image_path, threshold, threeway_range);
%disp('(Press enter)');
%pause;
%close all;

% d)
% disp('Task 1d - Extended frame differencing');
%ext_frame_diff(image_path,threshold,delay);
%disp('(Press enter)');
%pause;
%close all;