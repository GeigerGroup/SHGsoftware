classdef Scan < handle
    %SCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Timer
        
        %figure for plotting data
        Figure
        
        %data object to hold all data
        Data
        
        %point number for stage control
        StageIndex = 1;
        CurrentStagePosition
        PointNumber = 1
    end
    
    methods
        function obj = Scan(name)
            %Makes Scan object that will be used only for initiating
            %stage movement for HD-SHG measurements
            if nargin > 0
                if ischar(name)
                    %add name
                    obj.Name = name;
                    
                    %create timer to time scan
                    %repeatedly polls the photon counter every 100 ms
                    %to see when data is ready, then gets other data
                    obj.Timer = timer;
                    obj.Timer.StartFcn = @(~,~) disp('Scan started.');
                    obj.Timer.TimerFcn = {@(~,~,obj) obj.getData, obj};
                    obj.Timer.StopFcn = @(~,~) disp('Scan stopped.');
                    obj.Timer.Period = 0.1; obj.Timer.StartDelay = 0.05;
                    obj.Timer.ExecutionMode = 'fixedRate';
                    
                    %get current daqParam
                    daqParam = getappdata(0,'daqParam');
                    
                    %create new figure based on what is enabled
                    obj.Figure = ScanFigure();
                    
                    %create data structure to hold data
                    obj.Data = ScanData();
                    
                    %write header to file
                    fileID = fopen(strcat(obj.Name,'.txt'),'w');
                    fprintf(fileID,obj.Data.createHeader());
                    fclose(fileID);
                    
                    
                    %go to first position
                    if daqParam.ContMode == false
                        obj.CurrentStagePosition = daqParam.ScanPositions(1);
                        daqParam.Stage.goTo(obj.CurrentStagePosition);
                    else
                        %if continuous mode
                        %if not at either end, go to 0
                        if obj.checkAtEnd == false
                            daqParam.Stage.goTo(0);
                        else
                            %If at start, go to end
                            if daqParam.Stage.getCurrentPosition == 0
                                daqParam.Stage.goToCont(99.7)
                            %if at end, go to start
                            elseif daqParam.Stage.getCurrentPosition == 39880
                                daqParam.Stage.goToCont(0)
                            end
                        end

                    end
                    
                    obj.startScan()
                else
                    error('Input name must be char')
                end
            else
                error('Acquisition needs a name')
            end
        end
            
        function startScan(obj)
            %start timer
            start(obj.Timer)
            
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
            %stage position
            obj.Data.Stage = vertcat(obj.Data.Stage,daqParam.Stage.getCurrentPosition/400);

            %update plots
            obj.Figure.updatePlots(obj.Data);
    
            %open file in append mode, write string to it
            fileID = fopen(strcat(obj.Name,'.txt'),'a');
            fprintf(fileID,obj.Data.getLastDataString());
            fclose(fileID);
            
            %if data received, check acquisition for flow control, 
            %end of scan, etc.
            obj.checkScan
        end
        
        function checkScan(obj)
            %Checks stage progress and end scan   
            
            %get parameters
            daqParam = getappdata(0,'daqParam');
            
            if daqParam.ContMode == false
                %check if its at the end of an interval
                if (rem(obj.PointNumber,daqParam.PointsPerPos) == 0)
                    %iterate index since interval is over
                    obj.StageIndex = obj.StageIndex + 1;
                    %if scan is over
                    if (obj.StageIndex > length(daqParam.ScanPositions))
                        obj.stopScan;
                        daqParam.Stage.goTo(0);
                        if daqParam.IndefiniteScans == true
                            %start new scan
                            daqParam.ScanNumber = daqParam.ScanNumber + 1;
                            name = strcat(daqParam.Name,'_',num2str(daqParam.ScanNumber));
                            scan = Scan(name);
                            setappdata(0,name,scan);
                        else
                            return
                        end
                    else
                        %if scan is still continuing, just go to next point
                        daqParam.PhotonCounter.stopScan();
                        obj.CurrentStagePosition = daqParam.ScanPositions(obj.StageIndex);
                        daqParam.Stage.goTo(obj.CurrentStagePosition);
                        daqParam.PhotonCounter.startScan();
                    end
                end
            else
                %continuous mode code
                atEnd = obj.checkAtEnd();
                if (atEnd)
                    obj.stopScan;     
                    if daqParam.IndefiniteScans == true 
                        %start new scan
                        daqParam.ScanNumber = daqParam.ScanNumber + 1;
                        name = strcat(daqParam.Name,'_',num2str(daqParam.ScanNumber));
                        scan = Scan(name);
                        setappdata(0,name,scan);
                    else
                        daqParam.Stage.goTo(0);
                    end
                end
            end
            
            %increment point number in scan
            obj.PointNumber = obj.PointNumber + 1;
        end
        
        function goToContinuous(obj)
            %this function starts scan to 99.7 without pausing MATLAB
            %to wait for the end
            position = 99.7;
            steps = int32(position*400);
            
            %go to the position
            disp(['Going to ' num2str(position) ' mm']);
            
            result = calllib('libximc','command_move', obj.ID, ...
                steps, 0);
            if result ~= 0
                    disp(['Command failed with code', num2str(result)]);
            end
        end
        
        function atEnd = checkAtEnd(obj)
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            %get current position
            position = daqParam.Stage.getCurrentPosition();
            
            %check if at beginning or end
            if ((position == 39880)||(position == 0))
                atEnd = true;
            else
                atEnd = false;
            end
        end
        
        function stopScan(obj)
            %stop and delete timer
            stop(obj.Timer);
            delete(obj.Timer);
            %get current parameters
            daqParam = getappdata(0,'daqParam');
            %reset photon counter
            if (daqParam.PhotonCounterEnabled)
                daqParam.PhotonCounter.stopScan
            end
        end
    end
    
    
end


