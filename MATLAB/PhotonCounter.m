%creates a class for photon counter objects to communicate with

classdef PhotonCounter < handle
    properties
        Serial
        DwellTime;
        Interval;
        %channel enabled hard set here, should be option eventually
        ChannelEnabled = 'A';
    end
    methods
        function obj = PhotonCounter(COMport)
            if nargin > 0
                if ischar(COMport)
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 19200;
                    obj.Serial.StopBits = 2;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open
                    fopen(obj.Serial)
                    
                    %set default dwellTime
                    obj.setDwellTime(obj.DwellTime);
                    
                    %set default Interval
                    obj.setInterval(obj.Interval);
                    
                else
                    error('Input COM port must be char')
                end
            end
        end
        
        function startScan(obj)
            fprintf(obj.Serial,'CS');
        end
        
        function stopScan(obj)
            fprintf(obj.Serial,'CH');
        end
        
        function resetScan(obj)
            fprintf(obj.Serial,'CR');
        end
        
        function data = getData(obj)          
            %channel is either A or B
            
            %check if data is ready
            fprintf(obj.Serial,'SS1');
            if str2num(fscanf(obj.Serial)); %test on status byte
                fprintf(obj.Serial,strcat('Q',obj.ChannelEnabled)); %ask for data
                data = str2num(fscanf(obj.Serial)); %receive data
            else
                data = [];
                display('Error: no data ready') %if data is not ready
            end
        end
        
        function setDwellTime(obj,dwellTime)
            fprintf(obj.Serial,strcat('DT',num2str(dwellTime))); %dwell time in seconds
            obj.DwellTime = dwellTime;
        end
        
        function setInterval(obj,interval)
            %in seconds, if timing off 10 Mhz (change 1e7 if otherwise)
            fprintf(obj.Serial,strcat('CP2,',num2str(interval*1e7)));
            obj.Interval = interval
        end
            
            
    end
end
