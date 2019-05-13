classdef FlowSystem < handle
    %object to represent flow system, which includes a pump and may or may
    %not include a valve system
    
    properties
        Pump
        Valve
        ValveStates = [false false false false];
        
        Mode = true; %true is salt mode, false is pH mode
        Concentrations = [0 0 0 0]; %one must hold water or most dilute sol
        Reservoirs = [true true true true];
        TotalFlow = 10;
        FlowRates = [10 10 10 10];
        TargetConc = 0;
    end
    
    methods
        %initialize empty flow system
        function obj = FlowSystem()
        end
        
        %set valve state
        function setValveState(obj,channel,value)
            %set state
            obj.Valve.setState(channel,value)
            %store state
            obj.ValveStates(channel) = value;
        end
        
        %set a flow rate, can be for one channel or multiple if you pass in
        %arrays of channels and rates
        function setFlowRate(obj,channel,rate)
            for i = 1:length(channel)
                %set rate
                obj.Pump.setFlowRate(channel(i),rate(i))
                %store rate
                obj.FlowRates(channel(i)) = rate(i);
            end
        end
        
        %start flow in channels, can be for one channel or multiple if you
        %pass in array of channel numbers
        function startFlow(obj,channel)
            for i = 1:length(channel)
                if obj.FlowRates(i) > 0
                    if ~isempty(obj.Valve)
                        obj.setValveState(channel(i),1)
                    end
                    obj.Pump.startFlow(channel(i))
                end
            end
        end
        
        %stop flow in channels, can be for one channel or multiple if you
        %pass in array of channel numbers
        function stopFlow(obj,channel)
            for i = 1:length(channel)
                obj.Pump.stopFlow(channel(i))
                if ~isempty(obj.Valve)
                    obj.setValveState(channel(i),0)
                end
            end
        end
        
        %terrible function to calculate rates based on concentrations, 
        %should rewrite
        function rates = calculateRates(obj,conc)       
            %select which reservoir to mix to get value
            res = [];
            
            %salt mode
            if obj.Mode == true
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
            if obj.Mode == false
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
            if strcmp(obj.Pump.TubeID,'3.17')
                flowMin = 0.35;
                flowMax = 35;
            elseif strcmp(obj.Pump.TubeID,'2.29')
                flowMin = 0.24;
                flowMax = 24;
            elseif strcmp(obj.Pump.TubeID,'0.76')
                flowMin = 0.036;
                flowMax = 3.6;
            elseif strcmp(obj.Pump.TubeID,'0.64')
                flowMin = 0.026;
                flowMax = 2.6;
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
        
    end
    
    
end

