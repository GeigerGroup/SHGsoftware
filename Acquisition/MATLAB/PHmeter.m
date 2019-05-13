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
                    obj.Serial.TimeOut = 0.1;
                    
                    %open
                    fopen(obj.Serial);
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
            
            if strfind(out,'GETMEAS')
                out = fscanf(obj.Serial); % empty - clean up?
                
                % get actual string
                string = fscanf(obj.Serial);
                out = fscanf(obj.Serial); % empty - clean up?
                if ~isempty(string)
                    split = strsplit(string,','); % split it
                    
                    %make sure its the proper length
                    if (length(split) == 33)
                        
                        pH = str2double(split{9}); % pick out pH
                        cond = str2double(split{20}); % pick out cond
                    
                        if strcmp(split{21},'mS/cm') %put in microS/cm if in mS
                            cond = cond*1000;
                        end
                    else
                        pH = [];
                        cond = [];
                        disp('pH cond string not correct length.')
                    end
                else
                    pH = [];
                    cond = [];
                end
                
            else
                display('no pH data')
                pH = [];
                cond = [];  
            end
        end
    end
end
