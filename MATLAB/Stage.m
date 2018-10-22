classdef Stage < handle
    %Class to represent translation stage object. Currently use a Standa
    %Stage
    %
    
    properties
        ID
        PointsPerPos = 0;
        PosPerScan = 0;
        
        PeakFind = false;
        PeakFindActive = false;
        ScanPositions;
    end 
    
    methods
        function obj = Stage()
            % if library isn't loaded, load it
            if not(libisloaded('libximc'))
                disp('Loading library...')
                [notfound,warnings] = loadlibrary('libximc.dll', @ximcm);
                disp(notfound);
                disp(warnings);
            end
            
            %search for devices, if more than one may need more complicated
            %hints/probes, may choose which device to select
            dev_enum = calllib('libximc', 'enumerate_devices', 1,'');
            dev_name = calllib('libximc','get_device_name',dev_enum,0);
            calllib('libximc','free_enumerate_devices', dev_enum);
            if ~isempty(dev_name)
                disp(['Found stage named: ' dev_name]);
            else
                disp('No stages found.');
                return
            end
            
            %open device
            obj.ID = calllib('libximc','open_device', dev_name);
        end
        
        function goTo(obj,position)
            %put position in mm into steps
            if (position > 99.7 || position < 0)
                disp('Position out of range')
                return
            else
                steps = int32(position*400);
                
                %go to the position
                disp(['Going to ' num2str(position) ' mm']);
                result = calllib('libximc','command_move', obj.ID, ...
                    steps, 0);
                if result ~= 0
                    disp(['Command failed with code', num2str(result)]);
                end
                
                %wait to reach it
                disp('Waiting to reach position...');
                result = calllib('libximc','command_wait_for_stop', obj.ID, 10);
                if result ~= 0
                    disp(['Command failed with code', num2str(result)]);
                end
            end
        end
        
        function fineStagePos = calculateFineStagePos(~,data)
            %get daqParam
            daqParam = getappdata(0,'daqParam');
            
            %interval of autopause
            interval = daqParam.Stage.PointsPerPos;
            %calculate stage positions, average of counts
            pos = mean(reshape(data.Stage,...
                [interval,length(data.Stage)/interval]))';
            counts = mean(reshape(data.PhotonCounterA,...
                [interval,length(data.PhotonCounterA)/interval]))';

            %fit it with sine function with offset            
            ft = fittype('a*sin(b*x+c)+d');
            %init guesses
            aGuess = (max(counts)-min(counts))/2;
            bGuess = 0.05;
            cGuess = 0;
            dGuess = mean(counts);
            
            fo = fitoptions(ft);
            fo.StartPoint = [aGuess,bGuess,cGuess,dGuess];
            fo.Lower = [0,0.02,-2*pi,0];
            fo.Upper = [100000,0.1,2*pi,200000];
            
            %fit data to sin
            sinfit = fit(pos,counts,ft,fo)
            figure
            plot(sinfit,pos,counts)
            
            %evaluate fit over 1000 points in stage position
            fineX = linspace(0,99.7,1000)';
            fineYfit = feval(sinfit,fineX);
            
            %positive peak
            [~,posloc] = findpeaks(fineYfit);
            %if there is no positive peak take points at two edges of stage
            if isempty(posloc)
                fineStagePos = [95.7 91.7 8 4 0]';
            else
                fineStagePos = findPositions(fineX(posloc));
            end
            
            %negative positions
            [~,negloc] = findpeaks(-fineYfit);
            %if there is no negative peak take points at two edges of stage
            if isempty(negloc)
                fineStagePos = vertcat(fineStagePos,[95.7 91.7 8 4 0]');
            else
                fineStagePos = vertcat(fineStagePos,findPositions(fineX(negloc)));
            end
            
            %put it in descending order
            fineStagePos = sort(fineStagePos,1,'descend');
            
            
            %function to find points around center
            function positions = findPositions(centerPos)
                %create 9 points, centered around center position
                positions = [-8 -4 0 4 8]' + centerPos;
                if min(positions) < 0
                    %if any are below zero, move to edge
                    positions = positions - min(positions);
                elseif max(positions) > 99.7
                    %if any are above 99.7, move to edge
                    positions = positions - (max(positions)-99.7);
                end
            end
        end
        
        function close(obj)
            device_id_ptr = libpointer('int32Ptr', obj.ID);
            calllib('libximc','close_device', device_id_ptr);
            disp('Stage closed.')
        end
    end
end

