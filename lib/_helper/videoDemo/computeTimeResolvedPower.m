function eegPower = computeTimeResolvedPower(eeg, b, a, fs, windowTime, slideTime)


[numTimeSampleDesired, numElectrodes, nRaces] = size(eeg);
window = fs*windowTime;
tEnd = floor(numTimeSampleDesired/fs - windowTime-1);
numTimePoints = (tEnd/slideTime);
startIndex = 0 ;

for i = 1:nRaces
    iRace = i;
    y = eeg(:,:,iRace);
    yFiltered = filter(b,a,y);
    
    yTFiltered = getTimeResolvedData(yFiltered, tEnd, window, slideTime, fs, startIndex);

    for ii = 1:numElectrodes
        iElectrode = ii;
        for iii = 1:numTimePoints
            iTime = iii;
            yT_ = squeeze(yTFiltered(:, iElectrode, iTime));
            yT_ =  mean(yT_.^2);
            eegPower(iTime,iElectrode,iRace) = yT_;
        end
    
    end

end


