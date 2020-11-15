% Question 2 : Statistical BG models

% parameters
image_path = '../sequence-01/';
close all;

% a)
% experiment with threshold (e.g. 25, 40)
%threshold = 25;
%single_gaussian_BG_model(image_path, threshold);
%close all;
%pause;

% b)
% experiment with threshold (e.g. 10, 25, 40) alpha (0.01, 0.5, 0.99)
threshold = 10;
alpha = 0.001;
single_gaussian_BG_model_EMAF(image_path, threshold, alpha);
close all;
pause;

% c)
% redesign...






