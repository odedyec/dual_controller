function [agents] = ga_optimize(agents, param)
% Setup params
Population = param.Population;
Generations = param.Generations;
SHOW = param.show;
% Run GA
for gen=1:Generations
    agents = fitness(agents, param);
    agents = selection(agents, param.Selection);
    agents = crossover(agents, Population);
    if gen == Generations
        break
    end
    if SHOW
        my_draw(agents, param, gen);
    end
    agents = mutate(agents, param);
end

end

function my_draw(agents, param, gen)
disp('----------------------------------------')
disp(['---------------  Gen: ', num2str(gen),  '  ---------------'])
disp(['J: ', num2str(agents{1}.fitness)])
disp('========================================')
drawnow();
% pause
end