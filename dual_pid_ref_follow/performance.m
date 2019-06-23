function J = performance(r, y, sig)
n = length(y);
J = zeros(1, n);
for i=1:n
    J(i) = (r - y(:, i))' * sig * (r - y(:, i));
end