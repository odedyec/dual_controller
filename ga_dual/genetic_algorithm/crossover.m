function agents = crossover(agents, population)
for i=length(agents)+1:2:population
    parent1 = randi(length(agents));
    parent2 = randi(length(agents));
    crossover_amount = rand;
    child1 = Agent(size(agents{1}.K,1), size(agents{1}.K,2));
    child1.K = agents{parent1}.K * crossover_amount + agents{parent2}.K * (1-crossover_amount);
    child2 = Agent(size(agents{1}.K,1), size(agents{1}.K,2));
    child2.K = agents{parent2}.K * crossover_amount + agents{parent1}.K * (1-crossover_amount);
    agents{i} = child1;
    agents{i+1} = child2;
    
end