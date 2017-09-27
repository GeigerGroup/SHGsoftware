classdef Acquisition < handle
    properties
        Name
        Timer
        
        PointNumber = 1;
        ScanLength = Inf;
        
        PhotonCounter
        PHmeter
        DAQsession
        Pump
        
        FlowIndex = 1;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        FlowControl = false;

        Time
        DataPhotonCounter
        DataNIDAQpower
        DatapH
        DataCond
    end
    
    methods
        function obj = Acquisition(name)
            if nargin > 0
                if ischar(name)
                    %add name
                    obj.Name = name;
                    
                    %create timer to time acquisition
                    obj.Timer = createDataTimer(obj);
                    
                    %give reference to photon counter
                    obj.PhotonCounter = getappdata(0,'photonCounter');
                    
                    %give reference to DAQsession
                    obj.DAQsession = getappdata(0,'daqSession');
                    
                    %give reference to pump
                    obj.Pump = getappdata(0,'pump');
                    
                    %give reference to pHmeter
                    %obj.PHmeter = getappdata(0,'pHmeter');
                   

                else
                    error('Input name must be char')
                end
            else
                error('Acquisition needs a name')
            end
        end
        
        function  getData(obj)
            %get data from the instruments selected
            
            %time based on photon counter
            if (~isempty(obj.PhotonCounter))
                obj.Time = vertcat(obj.Time,obj.PointNumber*obj.PhotonCounter.Interval);
            end  
            
            %photon counter data
            if (~isempty(obj.PhotonCounter))
               obj.DataPhotonCounter = vertcat(obj.DataPhotonCounter,obj.PhotonCounter.getData('A'));
            end
            
            %NIDAQ power data
            if (~isempty(obj.DAQsession))
               obj.DataNIDAQpower = vertcat(obj.DataNIDAQpower,obj.DAQsession.Session.inputSingleScan);
            end
            
            %pH meter data
            if (~isempty(obj.PHmeter))
                [pH, cond] = obj.PHmeter.getData;
                obj.DatapH = vertcat(obj.DatapH,pH);
                obj.DataCond = vertcat(obj.DataCond,cond);
            end
            
            figure(1)
            plot(obj.Time,obj.DataPhotonCounter)
            figure(2)
            plot(obj.Time,obj.DataNIDAQpower)
        end
        
        function checkAcquisition(obj)
            %check to see if have exceeded point number, and if flow
            %control if change should occurr
            
            if obj.FlowControl %check if flow control is enabled
                if obj.PointNumber == obj.FlowConcentrationPoint(obj.FlowIndex) 
                    %check if point number is point number where change happens
                    
                    %calculate flow rates for two reservoir salt
                    obj.Pump.calculateSalt2Reservoir(obj.FlowConcentrationValue(obj.FlowIndex));
                    obj.FlowIndex = obj.FlowIndex + 1; %increment flow index
                end
            end
                    
            
            %increment point number in acquisition
            obj.PointNumber = obj.PointNumber + 1;
            
            %check if have exceeded scan length and then stop
            if obj.PointNumber > obj.ScanLength
                obj.stopAcquisition
            end
        end
        
        function startAcquisition(obj)
            
            %start timer
            start(obj.Timer);
            
            %start photon counter
            if (~isempty(obj.PhotonCounter))
                obj.PhotonCounter.resetScan
                obj.PhotonCounter.startScan
            end
        end
        
        function pauseAcquisition(obj)
            
            %stop timer
            stop(obj.Timer);
            
            %stop photon counter
            if (~isempty(obj.PhotonCounter))
                obj.PhotonCounter.stopScan
                disp('Photon counter paused')
            end
            
        end
        
        function resumeAcquisition(obj)
            
            %start timer
            start(obj.Timer);
                        
            %start photon counter
            if (~isempty(obj.PhotonCounter))
                obj.PhotonCounter.startScan
            end
        end
            
            
        
        function stopAcquisition(obj)
            stop(obj.Timer);
            delete(obj.Timer);
            
            %reset photon counter
            if (~isempty(obj.PhotonCounter))
                obj.PhotonCounter.stopScan
            end
        end

    end
end
    