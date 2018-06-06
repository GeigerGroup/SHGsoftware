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
        DataTime
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
        
        %point number for photon counter
        PointNumber = 1;

        %point number for flow control
        FlowIndex = 1;
        CurrentSolution
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
                    if daqParam.PhotonCounterEnabled
                        %give reference to photon counter
                        obj.PhotonCounter = getappdata(0,'photonCounter');
                    end
                    
                    %if ADC power reading enabled
                    if daqParam.ADCpowerEnabled
                        %give reference to labjack
                        obj.LabJack = getappdata(0,'labJack');
                    end
                    
                    %if flow control is enabled
                    if daqParam.FlowControl             
                        %give reference to pump
                        obj.Pump = getappdata(0,'pump');
                        %give reference to DAQsession
                        obj.DAQsession = getappdata(0,'daqSession');
                    end
                    
                    %if pH meter is enabled
                    if daqParam.PHmeterEnabled
                        %give reference to pHmeter
                        obj.PHmeter = getappdata(0,'pHmeter');
                    end
                      
                    %create new figure to hold subplots handle
                    obj.FigureHandle = figure;

                    %number of plots from photon counter
                    multiple = 1;
                    if strcmp(daqParam.Channel,'AB')
                        multiple = 2;
                    end  
                    %number of plots total
                    numplots = sum([daqParam.PhotonCounterEnabled*multiple ...
                        daqParam.ADCpowerEnabled daqParam.PHmeterEnabled*2]);
                    
                    %index to iterate through  plots
                    plotIndex = 1;
                    
                    %check to see which plots are needed and build   
                    %photon counter plots
                    if daqParam.PhotonCounterEnabled             
                        if contains(daqParam.Channel,'A')
                            subplot(numplots,1,plotIndex)
                            %create line object with temp point then delete 
                            obj.LineHandlePhotonsA = plot(0,0);
                            obj.LineHandlePhotonsA.XData = [];
                            obj.LineHandlePhotonsA.YData = [];
                            ylabel('A Counts')
                            plotIndex = plotIndex + 1;
                        end
                        if contains(daqParam.Channel,'B')
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
                    if daqParam.ADCpowerEnabled 
                        subplot(numplots,1,plotIndex)                      
                        %create line object with temp point then delete
                        obj.LineHandlePower = plot(0,0);
                        obj.LineHandlePower.XData = [];
                        obj.LineHandlePower.YData = [];
                        ylabel('Power')
                        plotIndex = plotIndex + 1;
                    end
                    %pH plots                    
                    if daqParam.PHmeterEnabled
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
                    
                    %first, create header according to which data has been recorded
                    %start with photon counter data
                    header = 'time';
                    if contains(daqParam.Channel,'A')
                        header = strcat(header,'\tcountsA');
                    end
                    if contains(daqParam.Channel,'B')
                        header = strcat(header,'\tcountsB');
                    end
                    %then adc data
                    if daqParam.ADCpowerEnabled
                        header = strcat(header,'\tpower');
                    end
                    %then pH data
                    if daqParam.PHmeterEnabled
                        header = strcat(header,'\tcond','\tpH');
                    end
                    %then target concentration
                    if daqParam.FlowControl
                        header = strcat(header,'\tsolution');
                    end      
                    header = strcat(header,'\r\n');
                    
                    %then, create file and write to it
                    filename = strcat(obj.Name,'.txt');
                    fileID = fopen(filename,'w');
                    fprintf(fileID,header);
                    fclose(fileID);
                    
                    %set solution condition to first value (SHOULD CHANGE)
                    if daqParam.FlowControl
                        obj.CurrentSolution = daqParam.FlowConcentrationValue(1);
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
            
            %get parameters
            daqParam = getappdata(0,'daqParam');
            
            output = num2str(obj.PointNumber);
            %photon counter data
            if (daqParam.PhotonCounterEnabled)
                [dataA,dataB] = obj.PhotonCounter.getData;
                if ~isempty(dataA) %if it got something continue
                    %now timing runs off photon counter, should change
                    obj.DataTime = vertcat(obj.DataTime,...
                        obj.PointNumber*daqParam.Interval);
                    if contains(daqParam.Channel,'A')
                        %add to y data
                        obj.DataPhotonCounterA = vertcat(obj.DataPhotonCounterA,dataA);
                        %update x and y data
                        obj.LineHandlePhotonsA.XData = obj.DataTime;
                        obj.LineHandlePhotonsA.YData = obj.DataPhotonCounterA;
                        %add data to output string
                        output = strcat(output,'\t',num2str(dataA));
                    end
                    if contains(daqParam.Channel,'B')
                        %add to y data
                        obj.DataPhotonCounterB = vertcat(obj.DataPhotonCounterB,dataB);
                        %update x and y data
                        obj.LineHandlePhotonsB.XData = obj.DataTime;
                        obj.LineHandlePhotonsB.YData = obj.DataPhotonCounterB;
                        %add data to output string
                        output = strcat(output,'\t',num2str(dataB));
                    end
                else
                    %if no data ready, exit without checking
                    return
                end
            end
         
            %ADC power data
            if (daqParam.ADCpowerEnabled)
                powerData = obj.LabJack.getReading;
                obj.DataADCpower = vertcat(obj.DataADCpower,powerData);
                
                %update x and y data on plot
                obj.LineHandlePower.XData = obj.DataTime;
                obj.LineHandlePower.YData = obj.DataADCpower;
                
                %add data to output string
                output = strcat(output,'\t',num2str(powerData));
            end
            
            %pH meter data
            if (daqParam.PHmeterEnabled)
                [pH, cond] = obj.PHmeter.getData;
                
                if ~isempty(pH) %if got the data
                    datapH = pH;
                else
                    datapH = NaN;
                end
                obj.DatapH = vertcat(obj.DatapH,datapH);
                
                if ~isempty(cond)
                    dataCond = cond;
                else
                    dataCond = NaN;
                end
                obj.DataCond = vertcat(obj.DataCond,dataCond);

                %update x and y data on plot
                obj.LineHandlepH.XData = obj.DataTime;
                obj.LineHandlepH.YData = obj.DatapH;
                
                obj.LineHandleCond.XData = obj.DataTime;
                obj.LineHandleCond.YData = obj.DataCond; 
                
                %add data to output string
                output = strcat(output,'\t',num2str(dataCond),...
                    '\t',num2str(datapH));
            end
            
            %flow control value
            if (daqParam.FlowControl)
                output = strcat(output,'\t',num2str(obj.CurrentSolution));
            end
            
            %write line of data to file
            output = strcat(output,'\r\n');
            filename = strcat(obj.Name,'.txt');
            %open file in append mode
            fileID = fopen(filename,'a');
            fprintf(fileID,output);
            fclose(fileID);
            
            %if data received, check acquisition for flow control, 
            %end of scan, etc.
            obj.checkAcquisition
        end
        
        %checks for flow control, end of scan, etc.
        function checkAcquisition(obj)
            
            %get daq parameters
            daqParam = getappdata(0,'daqParam');
            
            %check if flow control should occur
            if daqParam.FlowControl 
                %check if that all flow changes haven't happened
                if obj.FlowIndex <= length(daqParam.FlowConcentrationPoint)
                    %if at point where change should ocurr
                    if obj.PointNumber == daqParam.FlowConcentrationPoint(obj.FlowIndex)
                        disp(strcat('Flow change at point:  ',num2str(obj.PointNumber)))
                        
                        %calculate flow rates for two reservoir salt
                        rates = obj.Pump.calculateRates(daqParam.FlowConcentrationValue(obj.FlowIndex));
                        
                        %set current condition for writing to file
                        obj.CurrentSolution = daqParam.FlowConcentrationValue(obj.FlowIndex);
                        
                        %save current rates
                        daqParam.PumpStates = rates;
                        
                        %set flow rates and start flow
                        obj.Pump.setFlowRates(rates);
                        obj.Pump.startFlowOpenValves();

                        %increment flow index
                        obj.FlowIndex = obj.FlowIndex + 1;
                    end
                end
            end
            
            %check if have exceeded scan length and then stop
            if obj.PointNumber >= daqParam.ScanLength
                obj.stopAcquisition
                return
            end
            
            %check if should pause because of automatic next pause
            if (daqParam.AutoPause > 0)
                if (rem(obj.PointNumber,daqParam.AutoPause) == 0)
                    obj.pauseAcquisition
                end
            end
            
            %increment point number in acquisition
            obj.PointNumber = obj.PointNumber + 1;
        end
        
        %start the acquisition
        function startAcquisition(obj)
            
            %start timer
            start(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %start photon counter
            if (daqParam.PhotonCounterEnabled)
                obj.PhotonCounter.resetScan
                obj.PhotonCounter.startScan
                
                %clear out first point?
                obj.PhotonCounter.getData;
            end
        end
        
        function pauseAcquisition(obj)        
            %stop timer
            stop(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %stop photon counter
            if (daqParam.PhotonCounterEnabled)
                obj.PhotonCounter.stopScan
                disp('Photon counter paused.')
            end
            
            %close valves and stop pump
            if (daqParam.FlowControl)
                obj.Pump.stopFlowCloseValves();
            end             
        end
        
        function resumeAcquisition(obj)
            %start timer
            start(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %start photon counter
            if (daqParam.PhotonCounterEnabled)
                obj.PhotonCounter.startScan
            end
            
            %open valves and start pump
            if (daqParam.FlowControl)
                obj.Pump.startFlowCloseValves();
            end      
        end

        function stopAcquisition(obj)
            %stop and delete timer
            stop(obj.Timer);
            delete(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %reset photon counter
            if (daqParam.PhotonCounterEnabled)
                obj.PhotonCounter.stopScan
            end
            
            %close valves and stop pump
            if (daqParam.FlowControl)
                obj.Pump.stopFlowCloseValves();
            end
        end
    end
end
