function [T] = se3Exp(twist)
    %% Start Task: b) Implement se3Exp
    v = twist(1:3);     omega = twist(4:6);
    omega_hat = [0       -omega(3)  omega(2);
                 omega(3) 0        -omega(1);
                -omega(2) omega(1)  0];
    M = [omega_hat, v;
        0 0 0 0];
    T = expm(M);
    
    %T(1:3,1:3) = eye(3) + sin(omega)/abs(omega)*omega_hat + (1.-cos(omega))/abs(omega)^2*omega_hat^2;
    %A = eye(3) + (1.-cos(omega))/abs(omega)^2*omega_hat + (abs(omega)-sin(abs(omega)))/abs(omega)^3*omega_hat^2;
    %T(1:3,end) = A*v;
    %%%%% End Task
end

