# DAQsoftware

**** Disclaimer: I am not a profesional programmer. I am sure some of my common programming practices range from sloppy at best to incompetent at worst. ****

written primarily by paul ohno (on top of code provided by the hardware/software providers and various other individuals when noted)

Intended to allow for real-time scientific data acquisition using a variety of software and hardware componenents. The overall goal is flexibility and interchangeability with different components so redundancy and compatibility are main objectives. 

Current software packages under development are for IGOR Pro (6.11) and MATLAB (R2016_b), with the eventual goal of a fully open-source version in Python. 

Hardware control capabilities under developemnt include:

1. NI DAQ USB-6001 for interfacing with solenoid driver board and ADC to measure analog output power from photodiode or power meter
2. Ismatec REGLO ICC PUMP for independent four channel flow control
3. EPM Power Meter (model number?) for measurement of pulsed laser power and energy
4. Orion Star A320 for measurement of pH, conductivity, etc. with appropriate probes

future possibilities include:

1. pH monitoring with DAQ ADC using a pH probe and approriate op amp (proprietary meter replacement)
2. conductivity monitoring with DAQ ADC (proprietary meter replacement)
3. openDAQ as an alternaive to NI DAQ





