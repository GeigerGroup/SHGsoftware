classdef ScanData
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Time
        PhotonCounterA
        PhotonCounterB
        Stage
    end
    
    methods
        function obj = ScanData()
        end
        
        function str = getLastDataString(obj)

            %first column is time
            str = num2str(obj.Time(end));

            %photon counter data
            if ~isempty(obj.PhotonCounterA)
                str = strcat(str,'\t',num2str(obj.PhotonCounterA(end)));
            end
            if ~isempty(obj.PhotonCounterB)
                str = strcat(str,'\t',num2str(obj.PhotonCounterB(end)));
            end
            %then stage position
            if ~isempty(obj.Stage)
                str = strcat(str,'\t',num2str(obj.Stage(end)));
            end

            str = strcat(str,'\r\n');
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
            %then stage position
            if (daqParam.ContMode == false)
                string = strcat(string,'\tstage');
            end
            string = strcat(string,'\r\n');
        end
    end
                
end

