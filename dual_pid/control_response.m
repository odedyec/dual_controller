function [X, u] = control_response(A, B, K, x0, r, T, u_max)
dt = 0.005;
n = round(T / dt);
if size(r,2) > 1
    R = r;
else
    R = repmat(r, 1, n);
end
X = zeros(size(A,1), n);
u = zeros(1, n);
if n == 0
    return
end

for i=1:n
    r = R(:,i);
    if i == 1
        u(i) = max(min(K * (r - x0), u_max), -u_max);
        x_dot = A * x0 + B * u(i);
        X(:, i) = x0 + x_dot * dt;
    else
        u(i) = max(min(K * (r - X(:, i-1)), u_max), -u_max);
        x_dot = A * X(:, i-1) + B * u(i);
        X(:, i) = X(:, i-1) + x_dot * dt;
    end
end
