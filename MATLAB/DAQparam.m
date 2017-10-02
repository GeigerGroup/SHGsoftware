classdef DAQparam < handle
    properties
        WaveName = 'wave1';
        ScanLength = Inf;
        
        PhotonCounter = false;
        RecordA = false;
        RecordB = false;
        
        PHmeter = false;
        PH = false;
        Cond = false;
        
        MeasurePower = false;
        NIDAQ = false;
        EPM = false;
        
        AutoPause = false;
        
        FlowControl = false;
        
        Pump = false;
    end
end