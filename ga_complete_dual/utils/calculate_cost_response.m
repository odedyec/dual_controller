function J = calculate_cost_response(y, u, r, agent, param)
J = 0;
% res = extract_response_params(r, y, u, param);
t = param.dt:param.dt:param.T;
S = stepinfo(y(1,:),t,r(1, end));
% Add overshoot
J = S.Overshoot * param.overshoot_cost;
% Add rise time
if isnan(S.RiseTime)
    J = J + 100;
else
    J = J + S.RiseTime * param.rise_time_cost / param.T * 100;
end
% Add settling time
if isnan(S.SettlingTime)
    J = J + 100; %% Out of scope process
else
    J = J + S.SettlingTime * param.settling_time_cost / param.T * 100;
end
% Add energy cost
J = J + sum(abs(u)) / param.u_max  / param.T * param.dt* param.energy_cost * 100;
% Make sure K_f > K_s
if sum(abs(agent.K_fast)) < sum(abs(agent.K_slow))
    J = J + 100;
end
if agent.K_fast(1) < 5 * agent.K_fast(2)
    J = J + 40;
end
J = J + (sum(abs(agent.K_fast)) + sum(abs(agent.K_slow))) * param.gain_cost;
    
    % Stay in the quarter time area
%     J = J + abs(agent.t_switch - param.T / 4) * param.gain_t_switch;
