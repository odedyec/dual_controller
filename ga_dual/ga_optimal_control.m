%% clean up
clear all
clc;
%% GA param
param.Population = 500;
param.Generations = 30;
param.Selection = 0.2;
param.mutate_probability = 0.3;
%% System params
param.dt = 0.005;
param.T = 2;
param.show = 1;
param.x0 = [0;0;0;0];
param.ref_signal = [pi/6;0;0;0];
param.u_max = 10;
param.A = [ 0         0    1.0000         0;      0         0         0    1.0000;      0   81.4033  -45.8259   -0.9319;      0  122.0545  -44.0966   -1.3972];
param.B = [0;  0; 83.4659; 80.3162];

%% GA generate controllers
% Gen fast controller
param.Q = diag([10, 10 0 0]);
param.R = 0.001;

%% LQR response
K_lqr = lqr(param.A, param.B, param.Q, param.R);
[X, u, ref] = control_response(get_sys(param), K_lqr);
J = 0;
for i=1:length(u)
    e = ref(:, i) - X(:, i);
    J = e' * param.Q * e + u(:, i)' * param.R * u(:, i) + J;
end 
disp(['Lqr cost is ', num2str(J)])
figure(1)
t = param.dt:param.dt:param.T;
subplot(2, 1, 1)
plot(t, X(1, :) * 180 / pi, t, ref(1, :) * 180 / pi, 'r-')
ylabel('\theta')
subplot(2, 1, 2)
plot(t, X(2, :) * 180 / pi, t, ref(2, :) * 180 / pi, 'r-')
xlabel('t[sec]')
ylabel('\alpha')
%% GA

% create inline functions
sys = get_sys(param);

% create set of agents
agents = {param.Population, 1};
for i=1:param.Population
    agents{i}=DualControlAgent(size(sys.B, 2), size(sys.B, 1), param.T);
end
%%
% agents = ga_optimize(agents, param);
[X, u, ref] = dual_control_response(get_sys(param), ...
    agents{1}.K_fast, agents{1}.K_slow, agents{1}.t_switch);
J = 0;
for i=1:length(u)
    e = ref(:, i) - X(:, i);
    J = e' * param.Q * e + u(:, i)' * param.R * u(:, i) + J;
end 
disp(['K_dual cost is ', num2str(J)])
figure(1)
subplot(2, 1, 1)
hold on;
plot(t, X(1, :) * 180 / pi, 'g')
hold off
subplot(2, 1, 2)
hold on;
plot(t, X(2, :) * 180 / pi, 'g')
legend('lqr controller', 'reference', 'GA controller')
hold off;
figure(2)
plot(t, u, 'g')