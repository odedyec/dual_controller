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

figure(1);clf;pause(0.1)
[k_f, k_s, ag] = ga_control_optimize(param);

%% GA moving t_switch
param.show = 0;
data = [];
for t=0.08:param.dt:0.15
    param.t_switch_constant = t;
    [k_f, k_s, ag] = ga_control_optimize(param);
    disp(['t_switch = ', num2str(t), '   f = ', num2str(ag{1}.fitness)])
    data = [data; [t, k_f, k_s, ag{1}.fitness]];
    k_f
    k_s
end
    
% ag{1}.t_switch
% ag{1}.fitness
%% Show each one by itself
% k = [100 2];
% [x, u, r] = control_response(get_sys(param), k_f);
% J = calculate_cost_response(x, u, r, param)
% %% Plot single controller response
% subplot(2, 1, 1)
% hold on
% plot(param.dt:param.dt:param.T, x(1, :))
% hold off
% subplot(2, 1, 2)
% hold on
% plot(param.dt:param.dt:param.T, u(1, :))
% hold off

%%
% my_k_fast = [10, 0];
% my_k_slow = [2, 2];
% [x, u, J_dual, idx, J_dual_vals] = optimal_switch_gs(get_sys(param), my_k_fast, my_k_slow, param);
% figure(3);
% plot(param.dt:param.dt:param.T, J_dual_vals(2:end))
% calculate_cost_response(X, u, param.ref_signal, param)
% figure(2); clf;
% subplot(2, 1, 1)
% hold on
% plot(param.dt:param.dt:param.T, x(1, :), [param.dt * idx, param.dt * idx], [0, 10], 'r')
% hold off
% subplot(2, 1, 2)
% hold on
% plot(param.dt:param.dt:param.T, u(1, :))
% hold off