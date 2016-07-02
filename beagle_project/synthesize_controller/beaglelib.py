# -*- coding: utf-8 -*-
import numpy as np
import os
from math import ceil
from scipy.signal import cont2discrete
import json

class Acutator(object):

    def __init__(self, linear):
        
        self.linear = linear
        self.controller = None
    
    def initiate_model(self):
        raise Exception('The _initiate_model() function needs to be overwritten in '+
                        'actator subclasses')

    def initiate_controller(self, controlmodule):
        try:
            exec('from controllers.%s import Controller' % controlmodule)
            self.controller = Controller()
        except:
            raise Exception(('Could not load the controller in '+
                             'initiate_controller in %s. Please check that the '+
                             'specified controller file "%s" exists in the '+
                             '/controllers directory, and that it is '+
                             'syntactically correct.') % (str(self), controlmodule))

    def _reference_generator(self):
        raise Exception('The _reference_generator() function needs to be overwritten in '+
                        'actator subclasses')

    def _step_model(self):
        raise Exception('The _step_model() function needs to be overwritten in '+
                        'actator subclasses')

    def _step_controller(self, ref):
        raise Exception('The _step_controller() function needs to be '+
                        'overwritten in actator subclasses')

    def __str__(self):
        return 'Acutator object'

    def simulate(self, tf, simtype):
        
        # Computes reference signal
        N = int(ceil(float(tf)/self.h))
        ref = self._reference_generator(tf, simtype)

        # Sets up emty data arrays
        u = np.zeros((self.nControl, N))
        x = np.zeros((self.nStates, N))
        y = np.zeros((self.nMeasurements, N))
        
        # Simulates the system
        for ii in range(0, N-1):

            # Computes the control signal using the generated controller
            if not self.controller:
                u[:, ii] = self._step_controller(ref[:, ii]) # Simple response test
            else:
                u[:, ii] = self.controller(ref[0, ii], x[0, ii])

            # Computes the system reponse to the control signal 
            x[:, ii + 1], y[:, ii] = self._step_model(x[:, ii], u[0:1, ii])

        return ref, u, x, y

class DC_Motor(Acutator):

    def __init__(self, configfile=None, controlmodule=None):
        """        
        Initializes the Acutator constructor, sets the configuration and
        controller files and initializes the model with the specified
        configuration.
        
        ARGS:
            configfile (str) - The filename of the configuration file which is
                to be used, set to None by default (then uses the default
                settings)
            controller (str) - The filename of the controller file which is
                to be used, set to None by default. The system cannot be
                simulated unless a controller or a control signal sequence is
                specified.
        RETURNS:
            None
        """
        Acutator.__init__(self, linear=True)
        self.configfile = configfile
        self.controlmodule = controlmodule
        self.initiate_model(configfile)
        self.initiate_controller(controlmodule)

    def _reference_generator(self, tf, simtype):
        N = int(ceil(float(tf)/self.h))
        u = np.zeros((3, N))

        if simtype == 'steps':
            # Alternating steps in theta (±π) with thetadot and i set to 0, the
            # period time is set to 5 seconds
            T = 10. # [s]
            for ii in range(N):
                if ceil(ii*(tf/T)/float(N)) % 2:
                    u[0, ii] = 1.
                else:
                    u[0, ii] = -1.
        return u
            
    def initiate_model(self, configfile):
        # Load parameters from configuration file
        J = 0.01
        b = 0.1
        K = 0.01
        K = 0.01
        R = 1.
        L = 0.5
        
        # Time step
        self.h = 0.1
        self.nStates = 3
        self.nMeasurements = 1
        self.nControl = 1

        # Continuous time DC model
        A = np.array([[0., 1., 0.],[0., -b/J, K/J],[0., -K/L, -R/L]])
        B = np.array([[0.],[0.],[1./L]])
        C = np.array([[0.,1.,0.]])
        D = np.array([[0.]])
        
        # Discretize system using zero order hold
        dsys = cont2discrete((A, B, C, D), self.h, method='zoh', alpha=None)
        
        self.Ad = dsys[0]
        self.Bd = dsys[1]
        self.Cd = dsys[2]
        self.Dd = dsys[3]

    def _step_model(self, x, u):
        xp1 = np.dot(self.Ad, x) +  np.dot(self.Bd, u)
        y = np.dot(self.Cd, x)
        return xp1, y

    def _step_controller(self, ref):
        u = ref[0]
        return u

    def __str__(self):
        return 'DC motor object'

