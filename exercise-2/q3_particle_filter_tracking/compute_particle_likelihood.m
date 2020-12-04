function [ likelihood ] = compute_particle_likelihood(x,y,m_x,m_y,obssigma_x,obssigma_y )
%function to compute the likelihood of a particle with location (x,y) given
%observation with location (m_x,m_y)

%Input :
% x , y : location of particle
% m_x , m_y : location of observation
% obssigma_x , obssigma_y :  bandwidth for gaussian kernel used in parzen
% density estimation

%Output :
%likelihood : likelihood for particle
likelihood = gaussmf(x-m_x,[obssigma_x 0])*gaussmf(y-m_y,[obssigma_y 0]);

end