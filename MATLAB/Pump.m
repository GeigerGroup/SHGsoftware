% creates a class for REGLO ICC pump

classdef Pump < handle
    properties
        Serial
        cWater = 0; %conc of water
        cConc = 0.1; %conc of concentrated reservoir
        cDil = 0.001; %conc of dilute reservoir
        fTotal = 30; %total flow rate
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
                        fprintf(obj.Serial,strcat(num2str(i),'M')); % set to flowrate
                        setFlowRate(obj,i,30); % flowrate to 30
                    end
                else
                    error('Input COM port must be char');
                end
            end
        end
        
        function calculateSalt2Reservoir(obj,conc)
            coefConc = [obj.cWater obj.cConc; 1 1]; %matrix for conc
            coefDil = [obj.cWater obj.cDil; 1 1]; %matrix for dil
            
            solMatrix = [ojb.fTotal*conc; obj.fTotal]; %matrix for solutions
            
            flowConc = inv(coefConc)*solMatrix; %rates if conc works
            flowDil = inv(coefDil)*solMatrix; %rates if diluted works
            
            %min with 3.17 ID tubing is 0.35 mL/min
            flowConcCheck = ((flowConc < 0.35)|(flowConc > 30)) & (flowConc ~= 0);
            flowDilCheck = ((flowDil < 0.35)|(flowDil > 30)) & (flowDil ~= 0);
            
            finalFlowRates = [0; 0; 0; 0]; %matrix to hold final rates
            
            if sum(flowConcCheck) == 0 %check if conc works
                finalFlowRates(1) = flowConc(1);
                finalFlowRates(2) = flowConc(2);
            elseif sum(flowDilCheck) == 0  %check if diluted works
                finalFlowRates(1) = flowDil(1);
                finalFlowRates(3) = flowDil(2);
            else
                disp('Flow settings out of bounds'); %display if neither works
            end
            
            display(finalFlowRates)
            
            for i = 1:4
                obj.setFlowRate(i,finalFlowRates(i));
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





