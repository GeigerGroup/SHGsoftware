classdef DAQfigure
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        NumPlots
        DataPointers
    end
    
    methods
        function obj = DAQfigure()
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
                daqParam.ADCpowerEnabled daqParam.PHmeterEnabled*2 ...
                daqParam.FlowControl daqParam.StageControlEnabled]);
            
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
            
            %adc plot for power data
            if daqParam.ADCpowerEnabled
                obj.DataPointers{plotIndex} = 'ADCpower';
                obj.Figure.Children(plotIndex).YLabel.String = 'Power';
                plotIndex = plotIndex + 1;
            end
            
            %pH plots
            if daqParam.PHmeterEnabled
                %plot for pH data
                obj.DataPointers{plotIndex} = 'pH';
                obj.Figure.Children(plotIndex).YLabel.String = 'pH';
                plotIndex = plotIndex + 1;
                
                %plot for cond data
                obj.DataPointers{plotIndex} = 'Cond';
                obj.Figure.Children(plotIndex).YLabel.String = 'Cond';
            end
            
            %flow control solution plot
            if daqParam.FlowControl
                obj.DataPointers{plotIndex} = 'Solution';
                obj.Figure.Children(plotIndex).YLabel.String = 'Solution';
                plotIndex = plotIndex + 1;
            end
            
            %stageplots
            if daqParam.StageControlEnabled
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
        
        function string = createHeader(obj)
            %creates header based on the plots included in the figure
            %get parameters
            daqParam = getappdata(0,'daqParam');
            
            %create header according to which data will be recorded
            %start with photon counter data
            string = 'time';
            if contains(daqParam.Channel,'A')
                string = strcat(string,'\tcountsA');
            end
            if contains(daqParam.Channel,'B')
                string = strcat(string,'\tcountsB');
            end
            %then adc data
            if daqParam.ADCpowerEnabled
                string = strcat(string,'\tpower');
            end
            %then pH data
            if daqParam.PHmeterEnabled
                string = strcat(string,'\tcond','\tpH');
            end
            %then target concentration
            if daqParam.FlowControl
                string = strcat(string,'\tsolution');
            end
            %then stage position
            if daqParam.StageControlEnabled
                string = strcat(string,'\tstage');
            end
            string = strcat(string,'\r\n');
        end
            
    end
end

