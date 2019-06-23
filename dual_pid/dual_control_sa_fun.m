function J = dual_control_sa_fun(A, B, K_high, K_low, x0, setpoint, tsw, Tfinal, U_MAX, sig)
[~, ~, J_dual] = dual_control_response(A, B, K_high, K_low, x0, setpoint, tsw, Tfinal, U_MAX, sig);
J = sum(J_dual);