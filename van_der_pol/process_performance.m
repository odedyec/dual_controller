function J = process_performance(X, u)
sig = eye(2);
J = 0;
for x=X
    J = J + x' * sig * x;
end
