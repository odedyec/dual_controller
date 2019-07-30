classdef Agent
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fitness
        K
        low
        high
    end
    
    methods
        function obj = Agent(inp_size, out_size)
            %AGENT Construct an instance of this class
            %   Detailed explanation goes here
            obj.low = -100;
            obj.high = 100;
            obj.K = randn(inp_size, out_size) * obj.high;
            obj.fitness = inf;
        end
        
        function obj = set_fitness(obj, val)
            obj.fitness = val;
        end
        
        function obj = mutate(obj, i)
            val = 1.5 * rand + 0.5;  % Uniform random between [0.5, 2]
            obj.K(i) = val * obj.K(i);
        end
        
        function outputArg = is_bigger(obj,other)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = (obj.fitness > other.fitness);
        end
    end
end

