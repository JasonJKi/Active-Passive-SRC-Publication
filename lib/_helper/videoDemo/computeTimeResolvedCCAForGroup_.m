function [rhoThimeResolved] = computeTimeResolvedCCAForGroup_(eeg, stim, w, h, fs, windowTime, slideTime)


[numTimeSampleDesired, ~, nRaces] = size(eeg);
window = fs*windowTime;
tEnd = floor(numTimeSampleDesired/fs - windowTime-1);
numTimePoints = (tEnd/slideTime);
startIndex = 0 ;
padding = fs * 2;
for iRace = 1:nRaces
    
    
    y = eeg(:,:,iRace);
    x = stim(:,:,iRace);
      
    x = x*h;
    y = y*w;
    
    xT = getTimeResolvedData(x, tEnd, window, slideTime, fs, startIndex);
    yT = getTimeResolvedData(y, tEnd, window, slideTime, fs, startIndex);
    
  
    
    for iTime = 1:numTimePoints
        xT_ = xT(:,:,iTime);
        yT_ = yT(:,:,iTime);
        rhoThimeResolved(iTime,:,iRace) = computeCorrelation(xT_, yT_);
    end
end
end
