classdef LabJackDev < handle
    properties
        udObj = [];
        handle = [];
    end
    
    methods
        function obj = LabJackDev(IDnum) 
            % Make the UD .NET assembly visible in MATLAB.
            ljasm = NET.addAssembly('LJUDDotNet');
            ljudObj = LabJack.LabJackUD.LJUD;

            
            % Open the LabJack corresponding to the IDnum entered.
            [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB',IDnum, false, 0);
            
            
            obj.udObj = ljudObj;
            obj.handle = ljhandle;
            
            % Start by using the pin_configuration_reset IOType so that all pin
            % assignments are in the factory default condition.
            ljudObj.ePutS(ljhandle, ...
                'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
        end
        
        %function to set digital output to control valve states
        function setState(obj,channel,value)
           %set according to connections, valve 1-4 = 4-7
           channel = channel + 3;
           obj.udObj.eDO(obj.handle,channel,value);
        end
        
        %set the four DO pins for valve control to off
        function initValveControl(obj)
            for i = 1:4
                obj.setState(i,0)
            end
        end
       
        %function to get voltage for LabJack being used as power meter
        function voltage = getReading(obj)
            voltage = 0.0;
            
            % Take a differential measurement from AIN4.
            channelP = 4;
            channelN = 5;
            range = 0;  % Not applicable for the the U3
            resolution = 0;
            settling = 0;
            binary = 0;
            
            %create array to store 20 readings
            tempArray = zeros(20,1);
            for i = 1:20
                %take individual readings
                [~, voltage] = obj.udObj.eAIN(obj.handle, channelP, ...
                    channelN, voltage, range, resolution, settling, binary);
                tempArray(i) = voltage;
            end
            
            %take mean
            voltage = mean(tempArray);
            return
        end
    end
end