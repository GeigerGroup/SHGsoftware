classdef AcqData
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Time
        PhotonCounterA
        PhotonCounterB
        PowerADC
        pH
        Cond
        Solution
    end
    
    methods
        function obj = AcqData()
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
            if ~isempty(obj.PowerADC)
                str = strcat(str,'\t',num2str(obj.PowerADC(end)));
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
            %then adc data
            if daqParam.PowerADCEnabled
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
            string = strcat(string,'\r\n');
        end
    end
                
end

