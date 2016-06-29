%% DC motor parameters (simulink type model)
J = 0.01;
b = 0.1;
K = 0.01;
R = 1;
L = 0.5;

ddt0 = 0;
dt0 = 0;
t0 = 0;
i0 = 0;

%% DC motor parameters (statespace type model)
A = [0, 1, 0; 0, -b/J, K/J; 0, -K/L, -R/L];
B = [0; 0; 1/L];
C = eye(3);

x0 = [t0; dt0; i0];