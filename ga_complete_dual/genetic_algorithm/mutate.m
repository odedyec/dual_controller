function agents = mutate(agents,mutate_probability)
%MUTATE Summary of this function goes here
%   Detailed explanation goes here
param.what_to_mutate = [0, 0, 0];
param.what_to_mutate(randi([1, 2])) = 1;
for i=1:length(agents)
    reduce_prob = 1; min(1, i / 10);  %% The top 10 less likely to mutate
    param.mutate_probability = mutate_probability * reduce_prob;
    agents{i}.mutate(param);
end
end

