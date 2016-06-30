close all;
clear;

%% double integrator (discrete statespace type model)
fset.h = 0.1;                   % Discretization time step

% process dynamics
Ad = [1, fset.h; 0, 1];
Bd = [fset.h^2/2; fset.h];
Cd = [1,0];                % Measure only the position
Dd = [0];
x0 = [0, 0];

% Filter ettings
fset.Ad = Ad;
fset.Bd = Bd;
fset.Cd = Cd;
fset.Dd = Dd;
fset.nDiscreteStates = size(Ad, 1);
fset.nControlsignals = size(Bd, 2);
fset.nMeasuredStates = size(Cd, 1);
fset.x0 = x0;
fset.P0 = 10*eye(2);

% Filter design parameters
std_R = 0.5;
fset.R = 100;
fset.Q = eye(2);

% Design parameter error check
error_check(fset)