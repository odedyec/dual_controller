function [y_dual, u_dual, J_dual, idx, J_dual_vals] = optimal_switch_gs(A, B, K_fast, K_slow, t, x0, setpoint, U_MAX, sig)
J_dual_vals = zeros(length(t), 1);% * max(sum(J_low), sum(J_high));
t = t - t(1);
Tfinal = t(end);
for i=1:length(t)  % iterate through all of the time stamps
      [~, ~, J_for_switch] = dual_control_response(A, B, K_fast, K_slow, x0, setpoint, t(i), Tfinal, U_MAX, sig);
      J_dual_vals(i) = sum(J_for_switch);
end
% finding best switch point
[~, idx] = min(J_dual_vals);
[y_dual, u_dual, J_dual] = dual_control_response(A, B, K_fast, K_slow, x0, setpoint, t(idx), Tfinal, U_MAX, sig);