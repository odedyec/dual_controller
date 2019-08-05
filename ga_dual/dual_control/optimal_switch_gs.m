function [X, u, J_dual, idx, J_dual_vals] = optimal_switch_gs(sys, K_fast, K_slow, param)
J_dual_vals = zeros(sys.n, 1);% * max(sum(J_low), sum(J_high));
t = 0:sys.dt:sys.Tfinal;
for i=1:length(t)  % iterate through all of the time stamps
      [X, u, R] = dual_control_response(sys, K_fast, K_slow, t(i));
      J = calculate_cost_response(X, u, R, param); %.state_cost, param.input_cost);
      J_dual_vals(i) = sum(J);
end
% finding best switch point
[~, idx] = min(J_dual_vals);
[X, u, ~] = dual_control_response(sys, K_fast, K_slow, t(idx));
J_dual = J_dual_vals(idx);