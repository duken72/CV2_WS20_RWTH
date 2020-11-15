function im_w = warp_image(im, u, v,xx,yy)
    % Input:
    %   im:  the input image
    %   u,v: the optical flow
    % Output:
    %   im_w: the warped image
    xx = xx + u;
    yy = yy + v;
    im_w = interp2(im,xx,yy);
end