param.Population = 100;
param.Generations = 45;
param.dt = 0.005;
param.T = 2;
param.show = 1;
param.x0 = [0;0;0;0];
param.ref_signal = [pi/6;0;0;0];
param.u_max = 10;
param.A = [ 0         0    1.0000         0;      0         0         0    1.0000;      0   81.4033  -45.8259   -0.9319;      0  122.0545  -44.0966   -1.3972];
param.B = [0;  0; 83.4659; 80.3162];


param.state_cost = diag([1, 0.01, 0, 0]);
param.input_cost = 0;
%% GA generate controllers
% Gen fast controller
param.K_fast_Q = diag([1, 0.01 0 0]);
param.R = 0.01;
param.state_cost = diag([1, 0.01 0 0]);
param.input_cost = param.R;
% Gen slow controller
param.K_slow_Q = diag([1 1 0 0]);
param.R = 0.01;

