function visual_odometry_8point
clear; clc;
%% Task a. Read data
% Read input images:
image1 = imread('fountain\0005.png');
image2 = imread('fountain\0007.png');

% Intrinsic camera paramter matrices
file = fopen('fountain\camera_intrinsics_matrix.txt','r');
params = fscanf(file, '%f');
C = reshape(params, [3,3])';
K = inv(C);

%% Task b. Get corresponding point pairs:
nPoints =  12;  % or 12 e.g.
%[x1,y1,x2,y2] = getpoints(image1,image2,nPoints);
[x1,y1,x2,y2] = getpoints2(); % use predefined points (see below)

% Transform image coordinates with inverse camera matrices:
% can be done without for-loop as well
for i = 1:nPoints
   l = K * [x1(i); y1(i); 1];
   r = K * [x2(i); y2(i); 1];
   x1(i) = l(1); y1(i) = l(2);
   x2(i) = r(1); y2(i) = r(2);
end

%% Start Task: c) 8-Point Algorithm %%%%%%
% Compute constraint matrix A
A = zeros(nPoints, 9);
for i = 1:nPoints
    A(i,:) = [x2(i)*x1(i), x2(i)*y1(i), x2(i), y2(i)*x1(i), y2(i)*y1(i), y2(i), x1(i), y1(i), 1];
end
% Compute essential matrix E
[~,~,VA] = svd(A); % A = UA*SA*VA'
E = reshape(VA(:,end),3,3)';
[U, S, V] = svd(E);
if det(U) < 0 || det(V) < 0
    [U,S,V] = svd(-E);
end
E = U * diag([1,1,0]) * V';
%%%%% End Task

%% Task d) Recover R and T from the essential matrix E
% Two solutions: (see slides and Chapter 5 in Masks textbook).
R1 = [0 -1 0; 1 0 0; 0 0 1]; % Rotation matrix around z for pi/2
R2 = [0 1 0; -1 0 0; 0 0 1]; % Rotation matrix around z for -pi/2

R1 = U * R1' * V';
R2 = U * R2' * V';
T1hat = U * R1 * diag([1,1,0]) * U';
T2hat = U * R2 * diag([1,1,0]) * U';
T1 = [T1hat(3,2); T1hat(1,3); T1hat(2,1)];
T2 = [T2hat(3,2); T2hat(1,3); T2hat(2,1)];
%%%%% End Task

%% Compute scene reconstruction and correct combination of R and T:
%figure(2); imshow(uint8(image2)); hold on;
reconstruction(R1, T1, x1, y1, x2, y2, nPoints);
%reconstruction(R1, T2, x1, y1, x2, y2, nPoints);
%reconstruction(R2, T2, x1, y1, x2, y2, nPoints);
%reconstruction(R2, T1, x1, y1, x2, y2, nPoints);

end

% Compute correct combination of R and T and reconstruction of 3D points
function reconstruction(R, T, x1, y1, x2, y2, nPoints)

%% Start Task: d) Find the correct solution by reconstrucion
% Structure reconstruction matrix M:
M = zeros(3*nPoints, nPoints + 1);
for i = 1:nPoints
   x2_hat = hat([x2(i) y2(i) 1]);
   M(3*i - 2  :  3*i, i)           = x2_hat * R * [x1(i); y1(i); 1];
   M(3*i - 2  :  3*i, nPoints + 1) = x2_hat * T;
end
[~,~,VM] = svd(M);
lambda = VM(1:nPoints,end);
gamma = VM(nPoints+1,end);

% Determine correct combination of R and T:
if lambda >= zeros(nPoints,1)
    display(R);
    display(T);
    display(lambda);
    display(gamma);
    
    % Visualize the 3D points:
    figure(2), plot3(x1 ,y1 ,lambda ,'+');
    axis equal
end
%%%%%% End Task %%%%%%

%%%%% End Task %%%%%%

end

% Hat-function: cross product as matrix-operation
function A = hat(v)
    A = [0 -v(3) v(2) ; v(3) 0 -v(1) ; -v(2) v(1) 0];
end

% function getpoints
function [x1,y1,x2,y2] = getpoints(image1, image2, nPoints)

%x1 = zeros(nPoints, 1);
%y1 = zeros(nPoints, 1);
%x2 = zeros(nPoints, 1);
%y2 = zeros(nPoints, 1);

%% Start Task: b) Get Matches
figure(1);
imshow(image1); hold on;
[x1, y1] = ginput(nPoints);
plot(x1,y1,'r--o');

figure(2);
imshow(image2); hold on;
[x2, y2] = ginput(nPoints);
plot(x2,y2,'b--x');
hold off;
%%%%% End Task: Get Matches
end

% function getpoints2  --> points already defined
function [x1,y1,x2,y2] = getpoints2()

x1 = 1000 * [
    0.9535
    1.8815
    0.9535
    1.8855
    0.9475
    0.6815
    1.9055
    2.1575
    1.1075
    1.7415
    1.1435
    1.7015
    ];

y1 = 1000 * [
    1.4055
    1.4035
    1.8895
    1.8875
    0.3455
    0.8135
    0.3515
    0.8115
    1.2055
    1.2035
    0.6635
    0.6655
    ];

x2 = 1000 * [
    1.6295
    2.4355
    1.6295
    2.4415
    1.1755
    0.8835
    2.0875
    2.2875
    1.3355
    1.9375
    1.3775
    1.9075
    ];

y2 = 1000 * [
    1.3855
    1.3535
    1.9135
    1.8175
    0.1955
    0.7075
    0.3115
    0.7755
    1.1595
    1.1515
    0.5655
    0.6075
    ];
end