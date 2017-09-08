% creates a class for pH meter object

classdef PHmeter < handle
    properties
        Serial
    end
    methods
        function obj = PHmeter(COMport)
            if nargin > 0
                if ischar(COMport)
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 9600;
                    obj.Serial.StopBits = 1;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open
                    fopen(obj.Serial)
                else
                    error('Input COM port must be char')
                end
            end
        end
        
        function [pH, cond] = getData(obj)
            %read out all waiting data if it is there
            if obj.Serial.BytesAvailable
                fread(obj.Serial,obj.Serial.BytesAvailable);
            end
            
            %send command
            fprintf(obj.Serial,'GETMEAS');
            out = fscanf(obj.Serial); % echo of GETMEAS
            out = fscanf(obj.Serial); % empty - clean up?
            
            % get actual string
            string = fscanf(obj.Serial);
            split = strsplit(string,','); % split it
            
            pH = str2num(split{9}); % pick out pH
            cond = str2num(split{20}); % pick out cond
        end
    end
end
