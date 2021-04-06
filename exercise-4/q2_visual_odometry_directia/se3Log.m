function [twist] = se3Log(T)
    %% Start Task: b) Implement se3Log
    lg = logm(T);
    twist = [lg(1:3,4); lg(3,2); lg(1,3); lg(2,1)];
    %%%%% End Task
end