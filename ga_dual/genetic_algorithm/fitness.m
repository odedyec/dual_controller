function agents = fitness(agents,sim_func, fitness_func)
%FITNESS Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(agents)
    [output, input, ref] = sim_func(agents{i}.K);
    agents{i}.fitness = fitness_func(output, input, ref);
end

