function [my_sys] = get_sys(param)
%% Set general props
my_sys = struct();
my_sys.dt = param.dt;
my_sys.Tfinal = param.T;
my_sys.n = my_sys.Tfinal / my_sys.dt;
%% Set initial props
my_sys.x0 = param.x0;
my_sys.ref_signal = repmat(param.ref_signal, 1, my_sys.n);
%% Sys Props
my_sys.U_MAX = param.u_max;
my_sys.A = param.A;
my_sys.B = param.B;
end

