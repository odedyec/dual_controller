function [X, u] = mimo_response(A, B, K, x0, r, T, u_max, x_max)
dt = 0.005;
n = ceil(T / dt);
% if n == 0
%     X = [];
%     u = [];
%     return
% end

size_states = size(A,1);
size_input = size(B,2);
X = zeros(size_states, n);
u = zeros(size_input, n);
X(:, 1) = x0;
u(:, 1) = zeros(size_input,1);
for i=2:n
    u(:, i) = K * (r - X(:, i-1));
    for s=1:size_input
        u(s, i) = max(min(u(s, i), u_max(s)), -u_max(s));
    end
    x_dot = A * X(:, i-1) + B * u(:, i);
    X(:, i) = X(:, i-1) + x_dot * dt;
    for s=1:size_states
        X(s, i) = max(min(X(s, i), x_max(s)), -x_max(s));
    end
end
