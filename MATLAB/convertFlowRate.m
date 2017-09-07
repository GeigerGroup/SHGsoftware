function string = convertFlowRate(speed)
    string = sprintf('%.3e', speed);
    string = strcat(string(1),string(3:5),string(7),string(9));
end