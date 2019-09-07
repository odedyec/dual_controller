param.Population = 100;
param.Generations = 10;
param.dt = 0.005;
param.T = 2;
param.show = 1;
param.x0 = [0;0];
param.ref_signal = [10;0];
param.u_max = 4000;
param.A = [0. 1; 0.015, 1.80];
param.B = [0; 1];
param.state_cost = diag([1, 0.01]);
param.input_cost = 0;
param.mutate_prob = 0.8;

param.overshoot_cost = 0.2;
param.rise_time_cost = 0.2;
param.settling_time_cost = 0.3;
param.energy_cost = 0.05;
param.gain_cost = 0.02;
param.gain_t_switch = 0.1;
