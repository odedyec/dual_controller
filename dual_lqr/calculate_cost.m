function J = calculate_cost(y, r, sig)
J = 0;
n = size(y, 2);
if size(r,2) == n
    R = r;
else
    R = repmat(r, 1, n);
end
for i=1:n
    e = R(:, i) - y(:, i);
    J = e' * sig * e + J;
end