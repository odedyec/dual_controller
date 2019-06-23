function [y_dual, u_dual, J] = dual_control_response(A, B, K_high, K_low, x0, setpoint, switch_time, T, U_MAX, sig)

[y_high_sw, u_high_sw] = control_response(A, B, K_high, x0, setpoint, switch_time, U_MAX); % start with high controller
if size(y_high_sw, 2) == 0
    [y_low_sw,  u_low_sw]  = control_response(A, B, K_low,  x0, setpoint, T-switch_time, U_MAX); % continue with low controller
else
    [y_low_sw,  u_low_sw]  = control_response(A, B, K_low,  y_high_sw(:, end), setpoint, T-switch_time, U_MAX); % continue with low controller
end
y_dual = [x0, y_high_sw, y_low_sw]; % combine results
u_dual = [0, u_high_sw, u_low_sw];

E = setpoint - y_dual;
J = zeros(length(E),1);
for i=1:size(E,2)
    J(i) = E(:,i)' * sig * E(:,i);
end

