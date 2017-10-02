classdef DAQparam < handle
    properties
        Name = 'wave1';

        %boolenas of if hardware is enabled
        PhotonCounter = false;
        NIDAQ = false;
        Pump = false;
        PHmeter = false;
        
        
        %parameters for photon counter
        ScanLength = Inf;
        Interval = 1;
        DwellTime = 0.02;
                
        
        
        %parameters for flow control
        FlowControl = false;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        
      
    end
end