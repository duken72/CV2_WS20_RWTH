%% Question a: Compute and store optical flow for sequence-02

function apply_a()

  %% Init
  window_size = 5; % window size to compute optical flow per pixel
  sequence_name = '../sequence-02';
  so = 0; % sequence offset, first frame in sequence
  sequence_path = strcat(sequence_name,'/');
  filelist = dir(strcat(sequence_path,'*.jpg'));
  length(filelist);
  
  %% Iterate over files, parallel for loop
  for n = 1 : length(filelist)
    disp(n);
    %% Read pair of images
    path1 = strcat(sequence_path, sprintf('%04d',n+so), '.jpg');
    path2 = strcat(sequence_path, sprintf('%04d',n+1+so), '.jpg');
    im1 = imread(path1);
    im2 = imread(path2);
    im1 = double(mean(im1,3));
    im2 = double(mean(im2,3));

    %% Compute optical flow
    [u, v] = lucas_kanade(im1, im2, window_size);
    
    %% Store optical flow
    save_var(strcat('tracking_results/flows/',sequence_name,'/u_', sprintf('%04d',n)),u);
    save_var(strcat('tracking_results/flows/',sequence_name,'/v_', sprintf('%04d',n)),v);
  end
end

% Helper function so we can save varibales to disk in parfor loop
function save_var(path, var)
    save(path, 'var', '-ascii');
end
