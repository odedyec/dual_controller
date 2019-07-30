%% Setup system and controllers
clc; close all; clearvars
% Plant generation
A = [ 0         0    1.0000         0;
      0         0         0    1.0000;
      0   81.4033  -45.8259   -0.9319;
      0  122.0545  -44.0966   -1.3972];

B =[0;  0; 83.4659; 80.3162];
% High controller design
K_high = lqr(A, B, diag([10, 0 0 0]), 0.3)
K_high(2) = 15;
latex(sym(round(K_high)))

% Low controller controller design
K_low = lqr(A, B,  diag([10, 1 0 0]), 1)
latex(sym(round(K_low)))

%% Response
% setup requirements
setpoint = [deg2rad(30); 0; 0; 0];
Tfinal = 2;
x0 = [0;0;0;0];
U_MAX = 10;
sig = diag([10, 1, 0, 0]); % mostly care about the first state

% Run process;
[y_high, u_high] = control_response(A, B, K_high, x0, setpoint, Tfinal, U_MAX);
[y_low,  u_low]  = control_response(A, B, K_low,  x0, setpoint, Tfinal, U_MAX);

% Plot results
t = 0:0.005:(Tfinal-0.005); figure(1);
subplot(3, 1, 1); plot(t, rad2deg(y_high(1,:)), '--r',  t, rad2deg(y_low(1,:)), 'b'); xlabel('Time[sec]'); ylabel('x_1'); legend('K_{high}', 'K_{low}')
subplot(3, 1, 2); plot(t, rad2deg(y_high(2,:)), '--r', t, rad2deg(y_low(2,:)), 'b'); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}')
subplot(3, 1, 3); plot(t, u_high, '--r', t, u_low, 'b'); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}')

% Calculate performance
J_low = calculate_cost(y_low, setpoint, sig);
J_high = calculate_cost(y_high, setpoint, sig);
% figure(2); plot(t, J_low, 'b', t, J_high, '--r'); xlabel('Time[sec]'); ylabel('e^T \Sigma e(t)'); legend('K_{low}', 'K_{high}');title('cost vs time')
% figure(3); plot(t, cumsum(J_low), 'b', t, cumsum(J_high), '--r'); xlabel('Time[sec]'); ylabel('J'); legend('K_{low}', 'K_{high}');title('cumulative sum of cost vs time')
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
    optimal_switch_gs(A, B, K_high, K_low, t, x0, setpoint, U_MAX, sig);


fprintf('J_dual(t=%.2f)=%.2f   | J_low = %.2f, J_high = %.2f\n', t(idx), sum(J_dual), sum(J_low), sum(J_high))
toc
figure(4); plot(t, J_dual_vals); xlabel('Switch time [sec]'); ylabel('J(t)'); title('Switch time vs cost')
hold on; plot(t(idx), J_dual_vals(idx), 'kX', 'MarkerSize', 14);hold off;
figure(1); 
subplot(3, 1, 1); hold on; plot(t, rad2deg(y_dual(1,:)), '-.g','LineWidth', 2); xlabel('Time[sec]'); ylabel('x_1'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
subplot(3, 1, 2); hold on; plot(t, rad2deg(y_dual(2,:)), '-.g','LineWidth', 2); xlabel('Time[sec]'); ylabel('x_2'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
subplot(3, 1, 3); hold on; plot(t, u_dual, '-.g','LineWidth', 2); xlabel('Time[sec]'); ylabel('u'); legend('K_{high}', 'K_{low}', 'Dual'); hold off;
% figure(2); hold on; plot(t, J_dual, '-.g'); legend('K_{low}', 'K_{high}', 'Dual'); hold off;
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
% for i=1:4
%     fname = sprintf('%d.epsc', i);
%     fname2 = sprintf('%d.eps', i);
%     saveas(i, fname)
%     movefile(fname, fname2)
% end
% save('matlab.mat');
