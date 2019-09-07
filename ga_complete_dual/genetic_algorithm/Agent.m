classdef Agent
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
        function agent = Agent(inp_size, out_size, T, t_switch)
            %AGENT Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 4
                agent.t_switch = rand * T;
            else
                agent.t_switch = t_switch;
            end
            agent.low = -3;
            agent.high = 30;
            agent.out_size = out_size;
            agent.inp_size = inp_size;
            agent.K_fast = randn(agent.inp_size, agent.out_size) * agent.high;
            agent.K_slow = randn(agent.inp_size, agent.out_size) * agent.high;
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
            mutate_probability = param.mutate_probability;
            if param.what_to_mutate(1)
                for j=1:length(agent.K_fast)
                    if rand > 1 - mutate_probability
                        agent = agent.mutate_fast(j);
                    end
                end
            end
            
            if param.what_to_mutate(2)
                for j=1:length(agent.K_slow)
                    if rand > 1 - mutate_probability
                        agent = agent.mutate_slow(j);
                    end
                end
            end

            if param.what_to_mutate(3)
                for j=1:length(agent.K_slow)
                    if rand > 1 - mutate_probability
                        agent = agent.mutate_switch();
                    end
                end
            end
        end
        
        function agent = mutate_fast(agent, i)
            val = 1.3 * rand + 0.7;  % Uniform random between [0.5, 2]
            agent.K_fast(i) = val * agent.K_fast(i);
        end

        function agent = mutate_slow(agent, i)
            val = 1.3 * rand + 0.7;  % Uniform random between [0.5, 2]
            agent.K_slow(i) = val * agent.K_slow(i);
        end

        function agent = mutate_switch(agent)
              val = 1.1 * rand + 0.9;  % Uniform random between [0.5, 2]
              agent.t_switch = min(agent.t_switch * val, agent.T);
        end        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%   CROSSOVER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%
        function new_agent = crossover(agent, other)
            new_agent = Agent(agent.inp_size, agent.out_size, agent.T);
            crossover_amount = rand;
            new_agent.K_fast = agent.K_fast * crossover_amount + other.K_fast * (1-crossover_amount);
            new_agent.K_slow = agent.K_slow * crossover_amount + other.K_slow * (1-crossover_amount);
            new_agent.t_switch = agent.t_switch * crossover_amount + other.t_switch * (1-crossover_amount);
        end
        
        function K_slow = crossover_k_slow(agent, other)
            crossover_amount = rand;
            K_slow = agent.K_slow * crossover_amount + other.K_slow * (1-crossover_amount);
        end
        
        function K_fast = crossover_k_fast(agent, other)
            crossover_amount = rand;
            K_fast = agent.K_fast * crossover_amount + other.fast * (1-crossover_amount);
        end
        
        function K_slow = crossover_t_switch(agent, other)
            crossover_amount = rand;
            K_slow = agent.K_slow * crossover_amount + other.K_slow * (1-crossover_amount);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end

