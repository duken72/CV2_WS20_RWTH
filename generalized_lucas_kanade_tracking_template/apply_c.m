%% Question c: Optical Flow template tracking

function apply_c( )
  sequence_path = '../sequence-02/';   % path to sequence
  win2track = [295,252,328,280];    % cordinates of window to track in first frame
  lucas_kanade_tracking(sequence_path, win2track);
end
