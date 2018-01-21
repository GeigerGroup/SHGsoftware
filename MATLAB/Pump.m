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
                   
            %select which reservoir to mix to get value
            res = [];
            
            %salt mode
            if obj.Mode == true;
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
                                disp('Concentration too high for res 4')
                            end
                        else
                            disp('Concentration too high for res 3')
                        end
                    else
                        disp('Concentration too high for res 2')
                    end
                else
                    disp('Only one reservoir available?')
                end

                if isempty(res)
                    disp('No flowrates found')
                    rates = [];
                    return
                end

                concMatrix = [obj.Concentrations(1) obj.Concentrations(res); 1 1];
                solMatrix = [obj.TotalFlow*conc; obj.TotalFlow];

                flowMatrix = inv(concMatrix)*solMatrix; %calculate rates
            end
            
            %pH mode, can only go one direction from 7
            if obj.Mode == false;
                %if reservoir 2 is enabled
                if obj.Reservoirs(2)
                    % if pH is closer to 7 than reservoir 2, choose it
                    if abs(conc-7) <= abs(obj.Concentrations(2)-7)
                        res = 2;
                    elseif obj.Reservoirs(3)
                        %if pH is closer to 7 than reservoir 3, choose it
                        if abs(conc-7) <= abs(obj.Concentrations(3)-7)
                            res = 3;
                        elseif obj.Reservoirs(4)
                            if abs(conc-7) <= abs(obj.Concentrations(4)-7)
                                res = 4;
                            else
                                disp('pH too far from 7 for res 4')
                            end
                        else
                            disp('pH too far from 7 for res 4')
                        end
                    else
                        disp('pH too far from 7 for res 4')
                    end
                else
                    disp('Only one reservoir available?')
                end

                if isempty(res)
                    disp('No flowrates found')
                    rates = [];
                    return
                end
                
                % if pH 7, only flow first reservoir
                if conc == 7
                    flowMatrix = [obj.TotalFlow 0 0 0];
                end
                        
                % if going up 
                if conc > 7
                    concOHres = 10^-(14-obj.Concentrations(res));
                    concOHwant = 10^-(14-conc);
                    
                    concMatrix = [0 concOHres; 1 1];
                    solMatrix = [obj.TotalFlow*concOHwant; obj.TotalFlow];
                    
                    flowMatrix = inv(concMatrix)*solMatrix; %calculate rates
                    flowMatrix = round(flowMatrix,4); %round to four decimal places
                end
                
                % if going down
                if conc < 7
                    concHres = 10^-obj.Concentrations(res);
                    concHwant = 10^-conc;
                    
                    concMatrix = [0 concHres; 1 1];
                    solMatrix = [obj.TotalFlow*concHwant; obj.TotalFlow];
                    
                    flowMatrix = inv(concMatrix)*solMatrix; %calculate rates
                    flowMatrix = round(flowMatrix,4);
                end

                
            end

            
            disp(conc)
            
            %check rates
            if strcmp(obj.TubeID,'3.17')
                flowMin = 0.35;
                flowMax = 35;
            elseif strcmp(obj.TubeID,'0.76')
                flowMin = 0.036;
                flowMax = 3.6;
            end
            
            flowCheck = ((flowMatrix < flowMin)|(flowMatrix > flowMax)) & (flowMatrix ~= 0);
            
            
            rates = [0 0 0 0];
            
            if sum(flowCheck) == 0
                rates(1) = flowMatrix(1);
                rates(res) = flowMatrix(2);
            else
                rates = [];
                disp('Flow settings out of bounds')
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





