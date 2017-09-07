%creates a class for photon counter objects to communicate with

classdef PhotonCounter
    properties
        Serial
    end
    methods
        function obj = PhotonCounter(COMport)
            if nargin > 0
                if ischar(COMport)
                    obj.Serial = serial(COMport);
                    obj.Serial.BaudRate = 19200;
                    obj.Serial.StopBits = 2;
                    obj.Serial.DataBits = 8;
                    obj.Serial.Terminator = 'CR';
                    
                    %open
                    fopen(obj.Serial)
                    
                else
                    error('Input COM port must be char')
                end
            end
        end
        
        function startScan(obj)
            fprintf(obj.Serial,'CS');
        end
        
        function stopScan(obj)
            fprintf(obj.Serial,'CH');
        end
    end
end
