function agents = fitness(agents,sim_func, fitness_func, param)
%FITNESS Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(agents)
    [output, input, ref] = sim_func(agents{i}.K_fast, agents{i}.K_slow, agents{i}.t_switch);
    agents{i}.fitness = fitness_func(output, input, ref, agents{i}, param);    
end

