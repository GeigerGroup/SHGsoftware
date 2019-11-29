classdef Measurement < handle
    properties
        Name
        Timer
        TimeInterval
        Data
        Instrument
        PointNumber
        Figure
        LineHandle
    end
    
    methods
        function obj = Measurement(name,time)
            obj.Name = name;
            obj.TimeInterval = time;
            daqParam = getappdata(0,'daqParam');
            ph = daqParam.PHmeter;
            obj.Instrument = ph;
            
            %create timer
            obj.Timer = timer;
            obj.Timer.StartFcn = @(~,~) disp('Measurement started.');
            obj.Timer.TimerFcn = {@(~,~,obj) obj.getData, obj}; 
            obj.Timer.StopFcn = @(~,~) disp('Measurement stopped.');
            obj.Timer.Period = time;
            obj.Timer.StartDelay = time;
            obj.Timer.ExecutionMode = 'fixedRate';
            
            obj.PointNumber = 1;
            
            obj.Data = NaN(100,2);
           
        end
        
        function startMeasurement(obj)
            %start timer
            start(obj.Timer);
            
            obj.Figure = figure;
            obj.LineHandle = plot(0,0);
            obj.LineHandle.XData = [];
            obj.LineHandle.YData = [];
        end
        
        function getData(obj)
            [pH,cond] = obj.Instrument.getData();
            
            %check that it got a number
            if (isnumeric(cond) && ~isempty(cond))
                time = obj.PointNumber*obj.TimeInterval;
            
                % double matrix size if got two big
                if obj.PointNumber > length(obj.Data)
                    obj.Data = vertcat(obj.Data,NaN(length(obj.Data),2));
                end
            
                %add to data matrices
                obj.Data(obj.PointNumber,1) = time;
                obj.Data(obj.PointNumber,2) = cond;
                
                if mod(obj.PointNumber*obj.TimeInterval,1) == 0
                    %update plot
                    obj.LineHandle.XData = obj.Data(:,1);
                    obj.LineHandle.YData = obj.Data(:,2);
                end
            
                %iterate point number
                obj.PointNumber = obj.PointNumber +1;
            else
                time = obj.PointNumber*obj.TimeInterval;
            
                % double matrix size if got two big
                if obj.PointNumber > length(obj.Data)
                    obj.Data = vertcat(obj.Data,NaN(length(obj.Data),2));
                end
            
                %add to data matrices
                obj.Data(obj.PointNumber,1) = time;
                obj.Data(obj.PointNumber,2) = NaN;
                
                if mod(obj.PointNumber*obj.TimeInterval,1) == 0
                    %update plot
                    obj.LineHandle.XData = obj.Data(:,1);
                    obj.LineHandle.YData = obj.Data(:,2);
                end
            
                %iterate point number
                obj.PointNumber = obj.PointNumber +1;
            end
        end
        

        
        function pauseMeasurement(obj)        
            %stop timer
            stop(obj.Timer);      
        end
        
        function resumeMeasurement(obj)
            %start timer
            start(obj.Timer);  
        end
        
        function stopMeasurement(obj)
            %stop and delete timer
            stop(obj.Timer);
            delete(obj.Timer);
        end
        
        function exportData(obj,name)
            data = obj.Data;
            data(isnan(data(:,1)),:) = [];
            dlmwrite(name,data,'delimiter','\t','newline', 'pc');
        end
            
            
    end
    
end