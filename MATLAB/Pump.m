% creates a class for REGLO ICC pump

classdef Pump < handle
    properties
        Serial
        Mode = true; %true is salt mode, false is pH mode
        Concentrations = [0 0 0 0]; %one must hold water or most dilute sol
        Reservoirs = [true true true true];
        TotalFlow = 30;
        TubeID = '3.17';
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
                                      
                    %initialize certain settings
                    for i = 1:4
                        fprintf(obj.Serial,strcat(num2str(i),'J')); % set rotation to clockwise,
                        fprintf(obj.Serial,strcat(num2str(i),'M')); % set to flowrate
                        setFlowRate(obj,i,30); % flowrate to 30
                    end
                else
                    error('Input COM port must be char');
                end
            end
        end
        
        function rates = calculateRates(obj,conc)
            
            res = [];
            %if reservoir 2 is enabled
            if obj.Reservoirs(2)
                % if concentratrion <= reservoir 2, choose it
                if conc <= obj.Concentrations(2)
                    res = 2;
                elseif obj.Reservoirs(3)
                    %if concentration <= reservoir3, choose it
                    if conc <= obj.Concentrations(3)
                        res = 3;
                    elseif obj.Reservoirs(4)
                        if conc <= obj.Concentrations(4)
                            res = 4;
                        else
                            display('Concentration too high for res 4')
                        end
                    else
                        display('Concentration too high for res 3')
                    end
                else
                    display('Concentration too high for res 2')
                end
            else
                display('Only one reservoir available?')
            end
            
            if isempty(res)
                display('No flowrates found')
            else
                display(res)
            end
        end
        rates = res;                
                

        
%         function rates = calculateSalt2Reservoir(obj,conc)
%             coefConc = [obj.cWater obj.cConc; 1 1]; %matrix for conc
%             coefDil = [obj.cWater obj.cDil; 1 1]; %matrix for dil
%             
%             solMatrix = [obj.fTotal*conc; obj.fTotal]; %matrix for solutions
%             
%             flowConc = inv(coefConc)*solMatrix; %rates if conc works
%             flowDil = inv(coefDil)*solMatrix; %rates if diluted works
%             
%             %min with 3.17 ID tubing is 0.35 mL/min
%             flowConcCheck = ((flowConc < 0.35)|(flowConc > 30)) & (flowConc ~= 0);
%             flowDilCheck = ((flowDil < 0.35)|(flowDil > 30)) & (flowDil ~= 0);
%             
%             rates = [0 0 0 0]; %matrix to hold final rates
%             
%             if sum(flowConcCheck) == 0 %check if conc works
%                 rates(1) = flowConc(1);
%                 rates(2) = flowConc(2);
%             elseif sum(flowDilCheck) == 0  %check if diluted works
%                 rates(1) = flowDil(1);
%                 rates(3) = flowDil(2);
%             else
%                 rates = [];
%                 disp('Flow settings out of bounds'); %display if neither works
%             end
%         end
        
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
        
        
        function setFlowRates(obj,rates)      
            %get daqParam
            daqParam = getappdata(0,'daqParam');
            daqParam.PumpStates = rates;
            
            for i = 1:4
                %set flow rate
                obj.setFlowRate(i,rates(i));
                
                %update GUI if open
                pumpGUI = getappdata(0,'pumpGUI');
                if ~isempty(pumpGUI)
                    pumpGUI.Children(i).String = num2str(rates(i));
                end
            end 
        end
        
        function startFlows(obj)
            for i = 1:4
                obj.startFlow(i);
            end
        end
        
        function stopFlows(obj)
            for i = 1:4
                obj.stopFlow(i);
            end
        end
        
    end
end





