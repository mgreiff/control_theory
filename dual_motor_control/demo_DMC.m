% Init file for the demo_DMC example
TH = 1; % Controller threshhold gain, must be larger than 0
FS = 0.2; 
m = 1; % [kg]
b = 0.3; % Coefficient of friction, TBD empirically
set_param('DMC','AlgebraicLoop','None')
sim('DMC.slx')