function [X, u] = van_der_pol(K1, K2, t_sw, X0, n)
X = zeros(2, n);
u = zeros(1, n);
X(:, 1) = X0;
eps = 0.1;

controller = @(X, v)(X(1) + v - eps * (1 - X(1) ^2) * X(2));


for t=2:n
    if t < t_sw
        K = K1;
    else
        K = K2;
    end
    v = -K * X(:, t-1);
    u(t) = controller(X(:, t-1), v);
    [~, x] = propogate(X(:, t-1), u(t), eps*1.);
    X(:, t) = x;
end
