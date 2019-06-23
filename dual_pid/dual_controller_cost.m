function cost = dual_controller_cost(A, B, K_high, K_low, x0, setpoint, tsw, Tfinal, U_MAX, sig)
ans = dual_control_response(A, B, K_high, K_low, x0, setpoint, tsw, Tfinal, U_MAX, sig);
cost = ans(3);