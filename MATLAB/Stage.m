classdef Stage < handle
    %Class to represent translation stage object. Currently use a Standa
    %Stage
    %
    
    properties
        ID
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
        
        function goHome(obj) 
            %go home
            disp('Going home...')
            result = calllib('libximc', 'command_home', obj.ID);
            if result ~= 0
                disp(['Command failed with code', num2str(result)]);
            end
            
            %wait until it has stopped to return control
            result = calllib('libximc','command_wait_for_stop', obj.ID, 10);
            if result ~= 0
                disp(['Command failed with code', num2str(result)]);
            end
        end
        
        function close(obj)
            device_id_ptr = libpointer('int32Ptr', obj.ID);
            calllib('libximc','close_device', device_id_ptr);
            disp('Stage closed.')
        end
    end
end

