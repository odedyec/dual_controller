%% Setup system and controllers
close all; clearvars -except J_1000_s number_of_times_to_run run_number
% clc; 
SHOW_AND_SAVE = 1;
% Inline functions
OS = @(os) (sqrt(log(os / 100) ^ 2 / (pi ^ 2 + log(os / 100) ^ 2)));  %calculate zeta from Overshoot requirement
ST = @(st, zeta) (-log(0.05) / zeta / st); % calculate wn from zeta and settling time
P = @(zeta, wn) (roots([1, 2 * zeta * wn, wn ^2 ])); % calculate poles from zeta and wn
% Plant generation
wn = 0.1 * rand;
zeta = .0 * rand;
A_test = [0, 1; -0.15 -0.8]; % -wn^2, -2 * wn * zeta];
random_change = unifrnd(0.5, 1.5, 2, 2); % This changes the matrix A randomly
A_actual = A_test .* random_change; % Remove the .* random_change to disable change in matrix 
B=[0;1];
% High controller design
st = 0.5;%rand() * 1; %Settling time requirement
os = 25;%rand() * 50; % overshoot  requirment
zeta_high = OS(os);
wn_high = ST(zeta_high, st);
p_high = P(zeta_high, wn_high);
K_high = place(A_test, B, p_high);
% K_high = lqr(A, B, diag([10, 0.]), 1e-5)
% K_high = [281 11.6]
if SHOW_AND_SAVE 
    latex(sym(round(K_high)));
end

% Low controller controller design
st2 = 1;%st * 2;
os2 = 1;%os / 25;
zeta_low = OS(os2);
wn_low = ST(zeta_low, st2);

p_low = P(zeta_low, wn_low);
K_low = place(A_test, B, p_low);
% K_low = lqr(A, B,  diag([1, 0.1]), 1e-5)
% K_low = [29.6, 5]
if SHOW_AND_SAVE 
    latex(sym(round(K_low)))
end

%% Response
% setup requirements
setpoint = [0; 0];
Tfinal = 2;
x0 = [5;0];
U_MAX = 1000;
sig = diag([1, 0.01]); % mostly care about the first state

% Run process;
[y_high, u_high] = control_response(A_actual, B, K_high, x0, setpoint, Tfinal, U_MAX);
[y_low,  u_low]  = control_response(A_actual, B, K_low,  x0, setpoint, Tfinal, U_MAX);

% Plot results
t = 0:0.005:(Tfinal-0.005); 
if SHOW_AND_SAVE 
    figure(1);
    subplot(3, 1, 1); plot(t, y_high(1,:), '--r',  t, y_low(1,:), 'b'); xlabel('Time[sec]'); ylabel('x_1'); legend('K_{high}', 'K_{low}')
    subplot(3, 1, 2); plot(t, y_high(2,:), '--r', t, y_low(2,:), 'b'); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}')
    subplot(3, 1, 3); plot(t, u_high, '--r', t, u_low, 'b'); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}')
end

% Calculate performance
J_low = sum((setpoint - y_low)' * sig .* (setpoint - y_low)', 2);
J_high = sum((setpoint - y_high)' * sig .* (setpoint - y_high)', 2);
if SHOW_AND_SAVE
    figure(2); plot(t, J_low, 'b', t, J_high, '--r'); xlabel('Time[sec]'); ylabel('e^T \Sigma e(t)'); legend('K_{low}', 'K_{high}');title('cost vs time')
    figure(3); plot(t, cumsum(J_low), 'b', t, cumsum(J_high), '--r'); xlabel('Time[sec]'); ylabel('J'); legend('K_{low}', 'K_{high}');title('cumulative sum of cost vs time')
end
%% Find cross point
if length(find(J_high - J_low >= 1)) == 0
    t_cp = Tfinal;
    disp('J_high is obviously better')
elseif length(find(J_low - J_high >= 1)) == 0
    t_cp = Tfinal;
    disp('J_low is obviously better')
else
    t_cp = t(find(J_high - J_low < 0,1));
end
% t_cp = Tfinal;%

%% Grid search method
tic
[y_dual, u_dual, J_dual, idx, J_dual_vals] = ...
    optimal_switch_gs(A_test, B, K_high, K_low, t, x0, setpoint, U_MAX, sig);

[y_dual, u_dual, J_dual] = dual_control_response(A_actual, B, K_high, K_low, x0, setpoint, t(idx), t(end), U_MAX, sig);
toc
if SHOW_AND_SAVE
    fprintf('J_dual(t=%.2f)=%.2f   | J_low = %.2f, J_high = %.2f\n', t(idx), sum(J_dual), sum(J_low), sum(J_high))
    fprintf('                      | low = %.2f, high = %.2f\n', (sum(J_low) - sum(J_dual)) / sum(J_low) * 100, (sum(J_high)-sum(J_dual))/sum(J_high)*100);
    random_change

    figure(4); plot(t, J_dual_vals); xlabel('Switch time [sec]'); ylabel('J(t)'); title('Switch time vs cost')
    hold on; plot(t(idx), J_dual_vals(idx), 'kX', 'MarkerSize', 14);hold off;
    figure(1); 
    subplot(3, 1, 1); hold on; plot(t, y_dual(1,:), '-.g', 'LineWidth', 2); xlabel('Time[sec]'); ylabel('x_1'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
    subplot(3, 1, 2); hold on; plot(t, y_dual(2,:), '-.g', 'LineWidth', 2); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
    subplot(3, 1, 3); hold on; plot(t, u_dual, '-.g', 'LineWidth', 2); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
    figure(2); hold on; plot(t, J_dual, '-.g'); legend('K_{low}', 'K_{high}', 'Dual'); hold off;
end
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
% if SHOW_AND_SAVE
%     for i=1:4
%         fname = sprintf('%d.epsc', i);
%         fname2 = sprintf('%d.eps', i);
%         saveas(i, fname)
%         movefile(fname, fname2)
%     end
%     save('matlab.mat');
% end