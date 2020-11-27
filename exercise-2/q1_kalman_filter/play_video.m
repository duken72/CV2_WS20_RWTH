function play_video(video)
    frames = size(video,3);
    
    imagesc(video(:,:,1));
    colormap gray;
    truesize;
    
    vm = max(max(max(video)));
    
    for i=1:frames
        imshow(video(:,:,i), [0 vm]);
        pause(0.04); % 25 FPS
        %pause; % Uncomment to go through frames manually
    end
end