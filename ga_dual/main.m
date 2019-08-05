%% Cleanup and setup
addpath('genetic_algorithm/')
addpath('utils/')
addpath('dual_control/')
close all;
clear all
clc;
%% Set main parameters
set_param_pp
param.settling_time_precentage = 0.05;
param.overshoot_cost = 0.5;
param.rise_time_cost = 0.;
param.settling_time_cost = 0.5;
param.energy_cost = 0.4;
%% GA generate controllers
% Gen fast controller
param.overshoot_cost = 0.05;
param.rise_time_cost = .85;
param.settling_time_cost = 0.;
param.energy_cost = 0.10;
param.Q = param.K_fast_Q;
param.R = 0.000001;
figure(1)
K_fast = ga_control_optimize(param);
%% Gen slow controller
param.overshoot_cost = 0.005;
param.rise_time_cost = 0.005;
param.settling_time_cost = 0.0;
param.energy_cost = 0.99;
param.Q = param.K_slow_Q;
param.R = 0.01;
figure(2)
K_slow = ga_control_optimize(param);

%% Find switch point
param.overshoot_cost = 0.3;
param.rise_time_cost = 0.2;
param.settling_time_cost = 0.;
param.energy_cost = 0.5;
[X, u, J_dual, idx, J_dual_vals] = optimal_switch_gs(get_sys(param), K_fast, K_slow, param);
figure(3)
disp(['Switch time: ', num2str(idx * param.dt), '  |   J_dual: ', num2str(J_dual)]);
control_response(get_sys(param), K_slow);
sys = get_sys(param);
t = sys.dt:sys.dt:sys.Tfinal;
plot(t, J_dual_vals(1:end-1, 1), idx * sys.dt, J_dual, 'Xr') 
title('Switch time vs cost')
ylabel('J(t)')
xlabel('Switch time[sec]')
figure(4)
plot(t, X(1, :))
xlabel('t[sec]')
ylabel('x_1')