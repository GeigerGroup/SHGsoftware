function giveChannelCommand(channel,command)

serialPump = getappdata(0,'serialPump');
fprintf(serialPump,strcat(num2str(channel),command));

end
