function [X, u, R] = control_response(sys, K)

X = zeros(size(sys.A, 1), sys.n);
u = zeros(size(sys.B, 2), sys.n);
R = sys.ref_signal;
for i=1:sys.n
    r = R(:,i);
    if i == 1
        u(:, i) = max(min(K * (r - sys.x0), sys.U_MAX), -sys.U_MAX);
        x_dot = sys.A * sys.x0 + sys.B * u(i);
        X(:, i) = sys.x0 + x_dot * sys.dt;
    else
        u(:, i) = max(min(K * (r - X(:, i-1)), sys.U_MAX), -sys.U_MAX);
        x_dot = sys.A * X(:, i-1) + sys.B * u(i);
        X(:, i) = X(:, i-1) + x_dot * sys.dt;
    end
end
