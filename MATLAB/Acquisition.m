classdef Acquisition < handle
    properties
        %name of acquisition and timer
        Name
        Timer
        
        %handles for plotting data
        FigureHandle
        LineHandlePhotonsA
        LineHandlePhotonsB
        LineHandlePower
        LineHandlepH
        LineHandleCond
        
        %data
        DataPhotonCounterA
        DataPhotonCounterB
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
        Channel
        
        %parameters for flow control
        FlowIndex = 1;
        FlowConcentrationPoint
        FlowConcentrationValue
    end
    
    methods
        %initializes acq with parameters and sets up plots
        function obj = Acquisition(name)
            if nargin > 0
                if ischar(name)
                    %add name
                    obj.Name = name;
                    
                    %get current daqParam
                    daqParam = getappdata(0,'daqParam');
                    
                    %if photon counter enabled
                    %actually currently needs photonCounter for timing, so
                    %this must be true, but future version could time
                    %itself
                    obj.PhotonCounterEnabled = daqParam.PhotonCounterEnabled;
                    obj.ScanLength = daqParam.ScanLength;
                    obj.Interval = daqParam.Interval;
                    obj.DwellTime = daqParam.DwellTime;
                    obj.Channel = daqParam.Channel;
                    obj.PointNumber = 1;
                    if obj.PhotonCounterEnabled
                        %give reference to photon counter
                        obj.PhotonCounter = getappdata(0,'photonCounter');
                        obj.DataPhotonCounterA = XYData;
                        obj.DataPhotonCounterB = XYData;
                    end
                    
                    %if ADC power reading enabled
                    obj.ADCpowerEnabled = daqParam.ADCpowerEnabled;
                    if obj.ADCpowerEnabled
                        %give reference to labjack
                        obj.LabJack = getappdata(0,'labJack');
                        obj.DataADCpower = XYData;
                    end
                    
                    %if flow control is enabled
                    obj.FlowControl = daqParam.FlowControl;
                    if obj.FlowControl             
                        %give reference to pump
                        obj.Pump = getappdata(0,'pump');
                        %give reference to DAQsession
                        obj.DAQsession = getappdata(0,'daqSession');
                        obj.FlowConcentrationPoint = daqParam.FlowConcentrationPoint;
                        obj.FlowConcentrationValue = daqParam.FlowConcentrationValue;
                    end
                    
                    %if pH meter is enabled
                    obj.PHmeterEnabled = daqParam.PHmeterEnabled;
                    if obj.PHmeterEnabled
                        %give reference to pHmeter
                        obj.PHmeter = getappdata(0,'pHmeter');
                        obj.DatapH = XYData;
                        obj.DataCond = XYData;
                    end
                      
                    %create new figure to hold subplots handle
                    obj.FigureHandle = figure;
                    

                    %number of plots from photon counter
                    multiple = 1;
                    if strcmp(obj.Channel,'AB')
                        multiple = 2;
                    end  
                    %number of plots total
                    numplots = sum([obj.PhotonCounterEnabled*multiple ...
                        obj.ADCpowerEnabled obj.PHmeterEnabled*2]);
                    
                    %index to iterate through  plots
                    plotIndex = 1;
                    
                    %check to see which plots are needed and build   
                    %photon counter plots
                    if obj.PhotonCounterEnabled             
                        if contains(obj.Channel,'A')
                            subplot(numplots,1,plotIndex)
                            %create line object with temp point then delete 
                            obj.LineHandlePhotonsA = plot(0,0);
                            obj.LineHandlePhotonsA.XData = [];
                            obj.LineHandlePhotonsA.YData = [];
                            ylabel('A Counts')
                            plotIndex = plotIndex + 1;
                        end
                        if contains(obj.Channel,'B')
                            subplot(numplots,1,plotIndex)
                            %create line object with temp point then delete 
                            obj.LineHandlePhotonsB = plot(0,0);
                            obj.LineHandlePhotonsB.XData = [];
                            obj.LineHandlePhotonsB.YData = [];
                            ylabel('B Counts')
                            plotIndex = plotIndex + 1;
                        end
                    end
                    %adc plot for power data
                    if obj.ADCpowerEnabled 
                        subplot(numplots,1,plotIndex)                      
                        %create line object with temp point then delete
                        obj.LineHandlePower = plot(0,0);
                        obj.LineHandlePower.XData = [];
                        obj.LineHandlePower.YData = [];
                        ylabel('Power')
                        plotIndex = plotIndex + 1;
                    end
                    %pH plots                    
                    if obj.PHmeterEnabled
                        %plot for pH data
                        subplot(numplots,1,plotIndex)
                        %create line object with temp point then delete
                        obj.LineHandlepH = plot(0,0);
                        obj.LineHandlepH.XData = [];
                        obj.LineHandlepH.YData = [];
                        ylabel('pH')
                        plotIndex = plotIndex + 1;

                        %plot for cond data
                        subplot(numplots,1,plotIndex)
                        %create line object with temp point then delete
                        obj.LineHandleCond = plot(0,0);
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
        
        %check if data is ready and gets it if it is
        function  getData(obj)
            
            %photon counter data
            if (obj.PhotonCounterEnabled)
                [dataA,dataB] = obj.PhotonCounter.getData;
                if ~isempty(dataA) %if it got something continue
                    
                    if contains(obj.Channel,'A')
                        %add to x data
                        obj.DataPhotonCounterA.XData = ...
                            vertcat(obj.DataPhotonCounterA.XData,...
                            obj.PointNumber*obj.Interval);
                        %add to y data
                        obj.DataPhotonCounterA.YData = ...
                            vertcat(obj.DataPhotonCounterA.YData,dataA);
                        %update x and y data
                        obj.LineHandlePhotonsA.XData = obj.DataPhotonCounterA.XData;
                        obj.LineHandlePhotonsA.YData = obj.DataPhotonCounterA.YData;
                    end
                    if contains(obj.Channel,'B')
                        %add to x data
                        obj.DataPhotonCounterB.XData = ...
                            vertcat(obj.DataPhotonCounterB.XData,...
                            obj.PointNumber*obj.Interval);
                        %add to y data
                        obj.DataPhotonCounterB.YData = ...
                            vertcat(obj.DataPhotonCounterB.YData,dataB);
                        %update x and y data
                        obj.LineHandlePhotonsB.XData = obj.DataPhotonCounterB.XData;
                        obj.LineHandlePhotonsB.YData = obj.DataPhotonCounterB.YData;
                    end
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
            
            %if data received, check acquisition for flow control, 
            %end of scan, etc.
            obj.checkAcquisition
        end
        
        %checks f or flow control, end of scan, etc.
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
                        
                        %save current rates
                        daqParam = getappdata(0,'daqParam');
                        daqParam.PumpStates = rates;
                        
                        %set flow rates and start flow
                        obj.Pump.setFlowRates(rates);
                        obj.Pump.startFlowOpenValves();

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
        
        %start the acquisition
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
                obj.Pump.stopFlowCloseValves();
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
                obj.Pump.startFlowCloseValves();
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
                obj.Pump.stopFlowCloseValves();
            end
            
            %save data in a file
            %currently, only saves data at the end of the acquisition. 
               
            %first, create header according to which data has been recorded
            %start with photon counter data
            header = strcat(obj.Name,'_counts_time\t');
            if contains(obj.Channel,'A')
                header = strcat(header,obj.Name,'_countsA\t');
            end
            if contains(obj.Channel,'B')
                header = strcat(header,obj.Name,'_countsB\t');
            end
            %then adc data
            if ~isempty(obj.DataADCpower)
                header = strcat(header,obj.Name,'_power_time\t',...
                    obj.Name,'_power\t');
            end
            %then pH data
            if ~isempty(obj.DataCond)
                header = strcat(header,obj.Name,'_phmeter_time\t',...
                    obj.Name,'_phmeter_cond\t',obj.Name,'_phmeter_pH\t');
            end
            header = strcat(header,'\r\n');
            
            %then, create file and write to it
            filename = strcat(obj.Name,'.txt');
            fileID = fopen(filename,'w');
            fprintf(fileID,header);
            fclose(fileID);
            
            %then write data. first turn recorded data into square array
            %to do that, build matrix to find length of each vector
            %photon counter vectors
            if strcmp(obj.Channel,'A')
                nR = [size(obj.DataPhotonCounterA.XData,1) ...
                    size(obj.DataPhotonCounterA.YData,1)];
            elseif strcmp(obj.Channel,'B')
                nR = [size(obj.DataPhotonCounterB.XData,1) ...
                    size(obj.DataPhotonCounterB.YData,1)];
            elseif strcmp(obj.Channel,'AB')
                nR = [size(obj.DataPhotonCounterA.XData,1) ...
                    size(obj.DataPhotonCounterA.YData,1) ...
                    size(obj.DataPhotonCounterB.YData,1)];
            end 
            %adc vector
            if ~isempty(obj.DataADCpower)
                nR = horzcat(nR,[size(obj.DataADCpower.XData,1) ...
                    size(obj.DataADCpower.YData,1)]);
            end
            %pH meter vectors
            if ~isempty(obj.DataCond)
                nR = horzcat(nR, [size(obj.DataCond.XData,1) ...
                size(obj.DataCond.YData,1) ...
                size(obj.DatapH.YData,1)]);
            end
            %calculate number needed to pad with nan to turn into square
            dR = max(nR) - nR;
            
            %then actually combine recorded vectors together and pad
            %photoncounter data
            if strcmp(obj.Channel,'A')
                data = horzcat([obj.DataPhotonCounterA.XData;nan(dR(1),1)],...
                    [obj.DataPhotonCounterA.YData;nan(dR(2),1)]);
                index = 3;
            elseif strcmp(obj.Channel,'B')
                data = horzcat([obj.DataPhotonCounterB.XData;nan(dR(1),1)],...
                    [obj.DataPhotonCounterB.YData;nan(dR(2),1)]);
                index = 3;
            elseif strcmp(obj.Channel,'AB')
                data = horzcat([obj.DataPhotonCounterA.XData;nan(dR(1),1)],...
                    [obj.DataPhotonCounterA.YData;nan(dR(2),1)],...
                    [obj.DataPhotonCounterB.YData;nan(dR(3),1)]);
                index = 4;
            end 
            %adc vector
            if ~isempty(obj.DataADCpower)
                data = horzcat(data,[obj.DataADCpower.XData;nan(dR(index),1)],...
                    [obj.DataADCpower.YData;nan(dR(index+1),1)]);
                index = index + 2;
            end
            %pH meter vectors
            if ~isempty(obj.DataCond)
                data = horzcat(data,[obj.DataCond.XData;nan(dR(index),1)],...
                    [obj.DataCond.YData;nan(dR(index+1),1)],...
                    [obj.DatapH.YData;nan(dR(index+2),1)]);
            end
            
            %write them to file
            dlmwrite(filename,data,'-append','delimiter','\t','newline','pc');
        end
    end
end
