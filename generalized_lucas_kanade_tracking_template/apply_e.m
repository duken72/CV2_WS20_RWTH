%% Question e: Generalized LKT

function apply_e( )

  sequence_path = '../sequence-03/';

  win2track1 = [435,458,480,570]; % Large window
  win2track2 = [445,468,470,510]; % Small window

  generalized_lucas_tracking(sequence_path, win2track2);

end
