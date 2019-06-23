clc;
K1 = [10, 5];
K2 = [1, 1.5];
X0 = [5;3];
n = 100;
dt = 0.05;
J = zeros(n, 1);
for i=1:n
    [X, u] = van_der_pol(K1, K2, i, X0, n);
    J(i) = process_performance(X, u);
end
[J_dual, t_sw] = min(J);
% K1 performance
[X1, u1] = van_der_pol(K1, K2, 100000, X0, n);
J_1 = process_performance(X1, u)
% disp(['Energy used is', num2str(sum(u.^2))])
 
% K2 performance
[X2, u2] = van_der_pol(K1, K2, 0, X0, n);
J_2 = process_performance(X2, u)
% disp(['Energy used is', num2str(sum(u.^2))])

% Kdual performance
[X_dual, u_dual] = van_der_pol(K1, K2, t_sw, X0, n);
J_dual = process_performance(X_dual, u)
% disp(['Energy used is', num2str(sum(u.^2))])
(J_1 - J_dual)/J_1
(J_2 - J_dual)/J_2
%% Plot stuff
T = (1:n) * dt;
figure(1)
plot(T, J)
xlabel('Switch Time[sec]')
ylabel('J')
figure(2);
subplot(2, 1, 1); plot(T, X1(1, :), '--r', T, X2(1, :), 'b', T, X_dual(1, :),  '-.g', 'LineWidth', 2);
ylabel('X_1')
legend('K_{fast}', 'K_{slow}', 'K_{dual}')
subplot(2, 1, 2); plot(T, X1(2, :), '--r', T, X2(2, :), 'b', T, X_dual(2, :),  '-.g', 'LineWidth', 2);
ylabel('X_2')
xlabel('Time[sec]')
legend('K_{fast}', 'K_{slow}', 'K_{dual}')
figure(3)
plot(T, u1, '--r', T, u2, 'b', T, u_dual,  '-.g', 'LineWidth', 2);
ylabel('u')
xlabel('Time[sec]')
legend('K_{fast}', 'K_{slow}', 'K_{dual}')
% saveas(1, '1.epsc')
% movefile('1.epsc', '1.eps')
% saveas(2, '2.epsc')
% movefile('2.epsc', '2.eps')
% save('van_der_pol.mat')