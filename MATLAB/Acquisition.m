classdef Acquisition < handle
    properties
        %name of acquisition and timer
        Name
        Timer
        
        %figure for plotting data
        Figure
        
        %data
        Data
        DataTime
        DataPhotonCounterA
        DataPhotonCounterB
        DataADCpower
        DatapH
        DataCond
        DataStage
        
        %point number for photon counter
        PointNumber = 1;

        %point number for flow control
        FlowIndex = 1;
        CurrentSolution
        
        %point number for stage control
        StageIndex = 1;
        CurrentStagePosition
        
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
                    
                    %create new figure based on what is enabled
                    obj.Figure = DAQfigure();
                    
                    %create data structure to hold data
                    obj.Data = DAQdata();

                    %write data to file
                    %create header based on what is enabled
                    header = obj.Figure.createHeader();

                    %then, create file and write to it
                    filename = strcat(obj.Name,'.txt');
                    fileID = fopen(filename,'w');
                    fprintf(fileID,header);
                    fclose(fileID);
                    
                    %if flow control is enabled, set to first position
                    %(should change)
                    if daqParam.FlowControl
                        obj.CurrentSolution = daqParam.FlowConcentrationValue(1);
                    end
                    
                    %if stage control is enabled, go to initial position
                    if daqParam.StageControlEnabled
                        obj.CurrentStagePosition = daqParam.StageScanPositions(obj.StageIndex);
                        daqParam.Stage.goTo(obj.CurrentStagePosition);
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
                     
            %photon counter data
            if (daqParam.PhotonCounterEnabled)
                [dataA,dataB] = daqParam.PhotonCounter.getData();
                if ~isempty(dataA) %if it got something continue
                    %now timing runs off photon counter, should change
                    obj.Data.Time = vertcat(obj.Data.Time, obj.PointNumber*daqParam.Interval);
                    if contains(daqParam.Channel,'A')
                        obj.Data.PhotonCounterA = vertcat(obj.Data.PhotonCounterA,dataA);
                    end
                    if contains(daqParam.Channel,'B')
                        obj.Data.PhotonCounterB = vertcat(obj.Data.PhotonCounterB,dataB);
                    end
                else
                    return %if no data ready, exit without checking
                end
            end
            %then ADC power data
            if (daqParam.ADCpowerEnabled)
                powerData = daqParam.ADC.getReading();
                obj.Data.ADCpower = vertcat(obj.Data.ADCpower,powerData);
            end
            %then pH meter data
            if (daqParam.PHmeterEnabled)
                [pH, cond] = daqParam.PHmeter.getData;
                if ~isempty(pH) %if got the data
                    datapH = pH;
                else
                    datapH = NaN;
                end
                obj.Data.pH = vertcat(obj.Data.pH,datapH);
                if ~isempty(cond)
                    dataCond = cond;
                else
                    dataCond = NaN;
                end
                obj.Data.Cond = vertcat(obj.Data.Cond,dataCond);
            end
            %then flow control value
            if (daqParam.FlowControl)
                obj.Data.Solution = vertcat(obj.Data.Solution,obj.CurrentSolution);
            end
            %stage position
            if daqParam.StageControlEnabled
                obj.Data.Stage = vertcat(obj.Data.Stage,obj.CurrentStagePosition);
            end
            
            %update plots
            obj.Figure.updatePlots(obj.Data);
            
            %open file in append mode, write string to it
            fileID = fopen(strcat(obj.Name,'.txt'),'a');
            fprintf(fileID,obj.Data.getLastDataString());
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
                        rates = daqParam.Pump.calculateRates(daqParam.FlowConcentrationValue(obj.FlowIndex));
                        %set current condition for writing to file
                        obj.CurrentSolution = daqParam.FlowConcentrationValue(obj.FlowIndex);
                        %save current rates
                        daqParam.PumpStates = rates;
                        %set flow rates and start flow
                        daqParam.Pump.setFlowRates(rates);
                        daqParam.Pump.startFlowOpenValves();
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
            
%             if daqParam.StageControlEnabled
%                 if (rem(obj
            
            %check if should pause because of automatic next pause
            if (daqParam.AutoPause > 0)
                if (rem(obj.PointNumber,daqParam.AutoPause) == 0)
                    if daqParam.StageControlEnabled
                        %iterate position
                        obj.StageIndex = obj.StageIndex + 1;
                        if (obj.StageIndex > length(daqParam.StageScanPositions))
                            obj.stopAcquisition
                            return
                        else
                            %pause photonCounter
                            daqParam.PhotonCounter.stopScan()
                            %change stage position
                            daqParam.Stage.goTo(daqParam.StageScanPositions(obj.StageIndex));
                            obj.CurrentStagePosition = daqParam.StageScanPositions(obj.StageIndex);
                            %resume photonCounter
                            daqParam.PhotonCounter.startScan()
                        end
                    else
                        obj.pauseAcquisition;
                    end
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
                daqParam.PhotonCounter.resetScan
                daqParam.PhotonCounter.startScan
                
                %clear out first point?
                daqParam.PhotonCounter.getData;
            end
        end
        
        function pauseAcquisition(obj)        
            %stop timer
            stop(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %stop photon counter
            if (daqParam.PhotonCounterEnabled)
                daqParam.PhotonCounter.stopScan
                disp('Photon counter paused.')
            end
            
            %close valves and stop pump
            if (daqParam.FlowControl)
                daqParam.Pump.stopFlowCloseValves();
            end             
        end
        
        function resumeAcquisition(obj)
            %start timer
            start(obj.Timer);
            
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            
            %start photon counter
            if (daqParam.PhotonCounterEnabled)
                daqParam.PhotonCounter.startScan
            end
            
            %open valves and start pump
            if (daqParam.FlowControl)
                daqParam.Pump.startFlowOpenValves();
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
                daqParam.PhotonCounter.stopScan
            end
            %close valves and stop pump
            if (daqParam.FlowControl)
                daqParam.Pump.stopFlowCloseValves();
            end
        end
    end
end
