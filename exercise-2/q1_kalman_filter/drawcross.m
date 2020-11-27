function drawcross(x, color)
	hold on;
    line([x(1)-2 x(1)+2],[x(2)   x(2)],  'color',color,'linewidth',1);
    line([x(1)   x(1)],  [x(2)-2 x(2)+2],'color',color,'linewidth',1);
    hold off;
end