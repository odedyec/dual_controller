%% Cleanup and setup
addpath('genetic_algorithm/')
addpath('utils/')
addpath('dual_control/')
close all;
clear all
clc;
%% Set main parameters
set_param_pp
%% GA generate controllers
% Gen fast controller
param.Q = param.K_fast_Q;
param.R = 0.01;
figure(1)
K_fast = ga_control_optimize(param);
% Gen slow controller
param.Q = param.K_slow_Q;
param.R = 0.01;
figure(2)
K_slow = ga_control_optimize(param);
%% Find switch point
% param.Q = diag([1, 0.01]);
% param.R = 0.01;
% param.state_cost = param.Q;
% param.input_cost = 0;

[X, u, J_dual, idx, J_dual_vals] = optimal_switch_gs(get_sys(param), K_fast, K_slow, param);
figure(3)
J_dual
sys = get_sys(param);
t = sys.dt:sys.dt:sys.Tfinal;
plot(t, J_dual_vals(1:end-1, 1), idx * sys.dt, J_dual, 'Xr') 