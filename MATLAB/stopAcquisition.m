function stopAcquisition

t = getappdata(0,'timer');
stop(t);
delete(t);

end