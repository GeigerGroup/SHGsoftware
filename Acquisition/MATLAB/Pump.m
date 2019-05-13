% creates a class for REGLO ICC pump

classdef Pump < handle
    properties
        Serial
        TubeID = '2.29'
    end
    
    methods
        function obj = Pump(COMport)
            if nargin > 0
                if ischar(COMport)
                    %set COMport
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 9600;
                    obj.Serial.StopBits = 1;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open COMport
                    fopen(obj.Serial);
                                      
                    %get flow system to get settings
                    daqParam = getappdata(0,'daqParam');
                    fs = daqParam.FlowSystem;
                    
                    %initialize certain settings
                    for i = 1:4
                        obj.setTubeID(i,obj.TubeID); %set tube ID
                        fprintf(obj.Serial,strcat(num2str(i),'J')); % set rotation to clockwise,
                        fprintf(obj.Serial,strcat(num2str(i),'M')); % set to flowrate
                        obj.setFlowRate(i,20); % flowrate to 20
                    end
                    
                    %set pump in flow system
                    
                    daqParam.FlowSystem.Pump = obj;
                    
                else
                    error('Input COM port must be char');
                end
            end
        end
        

        %tube ID functions
        function setTubeID(obj,channel,ID)
            fprintf(obj.Serial,strcat(num2str(channel),'+',...
                num2str(str2double(ID)*100,'%04.f'))); %set tube ID
        end
        
        function setTubeIDs(obj,ID)
            for i = 1:4
                obj.setTubeID(i,ID)
            end
        end
        
        function getTubeID(obj)
            fread(obj.Serial,obj.Serial.BytesAvailable);%read out any left over characters
            for i = 1:4
                fprintf(obj.Serial,strcat(num2str(i),'+'));
                disp(fscanf(obj.Serial));
            end
        end
        
        %set flow rate function
        function setFlowRate(obj,channel,rate)     
            %convert flow rate to pump format
            string = sprintf('%.3e', rate);
            string = strcat(string(1),string(3:5),string(7),string(9));
            %send to pump
            fprintf(obj.Serial,strcat(num2str(channel),'f',string));
        end
        
        %starting/stopping flow functions
        function startFlow(obj,channel)
            fprintf(obj.Serial,strcat(num2str(channel),'H'));
        end
        
        function stopFlow(obj,channel)
            fprintf(obj.Serial,strcat(num2str(channel),'I'));
        end
        
    end
end