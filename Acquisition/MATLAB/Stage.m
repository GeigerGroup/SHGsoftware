classdef Stage < handle
    %Class to represent translation stage object. Currently use a Standa
    %Stage
    %
    
    properties
        ID
        
        PointsPerPos = 0;
        PosPerScan = 0;
        ScanPositions;
        
        ContMode = false;
        NormalSpeed = 4000;
        ScanSpeed = 1000;
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
            
            %set default speed
            obj.setSpeed(1000);
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
        
        function startContScan(obj)
            %this function starts scan to 99.7 without pausing MATLAB
            %to wait for the end
            position = 99.7;
            steps = int32(position*400);
            
            %set stage speed to scan speed
            obj.setSpeed(obj.ScanSpeed);
            
            %go to the position
            disp(['Going to ' num2str(position) ' mm']);
            
            result = calllib('libximc','command_move', obj.ID, ...
                steps, 0);
            if result ~= 0
                    disp(['Command failed with code', num2str(result)]);
            end
        end
        
        function reachedEnd = checkContScan(obj)
            %this function checks if the scan has reached the end, and if
            %so will stop the acquisition
            
            %derived from standa example matlab code
            dummy_struct = struct('Flags',999);
            parg_struct = libpointer('status_t', dummy_struct);
            
            [result, res_struct] = calllib('libximc','get_status', ...
                obj.ID, parg_struct);
            clear parg_struct
            if result ~= 0
                disp(['Command failed with code', num2str(result)]);
                res_struct = 0;
            end
            
            if res_struct.CurPosition == 39880
                reachedEnd = true;
            else
                reachedEnd = false;
            end
        end
        
        function speed = getSpeed(obj)
            %derived from standa example matlab code
            dummy_struct = struct('Speed',0);
            parg_struct = libpointer('move_settings_t', dummy_struct);
            
            % read current engine settings from motor
            [result, move_settings] = ...
                calllib('libximc','get_move_settings', obj.ID, parg_struct);
            
            clear parg_struct
            if result ~= 0
                disp(['Command failed with code', num2str(result)]);
            end
            speed = move_settings.Speed;        
        end
        
        function setSpeed(obj,speed)
            %max speed is 4000 steps per second
            %we're going to limit to 2000 here
            %default accelaration is 2000 steps/s/s
            %default decelaration is 4000 steps/s/s
            
            %check that its an integer
            if ((floor(speed)~=speed) || ~isnumeric(speed))
                disp('Speed must be integer')
                return
            else
                %check that its in the correct range
                if ((speed < 0) || (speed > 4000))
                    disp('Speed must be between 0 and 2000 steps/s')
                    return
                else
                    %derived from standa example matlab code
                    dummy_struct = struct('Speed',0);
                    parg_struct = libpointer('move_settings_t', dummy_struct);
                    
                    % read current engine settings from motor
                    [result, move_settings] = calllib('libximc','get_move_settings',...
                        obj.ID, parg_struct);
                    
                    clear parg_struct
                    if result ~= 0
                        disp(['Command failed with code', num2str(result)]);
                    end
                    
                    move_settings.Speed = speed;
                    move_settings.uSpeed = 0;
                    
                    % write engine settings to controller
                    result = calllib('libximc', 'set_move_settings', ...
                        obj.ID, move_settings);
                    if result ~= 0
                        disp(['Command failed with code', num2str(result)]);
                    end
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

