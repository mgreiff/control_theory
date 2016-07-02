# -*- coding: utf-8 -*-
from beaglelib import DC_Motor, new_configuration, new_controller
from matplotlib.pylab import plt
import numpy as np

if __name__ == '__main__':
    ###########################################################################
    # This example demonstrate how a motor can be parametrized manually,
    # creating a new configuration file using the new_configuration() function
    # in the beaglelib module, stored in /config. Using the created 
    # configuration file, a PID controller is synthesized in both C and Python,
    # after which the Python and C controllers are simulated independently.
    # The controllers are stored in /controllers and can be directly imported
    # into the beaglebone and AVR example applications, or some other
    # application.
    ###########################################################################

    # Create new configuration (stored in /config)
    param = {
        'name':'DC_Motor',
        'h': 0.1,
        'J': 0.01,
        'b': 0.1 ,
        'K': 0.01,
        'R': 1.,
        'L': 0.5
    }

    new_configuration('example_configuration.cnf', param)

    # Create new controller (stored in /controllers)
    param = {
        'Kp': 15.,
        'Ki': 0.01,
        'Kd': 3,
        'sat_lim_max': 10,
        'sat_lim_min': -10
    }

    new_controller('example_configuration.cnf', 'example_controller.py', 'PIDAW', param)

    # Create a motor object for simulation
    motor = DC_Motor(configfile='model.cnf', controlmodule='example_controller')

    # Simulate the system with an alternating step reference 
    ref, u, x, y = motor.simulate(30, 'steps')

    # Visualize simulation
    t = np.array([ii * motor.h for ii in range(len(u[0,:]))])
    plt.figure(1);
    plt.step(t, u[0])
    limits = np.array(plt.axis())*np.array([1.,1.,1.1,1.1])
    plt.axis(limits)
    plt.title('Control signal(s)')

    plt.figure(2);
    plt.step(t, np.transpose(x))
    limits = np.array(plt.axis())*np.array([1.,1.,1.1,1.1])
    plt.axis(limits)
    plt.title('System states')

    plt.figure(3);
    plt.step(t, ref[0])
    plt.step(t, x[0])
    limits = np.array(plt.axis())*np.array([1.,1.,1.1,1.1])
    plt.axis(limits)
    plt.title('Theta and reference')
    plt.show()