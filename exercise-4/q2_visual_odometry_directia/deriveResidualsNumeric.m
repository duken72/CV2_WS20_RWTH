function [ Jac, residual ] = deriveResidualsNumeric( IRef, DRef, I, xi, K )
    %% Start Task: d) Calculate numeric derivatives. (Slow)
    eps = 1e-6;
    Jac = zeros(size(I,1) * size(I,2),6);
    residual = calcResiduals(IRef,DRef,I,xi,K);
    for j=1:6
        epsVec = zeros(6,1);
        epsVec(j) = eps;
        
        xiPerm = xi + epsVec;
        Jac(:,j) = (calcResiduals(IRef,DRef,I,xiPerm,K) - residual) / eps;
    end
    %%%%%% End Task %%%%%%
end

