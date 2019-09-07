function agents = fitness(agents, param)
%FITNESS Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(agents)
    agents{i} = agents{i}.calc_fitness(param);
end

