function getData()

global waveName ...
    photonCounter recordA recordB ...
    pHmeter pH cond ...
    measurePower NIDAQ EPM

display('Getting Data');

if photonCounter
    if checkPCdataReady()
        if recordA
            appendDataPC('A',waveName)
        end
        if recordB
            appendDataPC('B',waveName)
        end
    end
end

if pHmeter
    if cond
        appendCondData()
    end
    if pH
        appendpHData()
    end
end

if measurePower
    if NIDAQ
        getNIDAQdata()
    end
    if EPM
        getEPMdata()
    end
end

checkAcquisition();


end