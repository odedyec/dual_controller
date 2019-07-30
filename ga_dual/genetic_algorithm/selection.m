function agents = selection(agents,select_precentage)
%SELECTION Summary of this function goes here
%   Detailed explanation goes here

f_vals = zeros(1, length(agents));
for i = 1:length(agents)
    f_vals(i) = agents{i}.fitness;
end
[v, I] = sort(f_vals);
idx = round(length(agents) * select_precentage);
agents = agents(I);
agents(1:length(agents) > idx) = [];
% outputArg2 = select_precentage;
end

