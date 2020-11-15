function outimg = gaussianfilter(inimg, sigma)
	
	padding = 1;

	% generate 1D Gaussian
	w = ceil(3*sigma);
	x = -w : w; % size of the filter: 2*ceil(3*sigma)+1
	gaussian = double(gauss(x,sigma));

	if padding
		% pad boundaries with black pixels
		binimg = zeros(size(inimg)+(2*w));
		binimg(w+1:end-w,w+1:end-w) = inimg;
	else
		binimg = inimg;
	end
		  	 
	[nbr_lines nbr_columns] = size(binimg);
	tmpimg = double(zeros(size(binimg)));
	outimg = double(zeros(size(binimg)));

	% apply to lines
	for c = w+1:nbr_columns-w
		for l = 1:nbr_lines
			tmpimg(l,c) = binimg(l,c-w:c+w) * gaussian';
		end
	end

	% apply to columns
	for c = 1:nbr_columns
		for l = w+1:nbr_lines-w
			outimg(l,c) = tmpimg(l-w:l+w,c)' * gaussian';
		end
	end

	if padding
		% clip boundaries
		outimg = outimg(w+1:end-w,w+1:end-w);
	end
end
