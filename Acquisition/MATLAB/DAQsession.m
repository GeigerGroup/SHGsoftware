% creates a class for custom NIDAQ session

classdef DAQsession < handle
    properties
        Session
        SolStates;
    end
    
    methods
        function obj = DAQsession()     
                %create session
                obj.Session = daq.createSession('ni');
                obj.SolStates = false(1,5);
                
                %assumes first device
                daqs = daq.getDevices();
                devname = daqs(1).ID;
                
                warning('off','daq:Session:onDemandOnlyChannelsAdded');
   
                %add output digital channels, port 0 lines 1 through 5
                addDigitalChannel(obj.Session,devname,'Port0/Line1:5','OutputOnly');
                obj.Session.outputSingleScan(obj.SolStates); % set all to zero
                disp('Added NIDAQ session for solenoid control')
        end
        
        function setValveStates(obj,states)
            obj.SolStates = states;
            obj.Session.outputSingleScan(obj.SolStates);
            disp('Valve States:')
            disp(states)
        end
        
        function setValveState(obj,channel,state)
            obj.SolStates(channel) = state;
            obj.Session.outputSingleScan(obj.SolStates);
        end
    end
end