classdef Scan < handle
    %SCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %point number for stage control
        StageIndex = 1;
        CurrentStagePosition
        PeakFindActive = false;
        PeakFindPositions;
    end
    
    methods
        function obj = Scan()
            %Makes Scan object that will be used only for initiating 
            %stage movement for HD-SHG measurements
            
            %get current daqParam
            daqParam = getappdata(0,'daqParam');
                    
             %if stage control is enabled, go to 0
            if daqParam.StageControlEnabled
                if daqParam.Stage.ContMode == false
                    obj.CurrentStagePosition = daqParam.Stage.ScanPositions(1);
                    daqParam.Stage.goTo(obj.CurrentStagePosition);
                else
                    daqParam.Stage.goTo(0);
                    %start continuous mode code
                    daqParam.Stage.startContScan;
                end
            end
        end
        
        function checkScan(obj)
            %Checks stage progress and end scan
            
            %if stage control is on
            if daqParam.StageControlEnabled
                if daqParam.Stage.ContMode == false
                    %check if its at the end of an interval
                    if (rem(obj.PointNumber,daqParam.Stage.PointsPerPos) == 0)
                        %iterate index since interval is over
                        obj.StageIndex = obj.StageIndex + 1;
                        %if scan is over
                        if (obj.StageIndex > length(daqParam.Stage.ScanPositions))
                            %just end
                            daqParam.Stage.goTo(0);
                            obj.stopAcquisition;
                            return
                        else
                            %if scan is still continuing, just go to next point
                            daqParam.PhotonCounter.stopScan();
                            obj.CurrentStagePosition = daqParam.Stage.ScanPositions(obj.StageIndex);
                            daqParam.Stage.goTo(obj.CurrentStagePosition);
                            daqParam.PhotonCounter.startScan();
                        end
                    end
                else
                    %continuous mode code
                    reachedEnd = daqParam.Stage.checkContScan();
                    if (reachedEnd)
                        obj.stopAcquisition;
                        %set speed back to normal speed
                        daqParam.Stage.setSpeed(daqParam.Stage.NormalSpeed);
                        daqParam.Stage.goTo(0);
                    end
                end
            end
        end
         
       
    end
end

