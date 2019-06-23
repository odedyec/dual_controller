%% Setup system and controllers
clc; close all; clearvars
% Inline functions
OS = @(os) (sqrt(log(os / 100) ^ 2 / (pi ^ 2 + log(os / 100) ^ 2)));  %calculate zeta from Overshoot requirement
ST = @(st, zeta) (-log(0.05) / zeta / st); % calculate wn from zeta and settling time
P = @(zeta, wn) (roots([1, 2 * zeta * wn, wn ^2 ])); % calculate poles from zeta and wn
% Plant generation
wn = 0.1 * rand;
zeta = .0 * rand;
A = [0, 1; -0.15 -0.8]; % -wn^2, -2 * wn * zeta];
B=[0;1];
% High controller design
st = 0.5; %rand() * 1; %Settling time requirement
os = 25; %rand() * 50; % overshoot  requirment
zeta_high = OS(os);
wn_high = ST(zeta_high, st);
p_high = P(zeta_high, wn_high);
K_high = place(A, B, p_high)
% K_high = lqr(A, B, diag([10, 0.]), 1e-5)
% K_high = [2 .6]
latex(sym(round(K_high)))

% Low controller controller design
st2 = 1; %st * 2;
os2 = 1;
zeta_low = OS(os2);
wn_low = ST(zeta_low, st2);

p_low = P(zeta_low, wn_low);
K_low = place(A, B, p_low)
% K_low = lqr(A, B,  diag([1, 0.1]), 1e-5)
% K_low = [5.6, .5]
latex(sym(round(K_low)))

%% Response
% setup requirements
dt = 0.005;
number_of_occur = 2;
Tfinal = 2 * 2 * number_of_occur;
r1 = [5;0];
R1 = repmat([5;0], 1, 400);
R2 = repmat([0;0], 1, 400);
setpoint = repmat([R1 R2], 1, number_of_occur);

x0 = [0;0];
U_MAX = 1000;
sig = diag([1, 0.01]); % mostly care about the first state

% Run process;
[y_high, u_high] = control_response(A, B, K_high, x0, setpoint, Tfinal, U_MAX);
[y_low,  u_low]  = control_response(A, B, K_low,  x0, setpoint, Tfinal, U_MAX);

% Plot results
t = 0:0.005:(Tfinal-0.005); figure(1);
subplot(9, 1, 2:5); plot(t, y_high(1,:), '--r',  t, y_low(1,:), 'b', 'MarkerSize', 14); ylabel('x_1'); legend('K_{high}', 'K_{low}')
subplot(9, 1, 6:9); plot(t, y_high(2,:), '--r', t, y_low(2,:), 'b', 'MarkerSize', 14); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}')
% subplot(3, 1, 3); plot(t, u_high, '--r', t, u_low, 'b'); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}')

% Calculate performance
J_low = zeros(length(t), 1); J_high = zeros(length(t), 1);
for i=1:length(t)
    J_low(i) = sum((setpoint(:, i) - y_low(:, i))' * sig .* (setpoint(:, i) - y_low(:, i))');
    J_high(i) = sum((setpoint(:, i) - y_high(:, i))' * sig .* (setpoint(:, i) - y_high(:, i))');
end
figure(2); plot(t, J_low, 'b', t, J_high, '--r', 'MarkerSize', 18); xlabel('Time[sec]'); ylabel('J'); legend('K_{low}', 'K_{high}');title('cost vs time')
figure(3); plot(t, cumsum(J_low), 'b', t, cumsum(J_high), '--r'); xlabel('Time[sec]'); ylabel('J'); legend('K_{low}', 'K_{high}');title('cumulative sum of cost vs time')
%% Find cross point
% if length(find(J_high - J_low >= 1)) == 0
%     t_cp = Tfinal;
%     disp('J_high is obviously better')
% elseif length(find(J_low - J_high >= 1)) == 0
%     t_cp = Tfinal;
%     disp('J_low is obviously better')
% else
%     t_cp = t(find(J_high - J_low < 0,1));
% end
% t_cp = Tfinal;%

%% Grid search method
tic
idxs = [];
horizon = 0.3 / dt;
y_dual = x0;
y_dual_global = zeros(2, length(setpoint));
u_dual_global = zeros(1, length(setpoint));
J_dual_global = zeros(1, length(setpoint));
op_controller = zeros(1, length(setpoint));
for i=1:floor(horizon):length(t)-floor(horizon)
    [y_dual, u_dual, J_dual, idx, J_dual_vals] = optimal_switch_gs(A, B, K_high, K_low, t(i:i+floor(horizon)), y_dual(:,end), setpoint(:,i:i+floor(horizon)), U_MAX, sig);
    idxs = [idxs idx];
    sum(J_dual)
    y_dual_global(:,i:i+floor(horizon)) = y_dual;%(:, 2:end);
    u_dual_global(:,i:i+floor(horizon)) = u_dual;%(:, 2:end);
    J_dual_global(:,i:i+floor(horizon)) = J_dual;%(:, 2:end);
    op_controller(i:i+idx-2) = 1;
    fprintf('T_start: %.2f, T_end: %.2f\n', t(i), t(i+floor(horizon)));
%     fprintf('J_dual(t=%.2f)=%.2f   | J_low = %.2f, J_high = %.2f\n', t(idx), sum(J_dual), sum(J_low), sum(J_high))
end
toc
% idxs
% figure(4); plot(t, J_dual_global); xlabel('Switch time [sec]'); ylabel('J(t)'); title('Switch time vs cost')
% hold on; plot(t(idx), J_dual_global(idx), 'kX', 'MarkerSize', 14);hold off;
fprintf('J_dual(t=%.2f)=%.2f   | J_low = %.2f, J_high = %.2f\n', t(idx), sum(J_dual_global), sum(J_low), sum(J_high))

figure(1); 
subplot(9, 1, 2:5); hold on; plot(t, setpoint(1, :), '.--k');plot(t, y_dual_global(1,:), '-.g','LineWidth', 2);  ylabel('x_1'); legend('K_{high}', 'K_{low}', 'Dual', 'ref'); hold off;set(gca, 'xtick', [])
subplot(9, 1, 6:9); hold on; plot(t, y_dual_global(2,:), '-.g','LineWidth', 2); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
subplot(9, 1, 1);plot(t, op_controller, '.', 'MarkerSize', 4);set(gca,'ytick',[0:1],'yticklabel',{'K_{low}', 'K_{high}'});set(gca, 'xtick', [])
%hold on; plot(t, u_dual_global, '-.g'); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
figure(2); hold on; plot(t, J_dual_global, '-.g'); legend('K_{low}', 'K_{high}', 'Dual'); hold off;

%% Simulated Annealing
% tic
% opt = optimoptions(@simulannealbnd, 'Display', 'final', ...
%     'reannealinterval', 200, ...
%     'MaxIterations', 30, ...
%     'FunctionTolerance', 1e1);%,...
% %     'plotfcn', @myplotfun
% sa_fun = @(tsw) (dual_control_sa_fun(A, B, K_high, K_low, x0, setpoint, tsw, Tfinal, U_MAX, sig));
% [t_sw_sa, J_sa] = simulannealbnd(sa_fun, t_cp/2, 0, t_cp, opt);
% toc
% figure(4); hold on; plot(t_sw_sa, J_sa, 'xr'); legend('Grid search', 'Optimal point', 'Simulated annealing'); hold off
%% save images
close(2)
close(3)
for i=1:1
    fname = sprintf('%d.epsc', i);
    fname2 = sprintf('%d.eps', i);
    saveas(i, fname)
    movefile(fname, fname2)
end
save('matlab.mat');
