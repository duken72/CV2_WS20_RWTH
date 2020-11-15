%do LK iterations for translation+rotation warping bring curim into
%alignment with the template.  On output, warped is the current image
%warped and cropped to the coordinate system of template.
%order of params is tx,ty,theta
%if holdrot is nonzero, rotation angle is held fixed (change trans only)
function [newparams,warped] = tr_iteration(template,curim,params,accel,numiter,disp,holdrot)

if (nargin < 7)
    holdrot = 0;
end
if (nargin <  6)
  disp = 0;
end
if (nargin <  5)
  numiter = 1;
end
if (nargin < 4)
  accel = 1;
end

[nr,nc] = size(template);
midr = nr/2;
midc = nc/2;

%% Compute gradients of template
sobelfilt = [[-1,0,1];[-2,0,2];[-1,0,1]/4.0];
Tx = imfilter(template,sobelfilt,'replicate');
Ty = imfilter(template,sobelfilt','replicate');

%% Cache the necessary partial derivatives of the template
ang = params(3);
[x,y] = meshgrid((1:nc)-midc-.5,(1:nr)-midr-.5);
gx = cos(ang) * Tx - sin(ang) * Ty;
gy = sin(ang) * Tx + cos(ang) * Ty;
gr = x .* Ty - y .* Tx;

%run through iterations
for iter=1:numiter

  tx = params(1);
  ty = params(2);
  ang = params(3);

  offset = [1 0 -midc-.5; 0 1 -midr-.5; 0 0 1];
  trans = [1 0 tx; 0 1 ty; 0 0 1];
  rot = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1];
%%  H = offset^(-1) * trans * smat * rot * offset;
  H = trans * rot * offset;
 
  %% Pwarp
  [warped,good] = Pwarp(curim,H,zeros(size(template)));
  good = double(bwmorph(good,'erode',2));
  
  if (iter==1)
    M(1,1) = sum(sum(good .* (gx .* gx)));
    M(1,2) = sum(sum(good .* (gx .* gy)));
    M(1,3) = sum(sum(good .* (gx .* gr)));
    M(2,1) = M(1,2);
    M(2,2) = sum(sum(good .* (gy .* gy)));
    M(2,3) = sum(sum(good .* (gy .* gr)));
    M(3,1) = M(1,3);
    M(3,2) = M(2,3);
    M(3,3) = sum(sum(good .* (gr .* gr)));
  end

  h0 = warped - template;

  vec(1) = sum(sum(good .* (h0 .* gx)));
  vec(2) = sum(sum(good .* (h0 .* gy)));
  vec(3) = sum(sum(good .* (h0 .* gr)));

  if (disp > 0)
    figure(1); colormap(gray); clf;
    subplot(2,4,1); imagesc(template), title('Template');
    subplot(2,4,2); imagesc(warped), title(sprintf('Warped Templ. (Iter: %d)', iter));
    subplot(2,4,3); imagesc(good), title('Pixels not leaving the template');
    subplot(2,4,4); imagesc(h0), title(sprintf('Error Image (Iter: %d)', iter));
    subplot(2,4,5); imagesc(gx), title('Gradient t_x'); % gradient tx
    subplot(2,4,6); imagesc(gy), title('Gradient t_y'); % gradient ty
    subplot(2,4,7); imagesc(gr), title('Gradient rot'); % gradient r
    drawnow;
  end

  delta =  - M \ vec';
  if holdrot
      delta(3) = 0;
  end
  newparams = params + accel*delta;
  params = newparams;

end

tx = params(1);
ty = params(2);
ang = params(3);
offset = [1 0 -midc-.5; 0 1 -midr-.5; 0 0 1];
trans = [1 0 tx; 0 1 ty; 0 0 1];
rot = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1];
H = trans * rot * offset; 
% trans 
% smat 
% rot
% offset
% H
[warped,good] = Pwarp(curim,H,zeros(size(template)));

return
