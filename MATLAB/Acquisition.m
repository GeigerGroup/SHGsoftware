classdef Acquisition < handle
    properties
        %name of acquisition and timer
        Name
        Timer
        
        %handles for plotting data
        FigureHandle
        LineHandlePhotons
        LineHandlePower
        LineHandlepH
        LineHandleCond
        
        %data
        DataPhotonCounter
        DataNIDAQpower
        DatapH
        DataCond
        
        %hardware objects
        PhotonCounter
        PHmeter
        DAQsession
        Pump
        
        %parameters for photon counter
        PointNumber
        ScanLength
        Interval
        DwellTime
        
        %parameters for flow control
        FlowControl = false;
        FlowIndex = 1;
        FlowConcentrationPoint;
        FlowConcentrationValue;
        

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
                    obj.DataPhotonCounter = XYData;
                    
                    %give reference to DAQsession
                    obj.DAQsession = getappdata(0,'daqSession');
                    obj.DataNIDAQpower = XYData;
                    
                    %give reference to pump
                    obj.Pump = getappdata(0,'pump');
                    
                    %give reference to pHmeter
                    obj.PHmeter = getappdata(0,'pHmeter');
                    obj.DatapH = XYData;
                    obj.DataCond = XYData;
                    
                    %create new figure to hold 4 subplots handle
                    obj.FigureHandle = figure;
                    
                    %plot for photon data
                    subplot(4,1,1)                
                    %create line object with temp point then delete-
                    %cleanup?
                    obj.LineHandlePhotons = plot(1,1);
                    obj.LineHandlePhotons.XData = [];
                    obj.LineHandlePhotons.YData = [];
                    
                    %plot for power data
                    subplot(4,1,2)                
                    %create line object with temp point then delete-
                    %cleanup?
                    obj.LineHandlePower = plot(1,1);
                    obj.LineHandlePower.XData = [];
                    obj.LineHandlePower.YData = [];
                    
                    
                    %plot for pH data
                    subplot(4,1,3)                
                    %create line object with temp point then delete-
                    %cleanup?
                    obj.LineHandlepH = plot(1,1);
                    obj.LineHandlepH.XData = [];
                    obj.LineHandlepH.YData = [];
                    
                    %plot for cond data
                    subplot(4,1,4)                
                    %create line object with temp point then delete-
                    %cleanup?
                    obj.LineHandleCond = plot(1,1);
                    obj.LineHandleCond.XData = [];
                    obj.LineHandleCond.YData = [];
                    
                    %read in current parameters
                    currentDAQparam = getappdata(0,'daqParam');
                    obj.ScanLength = currentDAQparam.ScanLength;
                    obj.Interval = currentDAQparam.Interval;
                    obj.DwellTime = currentDAQparam.DwellTime;
                    
                    %test flow control parameters
                    obj.FlowControl = true;
                    obj.FlowConcentrationPoint = [1 200 400 600 800];
                    obj.FlowConcentrationValue = [0.1 0.05 0 0.05 0.1];
                    

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
                data = obj.PhotonCounter.getData;
                if ~isempty(data) %if it got something continue
                    obj.DataPhotonCounter.XData = ...
                        vertcat(obj.DataPhotonCounter.XData,obj.PointNumber*obj.PhotonCounter.Interval);
                    obj.DataPhotonCounter.YData = ...
                        vertcat(obj.DataPhotonCounter.YData,data);
                else
                    return %else exit
                end
            end
         
            
            %NIDAQ power data, needs photoncounter interval to create x
            if (~isempty(obj.DAQsession))
                obj.DataNIDAQpower.XData = ...
                    vertcat(obj.DataNIDAQpower.XData,obj.PointNumber*obj.PhotonCounter.Interval);
                obj.DataNIDAQpower.YData = ...
                    vertcat(obj.DataNIDAQpower.YData,obj.DAQsession.Session.inputSingleScan);
            end
            
            %pH meter data
            if (~isempty(obj.PHmeter))
                [pH, cond] = obj.PHmeter.getData;
                
                if ~isempty(pH) %if got the data add it
                    obj.DatapH.XData = ...
                        vertcat(obj.DatapH.XData,obj.PointNumber*obj.PhotonCounter.Interval);
                    obj.DataCond.XData = ...
                        vertcat(obj.DataCond.XData,obj.PointNumber*obj.PhotonCounter.Interval);
                    obj.DatapH.YData = vertcat(obj.DatapH.YData,pH);
                    obj.DataCond.YData = vertcat(obj.DataCond.YData,cond);
                end

            end
            
            %update x and y data for each plot
            obj.LineHandlePhotons.XData = obj.DataPhotonCounter.XData;
            obj.LineHandlePhotons.YData = obj.DataPhotonCounter.YData;
            
            obj.LineHandlePower.XData = obj.DataNIDAQpower.XData;
            obj.LineHandlePower.YData = obj.DataNIDAQpower.YData;
            
            obj.LineHandlepH.XData = obj.DatapH.XData;
            obj.LineHandlepH.YData = obj.DatapH.YData;
            
            obj.LineHandleCond.XData = obj.DataCond.XData;
            obj.LineHandleCond.YData = obj.DataCond.YData;

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
