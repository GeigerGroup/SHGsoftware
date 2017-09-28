classdef Acquisition < handle
    properties
        Name
        Timer
        
        PointNumber = 1;
        ScanLength = Inf;
        
        PhotonCounter
        PHmeter
        DAQsession
        
        FlowIndex = 1;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        FlowControl = false;

        Time
        DataPhotonCounter
        DataNIDAQpower
        DatapH
        DataCond
        
        PlotPhotonCounter
        PlotPower
        PlotpH
        PlotCond
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
                    obj.PHmeter = getappdata(0,'pHmeter');
                    
                    %create each plot handle
                    figure
                    obj.PlotPhotonCounter = plot(obj.Time,obj.DataPhotonCounter);
                    obj.PlotPower = plot(obj.Time,obj.DataNIDAQpower);
                    obj.PlotpH = plot(obj.Time,obj.DatapH);
                    obj.PlotCond = plot(obj.Time,obj.DataCond);
                    
                    
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
            
            %photon counter data
            if (~isempty(obj.PhotonCounter))
                data = obj.PhotonCounter.getData('A');
                if ~isempty(data) %if it got something continue
                    obj.DataPhotonCounter = vertcat(obj.DataPhotonCounter,data);
                else
                    return %else exit
                end
                obj.Time = vertcat(obj.Time,obj.PointNumber*obj.PhotonCounter.Interval);
            end
         
            
            %NIDAQ power data
            if (~isempty(obj.DAQsession))
                obj.DataNIDAQpower = vertcat(obj.DataNIDAQpower,obj.DAQsession.Session.inputSingleScan);
            end
            
            %pH meter data
            if (~isempty(obj.PHmeter))
                [pH, cond] = obj.PHmeter.getData;
                
                if ~isempty(pH) %if got the data add it
                    obj.DatapH = vertcat(obj.DatapH,pH);
                    obj.DataCond = vertcat(obj.DataCond,cond);
                else
                    obj.DatapH = vertcat(obj.DatapH,0); %else add 0s
                    obj.DataCond = vertcat(obj.DataCond,0);
                end
            end
            
            
            set(obj.PlotPhotonCounter,'XData',obj.Time,'YData',obj.DataPhotonCounter)
            set(obj.PlotPower,'XData',obj.Time,'YData',obj.DataNIDAQpower)
            set(obj.PlotpH,'XData',obj.Time,'YData',obj.DatapH)
            set(obj.PlotCond,'XData',obj.Time,'YData',obj.DataCond)
            drawnow;
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
