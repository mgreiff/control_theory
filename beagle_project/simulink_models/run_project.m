%% Top level settings
% Here, the model which is to be simulated is set (h) with a controller (c)
% which is then simulated in a specified time (t). To change model or 
% controller parameters, alter the corresponding init file or the
% appropriate parameter in the workspace. No parameters are hard coded in
% the simulink models themselves. The default setting simulates a DC motor
% with a conditional anti-windup scheme in continuous time.
%
% Valid options are:
%
% h:
%      'DC_motor'   - Simulates the DC motor model.
% c:
%      'PID'        - Regular PID controller
%      'PIDAW'      - PID controller with conditional anti-windup (AW)
%      'PIDcascade  - Cascade control loop for position control with AW
%      'LQRi'       - LQR with inegrator states for elimination of ss error
%      'LQRp'       - Precompensated LQR for good trajectory following
% t:
%     'continuous'  - Simulates model and controller in continuous time
%     'discrete'    - Simulates model and discrete in continuous time

close all;
clear;

opt.h = 'DC_motor';
opt.c = 'LQRp';
opt.t = 'continuous';

%% Check that the input data is valid
if ~strcmp('DC_motor', opt.h)
    disp(['The hardware model "', opt.h, '" does not exist in the library.'])
    disp('Valid choices are: DC_motor and stepper_motor.')
    return
end

if ~strcmp('response', opt.c) &&...
   ~strcmp('PID', opt.c) &&...
   ~strcmp('PIDAW', opt.c) &&...
   ~strcmp('PIDcascade', opt.c) &&...
   ~strcmp('LQRp', opt.c) && ...
   ~strcmp('LQRi', opt.c)
    disp(['The controller ', opt.c, ' does not exist in the library.'])
    disp('Valid choices are: response, PID, PIDAW and cascade.')
    return
end

if ~strcmp('continuous', opt.t) &&...
   ~strcmp('discrete', opt.t)
    disp(['The spcified time ', opt.t, ' does not exist in the library.'])
    disp('Valid choices are: continuous and discrete.')
    return
end

%% Add all simulink folders to path
addpath(genpath('.'));

%% Run init files
fprintf('Initializing... ')
run(['init_', opt.h, '.m'])
if ~strcmp('response', opt.c)
    run(['init_', opt.h, '_', opt.c, '_', opt.t(1), '.m'])
end
fprintf('Done!')

%% Open and simulate model
if strcmp('response', opt.c)
    fprintf(['\nSimulating a ', opt.h, ' ', opt.c, ' in ', opt.t, ' time... '])
else
    fprintf(['\nSimulating a ', opt.h, ' with ', opt.c, ' in ', opt.t, ' time... '])
end
open([opt.h, '_', opt.c, '_', opt.t(1)]);
sim([opt.h, '_', opt.c, '_', opt.t(1)]);
fprintf('Done!\n')