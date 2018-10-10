classdef DAQdata
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Time
        PhotonCounterA
        PhotonCounterB
        ADCpower
        pH
        Cond
        Solution
        Stage
    end
    
    methods
        function obj = DAQdata()
        end
        
        function str = getLastDataString(obj)
            %first column is time
            str = num2str(obj.Time(end));
            
            % then photon counter data
            if ~isempty(obj.PhotonCounterA)
                str = strcat(str,'\t',num2str(obj.PhotonCounterA(end)));
            end
            if ~isempty(obj.PhotonCounterB)
                str = strcat(str,'\t',num2str(obj.PhotonCounterB(end)));
            end
            
            %then adc data
            if ~isempty(obj.ADCpower)
                str = strcat(str,'\t',num2str(obj.ADCpower(end)));
            end
            
            %then pH meter data
            if ~isempty(obj.pH)
                str = strcat(str,'\t',num2str(obj.pH(end)));
            end
            if ~isempty(obj.Cond)
                str = strcat(str,'\t',num2str(obj.Cond(end)));
            end
            
            %then flow control value
            if ~isempty(obj.Solution)
                str = strcat(str,'\t',num2str(obj.Solution(end)));
            end
            
            %then stage position
            if ~isempty(obj.Stage)
                str = strcat(str,'\t',num2str(obj.Stage(end)));
            end
            str = strcat(str,'\r\n');
        end
    end
                
end

