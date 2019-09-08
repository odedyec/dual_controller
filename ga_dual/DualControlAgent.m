classdef DualControlAgent
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fitness
        K_fast
        K_slow
        t_switch
        low
        high
        T
        inp_size
        out_size
    end
    
    methods
        function agent = DualControlAgent(inp_size, out_size, T)
            %AGENT Construct an instance of this class
            %   Detailed explanation goes here
            agent.low = -10;
            agent.high = 60;
            agent.out_size = out_size;
            agent.inp_size = inp_size;
            agent.K_fast = randn(agent.inp_size, agent.out_size) * agent.high;
            agent.K_slow = randn(agent.inp_size, agent.out_size) * agent.high;
            agent.t_switch = T * rand;
            agent.fitness = inf;
            agent.T = T;
        end
        
        function agent = set_fitness(agent, val)
            agent.fitness = val;
        end
        
        function outputArg = is_bigger(agent,other)
            outputArg = (agent.fitness > other.fitness);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%   MUTATE FUNCTIONS     %%%%%%%%%%%%%%%%%%%%%%%%%
        function agent = mutate(agent, param)
            agent = agent.mutate_fast(param);
            agent = agent.mutate_slow(param);
            agent = agent.mutate_switch(param);
        end
        
        
        function agent = mutate_switch(agent, param)
            if param.current_agent < 4
                return
            end
            mutate_probability = param.mutate_probability;
            if rand > 1 - mutate_probability
                agent.t_switch = agent.t_switch * (0.5 + rand * 0.5);
            end
        end
        
        function agent = mutate_fast(agent, param)
            mutate_probability = param.mutate_probability;
            if rand > 1 - mutate_probability
                agent.K_fast = randn(agent.inp_size, agent.out_size) * agent.high;
            end
        end
        
        function agent = mutate_slow(agent, param)
            mutate_probability = param.mutate_probability;
            if rand > 1 - mutate_probability
                agent.K_slow = randn(agent.inp_size, agent.out_size) * agent.high;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%   CROSSOVER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%
        function new_agent = crossover(agent, other)
            new_agent = DualControlAgent(agent.inp_size, agent.out_size, agent.T);
            crossover_amount = rand;
            new_agent.K_fast = agent.K_fast * crossover_amount + other.K_fast * (1-crossover_amount);
            crossover_amount = rand;
            new_agent.K_slow = agent.K_slow * crossover_amount + other.K_slow * (1-crossover_amount);
            crossover_amount = rand;
            new_agent.t_switch = agent.t_switch * crossover_amount + other.t_switch * (1-crossover_amount);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%   FITNESS FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%
        function agent = calc_fitness(agent, param)
            [X, u, r] = dual_control_response(get_sys(param), agent.K_fast, agent.K_slow, agent.t_switch);
            J = 0;
            n = size(X, 2);

            for i=1:n
                e = r(:, i) - X(:, i);
                J = e' * param.Q * e + u(:, i)' * param.R * u(:, i) + J;
            end 
            agent.fitness = J;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

