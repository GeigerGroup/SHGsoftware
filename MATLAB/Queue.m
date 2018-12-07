classdef Queue < handle
    %object to hold a set number of acquisition names and times to run at
    
    properties
        QueueName
        Names
        Times
        TimerObjs
    end
    
    methods
        function obj = Queue(name)
            obj.QueueName = name;
            %construct a blank queue. 
            obj.Names = {};
            obj.Times = {};
            obj.TimerObjs = {};
        end
        
        %add a certain number of acquisitions with basename, at the
        %timeinterval in minutes
        function addSequential(obj,basename,number, timeinterval)
            present = datevec(now);
            %first one starts in 1 minute
            obj.addEvent(strcat(basename,num2str(1)),present + [0 0 0 0 1 0]);
            %then all the rest start in intervals after that
            for i = 2:number
                obj.addEvent(strcat(basename,num2str(i)),present+[0 0 0 0 1+timeinterval*i 0])
            end
        end
        
        function addEvent(obj,name,time)
            %add an acquisition name and time to run
            obj.Names{end+1} = name;
            obj.Times{end+1} = time;
        end
        
        function start(obj)
            %write to file
            fileID = fopen(strcat(obj.QueueName,'QueueData.txt'),'w');
            fprintf(fileID,strcat('Queue Data for:',obj.QueueName,'\r'));
            for i = 1:length(obj.Names)
                str = [obj.Names{i} ' programmed for ' datestr(obj.Times{i}) '\r'];
                fprintf(fileID,str);
            end
            fclose(fileID);
            
            %go through each name/time pairing in queue, create timer to
            %trigger them
            for i=1:length(obj.Names)
                %create timer, set it to trigger from times
                t = timer;
                t.TimerFcn = {@(~,~) Acquisition(obj.Names{i})};
                startat(t,obj.Times{i})
                obj.TimerObjs{i} = t;
                str = [obj.Names{i} ' programmed for ' datestr(obj.Times{i})];
                disp(str);
            end
        end
        
        function deleteAll(obj)
            %delete each timer
            for i = 1:length(obj.TimerObjs)
                delete(obj.TimerObjs{i})
            end
        end
    end
end