def new_configuration(filename, param):
    models = ['DC_Motor']
    if not param['name'] in models:
        raise Exception(('Error in new_configuration. Could not open %s, '+
                        'valid options are %s') % (param['name'], str(models)))
    # TODO - Add model specific checks of input data
    # TODO - Check if the filename exists in the config directrory and warn
    # TODO - Check if the filename ends with .cnf or warn
    with open(os.path.join('config', filename), 'w') as configfile:
        json.dump(param, configfile, separators=(',', ':'),
                  sort_keys=True, indent=4)
    configfile.close()
                      
def new_controller(configfile, controlfile, ctype, param): 
    # TODO - Add more controllers and support generation/simulation of C code

    # Loads configuration file
    try:
        with open(os.path.join('config', configfile), 'r') as cnf:
            configfile = json.load(cnf)
        cnf.close()
    except:
        raise Exception(('Error in new_controller. Could not open the '+
                        'configuration file %s') % configfile)

    # Check if the specified controller is supported
    controllers = {
        'P':['Kp'],
        'PI':['Kp', 'Ki'],
        'PIAW':['Kp', 'Ki', 'sat_lim_max', 'sat_lim_min'],
        'PD':['Kp', 'Kd'],
        'PID':['Kp', 'Ki', 'Kd'],
        'PIDAW':['Kp', 'Ki', 'Kd', 'sat_lim_max', 'sat_lim_min'],
    }
    if not ctype in controllers.keys():
        raise Exception(('Error in new_controller. Could not open %s, '+
                        'valid options are %s') % (ctype, str(controllers.keys())))
    
    # Check that all the necessary parameters are set in param
    inputparam = param.keys()
    for parameter in controllers[ctype]:
        if not parameter in inputparam:
            raise Exception(('The parameter %s in param has to be set for %s '+
                             'control') % (parameter, ctype))
    # Synthesizes controller
    if (ctype == 'P' or ctype == 'PI' or
        ctype == 'PIAW' or ctype == 'PD' or
        ctype == 'PID' or ctype == 'PIDAW'):
        constructor = (('class Controller(object):\n'+4*' '+
                      'def __init__(self):\n'+8*' '+'self.Kp = %f\n'+8*' '+
                      'self.h = %f\n') % (param['Kp'], configfile['h']))
        precsig     = ('\n'+4*' '+'def __call__(self, r, x):\n'+8*' '+
                      'e = r - x\n')
        csig        = 8*' '+'u = self.Kp * e'
        postcsig    = ''
        tostring    = ('\n'+8*' '+'return u\n\n'+4*' '+'def __str__(self):\n'+
                      8*' '+'return "%s controller object"') % ctype
        if 'I' in ctype:
            constructor += (8*' '+'self.Ki = %f\n'+8*' '+'self.I = 0\n') % param['Ki']
            csig +=   (' + self.I')
            compI = 'self.I = self.I + self.Ki * e * self.h'
            if 'AW' in ctype:
                postcsig += ('\n'+8*' '+'if u >= %f:\n'%(param['sat_lim_max'])+
                            12*' '+'u = %f\n'%(param['sat_lim_max'])+8*' '+
                            'elif u <= %f:\n'%(param['sat_lim_min'])+12*' '+
                            'u = %f\n'%(param['sat_lim_min'])+8*' '+
                            'else:\n'+12*' '+compI)
            else:
                postcsig += ('\n'+8*' '+compI)
        if 'D' in ctype:
            constructor += (8*' '+'self.Kd = %f\n'+8*' '+'self.em1 = 0\n') % param['Kd']
            csig +=  (' + self.Kd * (e - self.em1) / self.h')
            postcsig += ('\n'+8*' '+'self.em1 = e')
        with open(os.path.join('controllers', controlfile), 'w') as ctr:
            ctr.write((constructor + precsig + csig + postcsig + tostring))
        #    ctr.write(('class Controller(object):\n    def __init__(self):\n'+
        #        '        self.Kp = %f\n        self.Ki = %f\n'+
        #        '        self.Kd = %f\n        self.h = %f\n'+
        #        '        self.I = 0\n        self.em1 = 0\n\n'+
        #        '    def __call__(self, r, x):\n        e = r - x\n'+
        #        '        self.I = self.I + self.Ki * e * self.h\n'+
        #        '        u = self.Kp * e + self.I + self.Kd * (e - self.em1) / self.h\n'+
        #        '        self.em1 = e\n        return u\n\n    def __str__(self):\n'+
        #        '        return "PID"') % (param['Kp'], param['Ki'], param['Kd'], configfile['h']))
        ctr.close()