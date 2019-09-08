function [agents] = ga_optimize(agents, param)
% Setup params
Population = param.Population;
Generations = param.Generations;
SHOW = param.show;
% Run GA
for gen=1:Generations
    param.gen = gen;
    agents = fitness(agents, param);
    if SHOW
        my_draw(agents, param);
    end
    agents = selection(agents, param.Selection);
    agents = crossover(agents, Population);
    if gen == Generations
        break
    end
    agents = mutate(agents, param);
end

end

function my_draw(agents, param)
disp('----------------------------------------')
disp(['---------------  Gen: ', num2str(param.gen),  '  ---------------'])
disp(['J: ', num2str(agents{1}.fitness)])
disp(['J: ', num2str(agents{1}.fitness)])

t_s = zeros(1, length(agents));
f   = zeros(1, length(agents));
figure(98)
gcf
t = param.dt:param.dt:param.T;
for i=1:length(agents)
    t_s(i) = agents{i}.t_switch;
    f(i)   = agents{i}.fitness;
    if f(i) < 3000
        [X, u, ref] = dual_control_response(get_sys(param), agents{i}.K_fast, agents{i}.K_slow, agents{1}.t_switch);
        subplot(2, 1, 1)
        hold on;
        plot(t, X(1, :) * 180 / pi)
        hold off
        subplot(2, 1, 2)
        hold on;
        plot(t, X(2, :) * 180 / pi)
        hold off;
    end
end
disp(['t_\mu: ', num2str(mean(t_s)), '   t_std: ', num2str(std(t_s))])
disp(['f_\mu: ', num2str(mean(f)), '   f_std: ', num2str(std(f))])
figure(97) 
hist(t_s)
drawnow();
disp('========================================')
% pause
end