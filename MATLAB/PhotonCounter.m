%creates a class for photon counter objects to communicate with

classdef PhotonCounter < handle
    properties
        Serial;
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
                    obj.sendCommand('NE1'); %continous scan
                    
                    daqParam = getappdata(0,'daqParam');
                    %set default dwellTime
                    obj.setDwellTime(daqParam.DwellTime);
                    
                    %set default Interval
                    obj.setInterval(daqParam.Interval);
                    
                else
                    error('Input COM port must be char')
                end
            end
        end
        
        %scan functions
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
            
            daqParam = getappdata(0,'daqParam');
            daqParam.DwellTime = dwellTime;
        end
        
        function setInterval(obj,interval)
            %in seconds, if timing off 10 Mhz (change 1e7 if otherwise)
            obj.sendCommand(strcat('CP2,',num2str(interval*1e7)));
            
            daqParam = getappdata(0,'daqParam');
            daqParam.Interval = interval;
        end
        
        
        %gating functions
        function setGateMode(obj,channel,mode)  
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
            
            %mode is 'CW', 'FIXED', or 'SCAN'
            characterM = [];
            if strcmp(mode,'CW')
                characterM = '0';
            elseif strcmp(mode,'FIXED')
                characterM = '1';
            elseif strcmp(mode,'SCAN')
                characterM = '2';
            end
            
            %send command
            obj.sendCommand(strcat('GM',character,',',characterM));
        end
        
        function setGateDelayScanStep(obj,channel,step)
            %channel is 'A','B'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('GY',character,',',num2str(step)));
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
        
        %counting functions
        function setDiscriminatorLevel(obj, channel, level)   
            %channel is 'A','B','T'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('DL',character,',',num2str(level)));
        end
        
        function setInput(obj,channel,input)
            %channel is 'A','B','T'
            character = obj.channelCharacter(channel);
            
            obj.sendCommand(strcat('CI',character,',',num2str(input)));
        end
            
        
        %acquisition functions
        function [dataA,dataB] = getData(obj)          
            %get data from both A and B
            
            %read out all waiting data if it is there
            if obj.Serial.BytesAvailable
                fread(obj.Serial,obj.Serial.BytesAvailable);
            end
            
            %ask if data is ready
            fprintf(obj.Serial,'SS1');
            if str2double(fscanf(obj.Serial))
                obj.sendCommand('QA'); %ask for dataA
                dataA = str2double(fscanf(obj.Serial)); %receive dataA
                obj.sendCommand('QB'); %ask for dataB
                dataB = str2double(fscanf(obj.Serial)); %receive dataB
            else
                %set data to empty if not ready
                dataA = [];
                dataB = [];
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
        
    end
end
