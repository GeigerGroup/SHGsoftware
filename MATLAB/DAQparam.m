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
        DwellTime = 0.002;
        Channel = 'A';
        
        %booleans of if enabled for an acquisition
        PhotonCounterEnabled = true;
        ADCpowerEnabled = false;
        FlowControl = false;
        PHmeterEnabled = false;

        %parameters for flow control
        FlowConcentrationPoint;
        FlowConcentrationValue;
        
        %target concentration
        TargetConc = 0;
        
        %solenoid valves
        SolStates = false(1,5);
        
        %pump flow rates
        PumpStates = [0 0 0 0];
        
        %automatic pause for acquisitions
        AutoPause = 0;
    end
end