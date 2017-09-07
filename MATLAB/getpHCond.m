function [pH, cond] = getpHCond

%get serial port
serialpHmeter = getappdata(0,'serialpHmeter');

%read out all waiting data to be sure its clear
if serialpHmeter.BytesAvailable
    fread(serialpHmeter, serialpHmeter.BytesAvailable);
end

%send command
fprintf(serialpHmeter,'GETMEAS');
out = fscanf(serialpHmeter); %echo of GETMEAS
out = fscanf(serialpHmeter); %empty - echo of read command?

% get actual string
string = fscanf(serialpHmeter);
split = strsplit(string,','); %split it

pH = split{9}; %pick out pH
cond = split{20}; % pick out cond

end

