function [y_dual, u_dual, R] = dual_control_response(sys, K_high, K_low, switch_time)
n2 = floor((sys.Tfinal - switch_time)/sys.dt);
n1 = sys.n - n2;
sys.n = n1;
R = sys.ref_signal;
[y_high_sw, u_high_sw] = control_response(sys, K_high); % start with high controller
if n1 > 0
    sys.x0 = y_high_sw(:, end);
end
sys.n = n2;
[y_low_sw,  u_low_sw]  = control_response(sys, K_low); % continue with low controller
y_dual = [y_high_sw, y_low_sw]; % combine results
u_dual = [u_high_sw, u_low_sw];


