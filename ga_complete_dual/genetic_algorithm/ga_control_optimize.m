function [K_fast, K_slow, agents] = ga_control_optimize(param)
% Setup params
Population = param.Population;
Generations = param.Generations;

SHOW = param.show;
sys = get_sys(param);
% generate agents
agents = {};
for i=1:Population
    if isfield(param, 't_switch_constant')
        agents{i}=Agent(size(sys.B, 2), size(sys.B, 1), param.T, param.t_switch_constant);
    else
        agents{i}=Agent(size(sys.B, 2), size(sys.B, 1), param.T);
    end
end

% create inline functions
sim_func = @(K_fast, K_slow, t_switch)(dual_control_response(sys, K_fast, K_slow, t_switch));
fitness_func = @(x, u, r, agent, params)(calculate_cost_response(x, u, r, agent, params));

% Run GA
for gen=1:Generations
    agents = fitness(agents, sim_func, fitness_func, param);
    agents = selection(agents, 0.2);
    agents = crossover(agents, Population);
    if gen == Generations
        break
    end
    if SHOW
        my_draw(agents, sim_func, fitness_func, param, gen);
    end
    agents = mutate(agents, param.mutate_prob);
end

K_fast = agents{1}.K_fast;
K_slow = agents{1}.K_slow;
if SHOW
    my_draw(agents, sim_func, fitness_func, param, gen);
end
end

function my_draw(agents, sim_func, fitness_func, param, gen)
K_fast = agents{1}.K_fast;
K_slow = agents{1}.K_slow;
subplot(2, 1, 1)
[x, u, r] = sim_func(K_fast, K_slow, agents{1}.t_switch);
t = param.dt:param.dt:param.T;
plot(t, x(1,:), t, r(1, :), '-k', [agents{1}.t_switch, agents{1}.t_switch], [0, r(1,end)], '--r') 
ylabel('x_1')
legend('K_{ga}', 'ref')
title({'Best controller response', ['K_{fast}: ', num2str(K_fast), '  K_{slow}: ', num2str(K_slow)], ['f_{ga}: ', num2str(agents{1}.fitness), '  t_{sw}: ', num2str(agents{1}.t_switch)]})
subplot(2, 1, 2)
plot(t, u) 
xlabel('Time[sec]')
ylabel('u')
disp('----------------------------------------')
disp(['---------------  Gen: ', num2str(gen),  '  ---------------'])
S = stepinfo(x(1,:),t,r(1, end));
disp(['OS: ', num2str(S.Overshoot)])
disp(['T_rt: ', num2str(S.RiseTime * 100 / param.T)])
disp(['T_st: ', num2str(S.SettlingTime * 100 / param.T)])
disp(['J: ', num2str(agents{1}.fitness)])
disp('========================================')
drawnow();
% pause
end