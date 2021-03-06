# control_theory
This repository contains a collection of projects and example implementations from
the wide field of control theory. Everything is done with the intention of being
reusable in future projects and each subdirectory has one or many ilustrative
reports located in the /report directories, or a simple README.md file if the
extent of the project doesn't warrant a full report.

## Contents
#### /dual_motor_control
This project is Simulink/Matlab based and investigates elimination of mechanical
backlash in a dual motor control(DMC), one dimensional cart system. The project
includes three aspects which might be useful in other contexts.
* A detailed description of a novel filter for splitting the control signals to
  the two motors.
* A method of computing optimal 1-D trajectories for the one dimensional cart,
  which could easily be extended to higher dimensional trajectories.
* A description and simulink implementation of a cascade P-PI-PI scheme with
  feedforward and very general implementations of a conditional anti-windup
  scheme.

#### /beagle_project
This project is concerned with the modeling and simulation of robotic acutators
(Simulink/Matlab) with various methods of control. The acutators currently
include a simple DC motor/servo, but stepper motors and hydraulics will be
considered as soon as possible. All controllers will be implemented in
discrete/continuous time in Simulink, where they can be analyzed in depth.
However, independently of Matlab/simulink, there will exist options of (i)
generating hard coded controllers in C and Python, (ii) methods of simulating
the generated controllers in Python, (iii) methods of automatic system 
identification and finally (iv) physical examples of acutator control in Python
(using ROS Indigo in conjunction with a Beaglebone Black) and in C (using an
AVR Omega) with the generated controllers.

#### /estimation_project
Yet to be written.

#### /kinect_vision
Yet to be written.
