function checkAcquisition

global autoPause pointNumber scanLength

pointNumber = pointNumber + 1;

if autoPause
    if pointNumber == autoPause
        pauseAcquisition();
    end
end

display(pointNumber)

if pointNumber == scanLength
    stopAcquisition();
end
end
