function J = calculate_cost(y, u, r, Q, R)
J = 0;
n = size(y, 2);

for i=1:n
    e = r(:, i) - y(:, i);
    J = e' * Q * e + u(:, i)' * R * u(:, i) + J;
end