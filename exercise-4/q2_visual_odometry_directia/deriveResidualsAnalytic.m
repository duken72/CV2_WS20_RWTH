function [ Jac, residual ] = deriveResidualsAnalytic( IRef, DRef, I, xi, K )

    % Get shorthands (R, t)
    T = se3Exp(xi);
    R = T(1:3, 1:3);
    t = T(1:3,4);
    KInv = K^-1;
    RKInv = R * K^-1;

    %%%%%% Start Task: f) Determine derivatives
    %
    %%%%%% End Task %%%%%%
end
