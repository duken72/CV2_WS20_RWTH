function [u, v] = lucas_kanade(im1, im2, window_size)
  % Input:
  %   im1, im2:    Pair of images that the optical flow is computed on
  %   window_size: Size of the optical flow window
  % Output:
  %   u, v:        Optical flow in u and v direction

  %% TODO
  sigma = 1;
  [imgDx, imgDy] = gaussderiv(im1, sigma);  
  gaussian = gauss(1, sigma);
  imgDt = im2 - im1;
  imgDt = conv2(imgDt, gaussian , 'same');
  imgDt = conv2(imgDt, gaussian', 'same');
    
  u = zeros(size(im1,1:2));
  v = zeros(size(im1,1:2));
 
  for i=1:size(im1,1)-window_size+1
      for j=1:size(im1,2)-window_size+1
          A = [reshape(imgDx(i:i+window_size-1, j:j+window_size-1), [window_size^2, 1]), ...
               reshape(imgDy(i:i+window_size-1, j:j+window_size-1), [window_size^2, 1])];
          b = reshape(imgDt(i:i+window_size-1, j:j+window_size-1), [window_size^2, 1]);
          d = A\b;
          u(i+floor(window_size/2),j+floor(window_size/2)) = d(1);
          v(i+floor(window_size/2),j+floor(window_size/2)) = d(2);
      end
  end
  
end
