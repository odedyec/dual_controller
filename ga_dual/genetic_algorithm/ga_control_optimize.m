function [K, agents] = ga_control_optimize(param)
% Setup params
Population = param.Population;
Generations = param.Generations;
Q = param.Q;
R = param.R;
SHOW = param.show;
sys = get_sys(param);
% generate agents
agents = {};
for i=1:Population
    agents{i}=Agent(size(sys.B, 2), size(sys.B, 1));
end

% create inline functions
sim_func = @(K)(control_response(sys, K));
sig_x = param.state_cost;
sig_u = param.input_cost;
fitness_func = @(x, u, r)(calculate_cost(x, u, r, sig_x, sig_u));

% Run GA
for gen=1:Generations
    agents = fitness(agents, sim_func, fitness_func);
    agents = selection(agents, 0.2);
    agents = crossover(agents, Population);
    if gen == Generations
        break
    end
    agents = mutate(agents, 0.3);
end

K = agents{1}.K;
if SHOW
    subplot(2, 1, 1)
    [x, u, r] = sim_func(K);
    K_lqr = lqr(sys.A, sys.B, Q, R);
    [x_lqr, u_lqr, r] = sim_func(K_lqr);
    t = sys.dt:sys.dt:sys.Tfinal;
    plot(t, x(1,:), t, x_lqr(1, :), t, r(1, :), '-k') 
    ylabel('x_1')
    legend('K_{ga}', 'K_{lqr}', 'ref')
    title({'Best controller response', ['K_{ga}: ', num2str(K)], ['f_{ga}: ', num2str(agents{1}.fitness)], ['K_{lqr}: ', num2str(K_lqr)], ['f_{lqr}: ', num2str(fitness_func(x_lqr, u_lqr, r))]})
    subplot(2, 1, 2)
    plot(t, u, t, u_lqr) 
    xlabel('Time[sec]')
    ylabel('u')
end
end
