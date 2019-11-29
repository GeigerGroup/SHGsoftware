%the key class of the entire software, that gets stored as 'daqParam' on
%the base appdata of matlab and holds both references to physical objects
%like the photon counter, pump, stage, etc. as well as parameters for the
%scans

classdef DAQparam < handle
    properties
        %references of physical objects
        PhotonCounter
        FlowSystem = FlowSystem()
        PowerADC
        PHmeter
        Stage
             
        %parameters for photon counter
        ScanLength = Inf;
        Interval = 1;
        DwellTime = 0.002;
        Channel = 'AB';
        
        %booleans of if enabled for an acquisition
        PhotonCounterEnabled = true;
        PowerADCEnabled = false;
        FlowControl = false;
        PHmeterEnabled = false;
        
        %parameters for scan
        PosPerScan = 10
        PointsPerPos = 10
        ContMode = false
        ScanSpeed = 2000;
        ScanPositions

        %parameters for flow control
        FlowConcentrationPoint;
        FlowConcentrationValue;
        
        %name
        Name
        
        %automatic pause for acquisitions
        AutoPause = 0;
    end
end