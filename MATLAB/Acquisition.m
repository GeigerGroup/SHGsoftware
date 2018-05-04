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
        DataADCpower
        DatapH
        DataCond
        
        %hardware objects
        PhotonCounter
        LabJack
        PHmeter
        DAQsession
        Pump
        
        %if objects enabled for this acquisition
        PhotonCounterEnabled
        ADCpowerEnabled
        PHmeterEnabled
        FlowControl
        SolStates
        
        %parameters for photon counter
        PointNumber
        ScanLength
        Interval
        DwellTime
        
        %parameters for flow control
        FlowIndex = 1;
        FlowConcentrationPoint
        FlowConcentrationValue
    end
    
    methods
        function obj = Acquisition(name)
            if nargin > 0
                if ischar(name)
                    %add name
                    obj.Name = name;
                    
                    %get current daqParam
                    daqParam = getappdata(0,'daqParam');
                    
                    %give reference to photon counter
                    obj.PhotonCounter = getappdata(0,'photonCounter');
                    obj.DataPhotonCounter = XYData;
                    
                    %give reference to labjack
                    obj.LabJack = getappdata(0,'labJack');
                    obj.DataADCpower = XYData;
                    
                    %give reference to pump
                    obj.Pump = getappdata(0,'pump');
                    
                    %give reference to DAQsession
                    obj.DAQsession = getappdata(0,'daqSession');
                    
                    %give reference to pHmeter
                    obj.PHmeter = getappdata(0,'pHmeter');
                    obj.DatapH = XYData;
                    obj.DataCond = XYData;
                    
                    %hardware enabled
                    obj.PhotonCounterEnabled = daqParam.PhotonCounterEnabled;
                    obj.ADCpowerEnabled = daqParam.ADCpowerEnabled;
                    obj.PHmeterEnabled = daqParam.PHmeterEnabled;
                    obj.FlowControl = daqParam.FlowControl;
                      
                    %create new figure to hold 4 subplots handle
                    obj.FigureHandle = figure;
                    
                    obj.PointNumber = 1;
                    obj.ScanLength = daqParam.ScanLength;
                    obj.Interval = daqParam.Interval;
                    obj.DwellTime = daqParam.DwellTime;
                    
                    if obj.PhotonCounterEnabled             
                        %photon parameters
                        obj.PhotonCounter.setDwellTime(obj.DwellTime);
                        obj.PhotonCounter.setInterval(obj.Interval);
                        
                        %plot for photon data
                        subplot(4,1,1)
                        %create line object with temp point then delete-
                        %cleanup?
                        obj.LineHandlePhotons = plot(1,1);
                        obj.LineHandlePhotons.XData = [];
                        obj.LineHandlePhotons.YData = [];
                        ylabel('Counts')
                    end
                    
                    if obj.ADCpowerEnabled
                        %plot for power data
                        subplot(4,1,2)                
                        %create line object with temp point then delete-
                        %cleanup?
                        obj.LineHandlePower = plot(1,1);
                        obj.LineHandlePower.XData = [];
                        obj.LineHandlePower.YData = [];
                        ylabel('Power')
                    end
                    
                    if obj.FlowControl
                        %flow control parameters
                        obj.FlowConcentrationPoint = daqParam.FlowConcentrationPoint;
                        obj.FlowConcentrationValue = daqParam.FlowConcentrationValue;
                    end
                    
                    if obj.PHmeterEnabled
                        %plot for pH data
                        subplot(4,1,3)
                        %create line object with temp point then delete-
                        %cleanup?
                        obj.LineHandlepH = plot(1,1);
                        obj.LineHandlepH.XData = [];
                        obj.LineHandlepH.YData = [];
                        ylabel('pH')

                        %plot for cond data
                        subplot(4,1,4)
                        %create line object with temp point then delete-
                        %cleanup?
                        obj.LineHandleCond = plot(1,1);
                        obj.LineHandleCond.XData = [];
                        obj.LineHandleCond.YData = [];
                        ylabel('Cond')

                    end

                    %create timer to time acquisition
                    obj.Timer = createDataTimer(obj);
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
            if (obj.PhotonCounterEnabled)
                data = obj.PhotonCounter.getData;
                if ~isempty(data) %if it got something continue
                    obj.DataPhotonCounter.XData = ...
                        vertcat(obj.DataPhotonCounter.XData,obj.PointNumber*obj.Interval);
                    obj.DataPhotonCounter.YData = ...
                        vertcat(obj.DataPhotonCounter.YData,data);
                    
                    %update x and y data
                    obj.LineHandlePhotons.XData = obj.DataPhotonCounter.XData;
                    obj.LineHandlePhotons.YData = obj.DataPhotonCounter.YData;
                else
                    %if no data ready, exit without checking
                    return
                end
            end
         
            
            %ADC power data
            if (obj.ADCpowerEnabled)
                obj.DataADCpower.XData = ...
                    vertcat(obj.DataADCpower.XData,obj.PointNumber*obj.Interval);
                obj.DataADCpower.YData = ...
                    vertcat(obj.DataADCpower.YData,obj.LabJack.getReading);
                
                %update x and y data on plot
                obj.LineHandlePower.XData = obj.DataADCpower.XData;
                obj.LineHandlePower.YData = obj.DataADCpower.YData;
            end
            
            %pH meter data
            if (obj.PHmeterEnabled)
                [pH, cond] = obj.PHmeter.getData;
                
                if ~isempty(pH) %if got the data add it
                    obj.DatapH.XData = ...
                        vertcat(obj.DatapH.XData,obj.PointNumber*obj.Interval);
                    obj.DataCond.XData = ...
                        vertcat(obj.DataCond.XData,obj.PointNumber*obj.Interval);
                    obj.DatapH.YData = vertcat(obj.DatapH.YData,pH);
                    obj.DataCond.YData = vertcat(obj.DataCond.YData,cond);
                    
                    %update x and y data on plot
                    obj.LineHandlepH.XData = obj.DatapH.XData;
                    obj.LineHandlepH.YData = obj.DatapH.YData;
                    
                    obj.LineHandleCond.XData = obj.DataCond.XData;
                    obj.LineHandleCond.YData = obj.DataCond.YData;
                end
            end
            
            %if data was received, check acquisition
            obj.checkAcquisition
        end
        
        function checkAcquisition(obj)
            
            %check if flow control should occur
            if obj.FlowControl 
                %check if that all flow changes haven't happened
                if obj.FlowIndex <= length(obj.FlowConcentrationPoint)
                    %if at point where change should ocurr
                    if obj.PointNumber == obj.FlowConcentrationPoint(obj.FlowIndex)
                        disp(strcat('Flow change at point:  ',num2str(obj.PointNumber)))
                        
                        %calculate flow rates for two reservoir salt
                        rates = obj.Pump.calculateRates(obj.FlowConcentrationValue(obj.FlowIndex));
                        disp(rates)
                        
                        %calculate solenoid state
                        states = rates > 0; %set solenoid valve to on if rate > 0
                        %states =[states any(states)]; %set valve 5 to on if any of others are on
                        states = [states 0]; %keep 5 always off
                        disp(states)
                        
                        %save solenoid states
                        obj.SolStates = states;
                        
                        %set flow rates and start flow
                        obj.Pump.setFlowRates(rates);
                        obj.Pump.startFlows;
                        
                        %set solenoid state
                        obj.DAQsession.setValveStates(states);
                        
                        %increment flow index
                        obj.FlowIndex = obj.FlowIndex + 1;
                    end
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
            if (obj.PhotonCounterEnabled)
                obj.PhotonCounter.resetScan
                obj.PhotonCounter.startScan
                
                %clear out first point?
                obj.PhotonCounter.getData;
            end
        end
        
        function pauseAcquisition(obj)        
            %stop timer
            stop(obj.Timer);
            
            %stop photon counter
            if (obj.PhotonCounterEnabled)
                obj.PhotonCounter.stopScan
                disp('Photon counter paused.')
            end
            
            %close valves and stop pump
            if (obj.FlowControl)
                obj.DAQsession.setValveStates([0 0 0 0 0]);
                obj.Pump.stopFlows
            end             
        end
        
        function resumeAcquisition(obj)
            %start timer
            start(obj.Timer);
            
            %start photon counter
            if (obj.PhotonCounterEnabled)
                obj.PhotonCounter.startScan
            end
            
            %open valves and start pump
            if (obj.FlowControl)
                obj.DAQsession.setValveStates(obj.SolStates);
                obj.Pump.startFlows
            end      
        end

        function stopAcquisition(obj)
            %stop and delete timer
            stop(obj.Timer);
            delete(obj.Timer);
            
            %reset photon counter
            if (obj.PhotonCounterEnabled)
                obj.PhotonCounter.stopScan
            end
            
            %close valves and stop pump
            if (obj.FlowControl)
                obj.DAQsession.setValveStates([0 0 0 0 0]);
                obj.Pump.stopFlows
            end
            
            %save data in a file
            
            %create header, find lengths to pad with NaN
            headers = strcat(obj.Name,'_counts_time','\t',...
                obj.Name,'_counts','\t',obj.Name,'_power_time','\t',...
                obj.Name,'_power','\t',obj.Name,'_phmeter_time','\t',...
                obj.Name,'_phmeter_cond','\t',obj.Name,'phmeter_pH','\t\n');
            
            %find lengths to pad with nan
            nR = [size(obj.DataPhotonCounter.XData,1) ...
                size(obj.DataPhotonCounter.YData,1) ...
                size(obj.DataADCpower.XData,1) ...
                size(obj.DataADCpower.YData,1) ...
                size(obj.DataCond.XData,1) ...
                size(obj.DataCond.YData,1) ...
                size(obj.DatapH.YData,1) ];
            dR = max(nR) - nR;
            
            %pad with nan and turn into array
            data = horzcat([obj.DataPhotonCounter.XData;nan(dR(1),1)], ...
                [obj.DataPhotonCounter.YData;nan(dR(2),1)], ...
                [obj.DataADCpower.XData;nan(dR(3),1)], ...
                [obj.DataADCpower.YData;nan(dR(4),1)], ...
                [obj.DataCond.XData;nan(dR(5),1)], ...
                [obj.DataCond.YData;nan(dR(6),1)], ...
                [obj.DatapH.YData;nan(dR(7),1)]);
            
            %create file and write to it
            filename = strcat(obj.Name,'.txt');
            fileID = fopen(filename,'w');
            fprintf(fileID,headers);
            fclose(fileID);
            dlmwrite(filename,data,'-append','delimiter','\t','newline','pc');
        end
    end
end
