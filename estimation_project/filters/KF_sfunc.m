function [sys,x0,str,ts] = KF_sfunc(t,x,u,flag,fset)

switch flag,
    case 0 % Initialization
        [sys,x0,str,ts] = mdlInitializeSizes(fset);
	case 2 % Update of discrete states
        sys = mdlUpdates(t,x,u,fset);
	case 3 % Calculation of outputs
        sys = mdlOutputs(t,x,u,fset);
    case {1, 4, 9}
        % 1 - Calculation of derivatives (not needed).
        % 4 - Calculation of next sample hit (variable sample time block only).
        % 9 - End of simulation tasks (not needed).
        sys = [];
    otherwise
        % No other flags are defined in simulink, throws error
        error(['Unhandled flag = ',num2str(flag)]);
end

function [sys,x0,str,ts] = mdlInitializeSizes(fset)

% Initialize simsizes
sizes = simsizes;

% No continuous states
sizes.NumContStates  = 0;

% All discrite states
sizes.NumDiscStates  = fset.nDiscreteStates;

% Number of outputs (3)
sizes.NumOutputs     = fset.nDiscreteStates;

% Number of inputs (1)
sizes.NumInputs      = fset.nControlsignals + fset.nMeasuredStates;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes); 

x0 = fset.x0;

str = [];                % Set str to an empty matrix.
ts  = [fset.h 0];       % sample time: [period, offset]
		      
%==============================================================
% Update the discrete states
%==============================================================
function sys = mdlUpdates(t,x,u,fset)
Ad = fset.Ad;
Bd = fset.Bd;
Cd = fset.Cd;
Q = fset.Q;
R = fset.R;

persistent P
if isempty(P) || t == 0
    P = fset.P0;
end

Nc = fset.nControlsignals;
Nx = fset.nDiscreteStates;

uk = u(1:Nc);
zk = u(Nc+1:end);

% Predictor step
xf = Ad * x + Bd * uk;
Pf = Ad * P * Ad' + Q;

% Corrector step
K =  Pf * Cd' / (Cd * Pf * Cd'+ R);
xhat = xf + K * (zk - Cd * xf);
P = (eye(Nx) - K * Cd) * Pf;

% Updates the states
sys = xhat;

function sys = mdlOutputs(t,x,u,fset)
% Returns the current estimation
sys = x;
