classdef Queue < handle
    %object to hold a set number of acquisition names and times to run at
    
    properties
        Names
        Times
        TimerObjs
    end
    
    methods
        function obj = Queue()
            %construct a blank queue. 
            obj.Names = {};
            obj.Times = {};
            obj.TimerObjs = {};

        end
        
        function addEvent(obj,name,time)
            %add an acquisition name and time to run
            obj.Names{end+1} = name;
            obj.Times{end+1} = time;
            
        end
        
        function start(obj)
            %go through each name/time pairing in queue
            for i=1:length(obj.Names)
                createAcqTimer(i)
            end
           
            function createAcqTimer(index)
                %initialize acquisition with name
                acq = Acquisition(obj.Names{index});
                %create timer, set it to trigger from times
                t = timer;
                t.TimerFcn = {@(~,~,acq) acq.startAcquisition, acq};
                startat(t,obj.Times{index})
                obj.TimerObjs{index} = t;
                str = [obj.Names{index} ' programmed for ' datestr(obj.Times{index})];
                disp(str);
            end
        end
        
        function delete(obj)
            %delete each timer
            for i = 1:length(obj.TimerObjs)
                delete(obj.TimerObjs{i})
            end
        end
    end
end

