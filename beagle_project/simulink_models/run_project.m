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
%     'DC_motor'   - Simulates the DC motor model.
% c:
%     'feedback'   - Linear feedback law with pp -1+-i (c) or 0 (d)
%     'PID'        - Regular PID controller
%     'PIDAW'      - PID controller with conditional anti-windup (AW)
%     'PIDcascade' - Cascade control loop for position control with AW
%     'LQRi'       - LQR with inegrator states for elimination of ss error
%     'LQRp'       - Precompensated LQR for good trajectory following
%     'MRAC'       - Adaptive control with reference model poles in -1+-i
%     'SMC'        - Sliding mode control with respect to angular position
% t:
%     'continuous'  - Simulates model and controller in continuous time
%     'discrete'    - Simulates model and discrete in continuous time
%
% Functional combinations are
% 
%                    DC_motor   Furuta   BeamBall  Cubes
%     'feedback'       0/0       0/0       0/0      0/0
%     'PID'            1/1       0/0       0/0      0/0
%     'PIDAW'          1/1       0/0       0/0      0/0
%     'PIDcascade'     0/1       0/0       0/0      0/0
%     'LQRi'           1/0       0/0       0/0      0/0
%     'LQRp'           1/0       0/0       0/0      0/0
%     'MRAC'           1/1       0/0       0/0      0/0
%     'SMC'            1/0       0/0       0/0      0/0

close all;
clear;

opt.h = 'DC_motor';
opt.c = 'MRAC';
opt.t = 'continuous';

%% Check that the input data is valid
models = {'DC_motor', 'Furuta', 'BeamBall', 'Cubes'};
controllers = {'response', 'PID', 'PIDAW', 'PIDcascade', 'LQRp', 'LQRi', 'MRAC', 'SMC'};
times = {'continuous', 'discrete'};

matches = strfind(models,opt.h);
if ~any(vertcat(matches{:})) 
    disp(['The hardware model "', opt.h,'" does not exist in the library.'])
    disp('Valid choices are: DC_motor.')
    return
end

matches = strfind(controllers,opt.c);
if ~any(vertcat(matches{:})) 
    disp(['The controller ', opt.c, ' does not exist in the library.'])
    disp('Valid choices are: response, PID, PIDAW and cascade.')
    return
end

matches = strfind(times,opt.t);
if ~any(vertcat(matches{:})) 
    disp(['The specified time ', opt.t, ' does not exist in the library.'])
    disp('Valid choices are: continuous and discrete.')
    return
end

%% Add all simulink folders to path
addpath(genpath('.'));

%% Run init files
fprintf('Initializing... ')
try
    run(['init_', opt.h, '.m'])
    if ~strcmp('response', opt.c)
        run(['init_', opt.h, '_', opt.c, '_', opt.t(1), '.m'])
    end
    fprintf('Done!')
catch
     fprintf(['Failed!\nThe initialization file "init_', opt.h, '_',...
              opt.c, '_', opt.t(1), '.m" could not be found.\n'])
end

%% Open and simulate model
if strcmp('response', opt.c)
    fprintf(['\nSimulating a ', opt.h, ' ', opt.c, ' in ',...
             opt.t, ' time... '])
else
    fprintf(['\nSimulating a ', opt.h, ' with ', opt.c, ' in ',...
             opt.t, ' time... '])
end

try
    open([opt.h, '_', opt.c, '_', opt.t(1)]);
    sim([opt.h, '_', opt.c, '_', opt.t(1)]);
    fprintf('Done!\n')
catch
    fprintf(['Failed!\nThe controller may not be supported in ',...
             opt.t, ' time just yet.\n'])
end