# beagle_project
This project is still in the early stages, but work will progress over the summer.

## Depencencies
Running the simulink part simply requires an installation of Matlab with
Simulink (no additinoal toolboxes are required). To run the beagle_project
codes you will need a machine with Ubuntu Trusty 14.04, complete with a
ROS Indigo installation. In addition, you will need a Beaglebone Black
Rev C flashed with the latest Debian image and preferably some of the
supported hardware.

## Installation
Yet to be written.

## Contents
#### /simulink_models
This directory can be operated at a high level from the run_project script, in
which three settings can be changed. The first specifies the hardware model 
* DC motor (*supported*)
* Servo motor (*not yet supported*)
* Hydraulic (*not yet supported*)
* Pneumatic acutators (*not yet supported*)

The second specified the controller which is to be used, depending on the slected
hardware model, available controllers are
* PID (*supported*)
* PID with conditional anti windup (*supported*)
* STUPID (*not yet supported*)
* Cascade control (*supported*)
* LQR (*not yet supported*)
* H-infinity (*not yet supported*)
* MPC (*not yet supported*)
* L1 (*not yet supported*)

The final setting specifies if the simulation should be made in discrete or
continuous time. All parameters of the models and controllers are located in the
/init_files/* directory and can be changed if necessary.

#### /beagle_bone
The code has yet to be written, but will include a discrete time Python
implementation of the above controllers.

#### /AVR_omega
The code has yet to be written, but will include a discrete time C implementation
of the above controllers.
