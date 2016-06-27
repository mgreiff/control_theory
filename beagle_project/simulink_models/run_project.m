close all;

%% Top level settings
% Here a model which is to be simulated is set (h) with a controller (c)
% which is then simulated in a specified time (t). To change model or 
% controller parameters, change the corresponding init file or the
% appropriate parameter in the workspace. No parameters are set in the
% simulink models themselves. The default setting simulates a DC motor with
% a conditional anti-windup scheme in continuous time.
h = 'DC_motor';
c = 'PIDAW';
t = 'continuous';

%% Check that the input data is valid
if ~strcmp('DC_motor', h) &&...
   ~strcmp('stepper_motor', h)
    disp(['The hardware ', h, ' does not exist in the library.'])
    disp('Valid choices are: DC_motor and stepper_motor.')
    return
end

if ~strcmp('response', c) &&...
   ~strcmp('PID', c) &&...
   ~strcmp('PIDAW', c) &&...
   ~strcmp('cascade', c) &&...
    disp(['The controller ', c, ' does not exist in the library.'])
    disp('Valid choices are: response, PID, PIDAW and cascade.')
    return
end

if ~strcmp('continuous', t) &&...
   ~strcmp('discrete', t)
    disp(['The spcified time ', t, ' does not exist in the library.'])
    disp('Valid choices are: continuous and discrete.')
    return
end

%% Add all simulink folders to path
addpath(genpath('.'));

%% Run init files
fprintf('Initializing... ')
run(['init_', h, '.m'])
if ~strcmp('response', c)
    run(['init_', h, '_', c, '.m'])
end
fprintf('Done!')

%% Open and simulate model
if strcmp('response', c)
    fprintf(['\nSimulating a ', h, ' ', c, ' in ', t, ' time... '])
else
    fprintf(['\nSimulating a ', h, ' with ', c, ' controller in ', t, ' time... '])
end
open([h, '_', c]);
sim([h, '_', c]);
fprintf('Done!\n')