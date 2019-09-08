function agents = mutate(agents, param)
%MUTATE Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(agents)
    param.current_agent = i;
    agents{i} = agents{i}.mutate(param);
end
end

