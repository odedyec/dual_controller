function response_params = extract_response_params(ref, output, input, param)
%EXTRACT_RESPONSE_PARAMS Summary of this function goes here
%   Detailed explanation goes here
response_params.overshoot = max((output(1, :) - ref(1, :))./ref(1, :));

response_params.rise_time = find(output(1, :) - 0.9 * ref(1, :) > 0, 1);
if isempty(response_params.rise_time)
    response_params.rise_time = size(ref, 2);
end
response_params.rise_time = response_params.rise_time / param.T * param.dt;

res = abs(output(1, :) - ref(1, :));
for i=size(output, 2):-1:1
    if res(i) > param.settling_time_precentage
        response_params.settling_time = i * param.T * param.dt;
        break;
    end
end

