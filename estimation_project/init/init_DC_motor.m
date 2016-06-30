close all;
clear;

%% DC motor parameters
J = 0.01;
b = 0.1;
K = 0.01;
R = 1;
L = 0.5;

theta0 = 0;
dtheta0 = 0;
i0 = 0;

x0 = [theta0; dtheta0; i0];

%% DC motor parameters (continuous statespace type model)
A = [0, 1, 0; 0, -b/J, K/J; 0, -K/L, -R/L];
B = [0; 0; 1/L];
C = [1,0,0;0,0,1];             % Measure current and angular position
D = zeros(size(C,1),size(B,2));
sysc = ss(A,B,C,[]);

%% DC motor parameters (discrete statespace type model)
h = 0.1;
sysd = c2d(sysc, h);

Ad = sysd.A;
Bd = sysd.B;
Cd = sysd.C;
Dd = sysd.D;

%% Filter settings
fset.h = h;
fset.Ad = Ad;
fset.Bd = Bd;
fset.Cd = Cd;
fset.Dd = Dd;
fset.nDiscreteStates = size(A,1);
fset.nControlsignals = size(B,2);
fset.nMeasuredStates = size(C,1);
fset.x0 = x0;
fset.P0 = 10*eye(size(A));

% Filter design parameters
std_R = [0.05,0.01];
fset.R = 100*eye(2);
fset.Q = eye(3);

% Design parameter error check
error_check(fset)