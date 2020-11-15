%% Question d: Generalized LKT

function apply_d( )
  % run this commands in your shell
  % only compile once
  % mex -c resampling.c
  % mex Pwarp.c resampling.o //use .obj on windows

  sequence_path = '../sequence-02/';
  win2track = [295,252,328,280];
  generalized_lucas_tracking(sequence_path, win2track);
  close all;
  pause;
end

