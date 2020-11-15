function [imgDx, imgDy] = gaussderiv(img, sigma)
	x = [floor(-3.0 * sigma + 0.5):floor(3.0 * sigma + 0.5)];
	gaussian = gauss(x, sigma);
	derivative = gaussdx(x, sigma);

	temp = conv2(img, derivative, 'same');
	imgDx= conv2(temp, gaussian', 'same');

	temp = conv2(img, gaussian, 'same');
	imgDy= conv2(temp, derivative', 'same');
end


