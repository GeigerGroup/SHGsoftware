classdef DAQparam < handle
    properties
        %boolenas of if hardware is enabled
        PhotonCounter = false;
        NIDAQ = false;
        Pump = false;
        PHmeter = false;
             
        %parameters for photon counter
        ScanLength = Inf;
        Interval = 1;
        DwellTime = 0.02;
        
        PHmeterEnabled = false;
        NIDAQpowerEnabled = false;
                               
        %parameters for flow control
        FlowControl = false;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        
        %solenoid valves
        SolStates = false(1,5);
        
        %pump flow rates
        PumpStates = [0 0 0 0];
             
    end
end