%creates a class for photon counter objects to communicate with

classdef PhotonCounter < handle
    properties
        Serial;
        DwellTime;
        Interval;
        %channel enabled hard set here, should be option eventually
        ChannelEnabled = 'B';
    end
    methods
        function obj = PhotonCounter(COMport)
            if nargin > 0
                if ischar(COMport)
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 9600;
                    obj.Serial.StopBits = 2;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open
                    fopen(obj.Serial);
                    
                    %defaultSettings
                    obj.setScanLength(2000)
                    fprintf(obj.Serial,'NE1'); %continous scan
                    
                    %set default dwellTime
                    obj.setDwellTime(obj.DwellTime);
                    
                    %set default Interval
                    obj.setInterval(obj.Interval);
                    
                else
                    error('Input COM port must be char')
                end
            end
        end
        
        %helper functions
        function sendCommand(obj,command)
            fprintf(obj.Serial,command);
        end
        
        function character = channelCharacter(~,channel)
            %channel is 'A','B', or 'T'
            character = [];
            if strcmp(channel,'A')
                character = '0';
            elseif strcmp(channel,'B')
                character = '1';
            elseif strcmp(channel,'T')
                character = '2';
            end
        end
        
        
        %actual functions
        function startScan(obj)
            obj.sendCommand('CS');
        end
        
        function stopScan(obj)
            obj.sendCommand('CH');
        end
        
        function resetScan(obj)
            obj.sendCommand('CR');
        end
        
        function setScanLength(obj,length)
            obj.sendCommand(strcat('NP',num2str(length)));
        end
        
        function setDwellTime(obj,dwellTime)
            obj.sendCommand(strcat('DT',num2str(dwellTime))); %dwell time in seconds
            obj.DwellTime = dwellTime;
        end
        
        function setInterval(obj,interval)
            %in seconds, if timing off 10 Mhz (change 1e7 if otherwise)
            obj.sendCommand(strcat('CP2,',num2str(interval*1e7)));
            obj.Interval = interval;
        end
        
        function setCW(obj,channel)  
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('GM',character,',0'));
        end
        
        function setGated(obj,channel)
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
 
            obj.sendCommand(strcat('GM',character,',1'));
        end
        
        function setGateDelay(obj,channel,delay)
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('GD',character,',',num2str(delay)));
        end
        
        function setGateWidth(obj,channel,width)
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('GW',character,',',num2str(width)));
        end
              
        function setDiscriminatorLevel(obj, channel, level)   
            %channel is 'A','B','T'
            character = obj.channelCharacter(channel);
            
            fprintf(obj.Serial,strcat('DL',character,',',num2str(level)));
        end

        function data = getData(obj)          
            %channel is either A or B
            
            %read out all waiting data if it is there
            if obj.Serial.BytesAvailable
                fread(obj.Serial,obj.Serial.BytesAvailable);
            end
            
            
            %ask if data is ready
            fprintf(obj.Serial,'SS1');
            if str2double(fscanf(obj.Serial))
                fprintf(obj.Serial,strcat('Q',obj.ChannelEnabled)); %ask for data
                data = str2double(fscanf(obj.Serial)); %receive data
            else
                %set data to empty if not ready
                data = [];
            end
        end
            
            
    end
end
