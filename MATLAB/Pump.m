% creates a class for REGLO ICC pump

classdef Pump < handle
    properties
        Serial
    end
    
    methods
        function obj = Pump(COMport)
            if nargin > 0
                if ischar(COMport)
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 9600;
                    obj.Serial.StopBits = 1;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open
                    fopen(obj.Serial);
                    
                    
                    %initialize certain settings
                    for i = 1:4
                        fprintf(obj.Serial,strcat(num2str(i),'K')); % set rotation to clockwise,
                        fprintf(obj.Serial,strcat(num2str(i),'M')); %  set to flowrate
                        setFlowRate(obj,i,30); % flowrate to 30
                    end
                else
                    error('Input COM port must be char');
                end
            end
        end
        
        function setFlowRate(obj,channel,rate)
            
            %convert flow rate to pump format
            string = sprintf('%.3e', rate);
            string = strcat(string(1),string(3:5),string(7),string(9));
            
            %send to pump
            fprintf(obj.Serial,strcat(num2str(channel),'f',string));
            
        end
        
        function startFlow(obj,channel)
            fprintf(obj.Serial,strcat(num2str(channel),'H'));
        end
        
        function stopFlow(obj,channel)
            fprintf(obj.Serial,strcat(num2str(channel),'I'));
        end
    end
end




