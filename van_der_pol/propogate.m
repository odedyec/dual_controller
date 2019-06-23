function [y, X] = propogate(X, u ,eps)
%PROPOGATE Summary of this function goes here
%   Detailed explanation goes here
% Unpack
x1 = X(1);
x2 = X(2);

% Equations
x_1 = x2;
x_2 = -x1 + eps*(1 - x1^2) * x2 + u;

% Propogate and pack
dt = 0.05;
x1 = x1 + dt * x_1;
x2 = x2 + dt * x_2;
y = x1;
X(1) = x1;
X(2) = x2;
end

