% Sample particle filter code


%**************************************************************************
%--------------------------------Initalization-----------------------------
%**************************************************************************

% As observations, we will use the ground truth bounding 
% box information provided with the VS-PETS soccer dataset
% to simulate a (very accurate) person detector.

% observations
load soccerboxes.mat

% each box is stored as one row of allboxes
% there are 6 columns
% col1 : frame number this box comes from
% col2 : object identifier this box comes from
% col3 : x coord (matlab col) of box center
% col4 : y coord (matlab row) of box center
% col5 : width of box
% col6 : height of box

% prepare sequence structure for genfilename.m
startframe = min(allboxes(:,1));
endframe = max(allboxes(:,1));
prefix = 'soccer/Frame';
postfix = '.jpg';
sequence = struct('prefix',prefix,...
                  'postfix',postfix,...
                  'digits',4,...
                  'startframe',startframe,...
                  'endframe',endframe);

% initialize by choosing a subsequence and one person to track
fstart = startframe;
fend = fstart+ 500;
fnum = fstart;

% get image frame and draw it
fname = genfilename(sequence,fnum);
imrgb = imread(fname);
figure(1); imagesc(imrgb);

% find all boxes in frame number fnum and draw each one on image
inds = find(allboxes(:,1)==fnum);
hold on
for iii=1:length(inds)
   box = allboxes(inds(iii),:);
   objnum = box(2);
   col0 = box(3);
   row0 = box(4);
   dcol = box(5)/2.0;
   drow = box(6)/2.0;
   h = plot(col0+[-dcol dcol dcol -dcol -dcol],row0+[-drow -drow drow drow -drow],'y-');
   set(h,'LineWidth',2);
end
hold off
drawnow

%intialize prior by clicking mouse near center of person 
%you want to track
[x0,y0] = ginput(1);


%**************************************************************************
%----------------------------------a-------------------------------------
%**************************************************************************
%number of particles for particle filtering
nsamples = 150;
%prior distribution will be gaussian
priorsigmax = 10;
priorsigmay = 10;
%generate particles from prior distribution

% Here comes your implementation of generate_particles
% (figure out the right input parameters!)
% --->
[ sampx,sampy ] = generate_particles(x0, y0, priorsigmax, priorsigmay, nsamples);
% <---

% plot particles
figure(1); imagesc(imrgb); hold on
plot(sampx,sampy,'b.');
hold off; drawnow;
pause;

%% *******************************************

%now start tracking
%weights = ones(1,nsamples)/nsamples;
deltaframe = 1;  %set it to 1 if you want to perform tracking for every frame
for fnum = (fstart+deltaframe): deltaframe : fend
    %get image frame and draw it
    fname = genfilename(sequence,fnum);
    imrgb = imread(fname);
    figure(1); imagesc(imrgb);
    %find all boxes in frame number fnum
    inds = find(allboxes(:,1)==fnum);
    
    %do motion prediction step of Bayes filtering 
    %we will use a deterministic motion model plus
    %additive gaussian noise.
    %we are using simple constant position model 
    %as a simple demonstration.
    motpredsigmax = 10;
    motpredsigmay = 10;
    [predx,predy] = generate_particles(sampx, sampy,...
                                       motpredsigmax, motpredsigmay,...
                                       nsamples);
    
    %compute weights based on likelihood
    %recall weights should be oldweight * likelihood
    %but all old weights are equal, so new weight will
    %just be the likelihood.
    
    %For measuring likelihood, we are using a mixture
    %model (parzen estimate) based on the locations of
    %the ground truth bounding boxes.  Note that this is
    %a semiparametric, multimodal distribtion.
    obssigmax = 10;
    obssigmay = 10;
    weights = ones(1,nsamples)/nsamples;
    
    % iterate over particles
    for i=1:nsamples
        prob = 0;
        x = predx(i);
        y = predy(i);
        
        % iterate over detections
        for iii=1:length(inds)
            box = allboxes(inds(iii),:);
            midx = box(3);  % centroid of box
            midy = box(4);
%**************************************************************************
%----------------------------------b---------------------------------------
%**************************************************************************

            % your function implementation comes here
            % (figure out the right input parameters!)
            % --->
            p = compute_particle_likelihood(x,y,midx,midy,obssigmax,obssigmay);
            % <---
            prob = prob + p;      
        end
        weights(i) = prob;
    end
    weights = weights /sum(weights);
    %%
    %resample particles according to likelihood weights
    %the resulting samples will then have equal weight
%**************************************************************************
%----------------------------------c---------------------------------------
%**************************************************************************
    
    % your function implementation comes here
    % --->
    indices = inverse_transform_sampling(weights);
    % <---
    
    % select samples 
    sampx = predx(indices);
    sampy = predy(indices);
    %plot resampled particles
    %jitter with a little noise so multiple copies can be seen
    clf('reset');
    figure(1); imagesc(imrgb); hold on
    plot(sampx+1*randn(1,nsamples),sampy+1*randn(1,nsamples),'b.');
    drawnow;
    file_name = sprintf('result/%d%s',fnum,'.png');
    saveas(gcf,file_name)
    
end