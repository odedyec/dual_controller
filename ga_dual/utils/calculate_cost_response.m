function J = calculate_cost_response(y, u, r, param)
J = 0;
% res = extract_response_params(r, y, u, param);
t = param.dt:param.dt:param.T;
S = stepinfo(y(1,:),t,r(1, end));
% Add overshoot
J = S.Overshoot * param.overshoot_cost;
% Add rise time
if isnan(S.RiseTime)
    J = J + 100 * param.rise_time_cost;
else
    J = J + S.RiseTime * param.rise_time_cost / param.T * 100;
end
% Add settling time
if isnan(S.SettlingTime)
    J = J + 100 * param.settling_time_cost; %% Out of scope process
else
    J = J + S.SettlingTime * param.settling_time_cost / param.T * 100;
end
% Add energy cost
J = J + sum(abs(u)) / param.u_max * param.energy_cost / param.T * param.dt;