function stop = myplotfun(~, optimvalues,flag)
global last_vals
stop = false;
if strcmp(flag, 'init')
    last_vals = zeros(500, 2);
end
last_vals(optimvalues.iteration+1, :) = [optimvalues.x, optimvalues.fval];
if optimvalues.iteration < 55
    return
end

% figure(4);
% hold on;

if (abs(last_vals(optimvalues.iteration,2) - last_vals(optimvalues.iteration+1,2)) < 1e-6)
    stop = true;
end
% plot(optimvalues.x, optimvalues.fval, 'xg')
% hold off;
% 