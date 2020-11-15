function [u,v] = flow_for_templates(template1, template2)
 
    sigma=1.0;
    [Ix, Iy] = gaussderiv(template1, sigma);
	It = gaussianfilter(template2, sigma) - gaussianfilter(template1, sigma);
    A = [sum(sum(Ix.*Ix)),sum(sum(Ix.*Iy)); sum(sum(Ix.*Iy)),sum(sum(Iy.*Iy)) ];
    b = -[sum(sum(Ix.*It)); sum(sum(Iy.*It))];
    trans =  A\b;
    
    %% Result is flow vector i.e. translation from template 1 to 2
    u = trans(1);
    v = trans(2);
    
end

