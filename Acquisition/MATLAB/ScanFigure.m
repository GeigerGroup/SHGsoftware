classdef ScanFigure
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        NumPlots
        DataPointers
    end
    
    methods
        function obj = ScanFigure()
            %create figure
            obj.Figure = figure;
            
            %get parameters
            daqParam = getappdata(0,'daqParam');
            
            %calculate number of plots needed
            %number of plots from photon counter
            multiple = 1;
            if strcmp(daqParam.Channel,'AB')
                multiple = 2;
            end
            %number of plots total
            obj.NumPlots = sum([daqParam.PhotonCounterEnabled*multiple ...
                (daqParam.ContMode == false)]);
            
            %create list of strings to point to data
            obj.DataPointers = cell(obj.NumPlots,1);

            %create each subplot
            for i = 1:obj.NumPlots
                subplot(obj.NumPlots,1,i);
                %create line object with temp point then delete
                linehandle = plot(0,0);
                linehandle.XData = [];
                linehandle.YData = [];
            end

            %index to iterate through  plots
            plotIndex = 1;
            %see what is enabled, and assign string name to point to data
            if daqParam.PhotonCounterEnabled
                if contains(daqParam.Channel,'A')
                    obj.DataPointers{plotIndex} = 'PhotonCounterA';
                    obj.Figure.Children(plotIndex).YLabel.String = 'A Counts';
                    plotIndex = plotIndex + 1;
                end
                if contains(daqParam.Channel,'B')
                    obj.DataPointers{plotIndex} = 'PhotonCounterB';
                    obj.Figure.Children(plotIndex).YLabel.String = 'B Counts';
                    plotIndex = plotIndex + 1;
                end
            end
            
            %stageplots
            if (daqParam.ContMode == false)
                %plot for stage position
                obj.DataPointers{plotIndex} = 'Stage';
                obj.Figure.Children(plotIndex).YLabel.String = 'Stage';
            end
        end
        
        function updatePlots(obj,data)
            for i = 1:obj.NumPlots
                obj.Figure.Children(i).Children.XData = data.Time;
                obj.Figure.Children(i).Children.YData = data.(obj.DataPointers{i});
            end
        end
            
    end
end

