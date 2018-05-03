classdef DAQparam < handle
    properties
        %booleans of if hardware is enabled
        PhotonCounter = false;
        NIDAQ = false;
        ADC = false;
        Pump = false;
        PHmeter = false;
             
        %parameters for photon counter
        ScanLength = Inf;
        Interval = 1;
        DwellTime = 0.02;
        
        %booleans of if enabled for an acquisition
        PhotonCounterEnabled = true;
        ADCenabled = true;

      
        %parameters for flow control
        FlowControl = false;
        ADCpowerEnabled = false;
        PHmeterEnabled = false;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        
        %solenoid valves
        SolStates = false(1,5);
        
        %pump flow rates
        PumpStates = [0 0 0 0];       
    end
end