classdef LabJackADC < handle
    properties
        dev = [];
        handle = [];
    end
    
    methods
        function obj = LabJackADC()
            
            % Make the UD .NET assembly visible in MATLAB.
            ljasm = NET.addAssembly('LJUDDotNet');
            ljudObj = LabJack.LabJackUD.LJUD;
            
            
            % Read and display the UD version.
            disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())]);
            
            % Open the first found LabJack U3.
            [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', ...
                'LJ_ctUSB', '0', true, 0);
            
            obj.dev = ljudObj;
            obj.handle = ljhandle;
            
            % Start by using the pin_configuration_reset IOType so that all pin
            % assignments are in the factory default condition.
            ljudObj.ePutS(ljhandle, ...
                'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
        end
        
        %set labjack to be ADC
        function setAsADC()
            
        end
        
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
                [~, voltage] = obj.dev.eAIN(obj.handle, channelP, ...
                    channelN, voltage, range, resolution, settling, binary);
                tempArray(i) = voltage;
            end
            
            %take mean
            voltage = mean(tempArray);
            return
        end
        
        %set labjack to be valve control
        function setAsValveControl()
            
        end
        

    end
end