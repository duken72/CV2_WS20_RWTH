%% Question b: Visualizing the optical flow

function apply_b()

  sequence_name = 'sequence-02';
  path_prefix = strcat('tracking_results/flows/',sequence_name,'/');
  filelist = dir(path_prefix);
  length(filelist);
  
  for n = 1 : length(filelist)
    path_u = strcat(path_prefix,'u_',sprintf('%04d',n)); 
    path_v = strcat(path_prefix,'v_',sprintf('%04d',n)); 
    u = dlmread(path_u);
    v = dlmread(path_v);
    flow = flowToColor(u,v);
    figure(1)
    clf;
    imagesc(flow);
    title(i);
    pause(0.03);
  end
end
