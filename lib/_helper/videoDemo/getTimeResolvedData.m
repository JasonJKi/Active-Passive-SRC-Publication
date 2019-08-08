function xT = getTimeResolvedData(x, tEnd, window, slideTime, fs, startIndex)

    if nargin < 6
        startIndex = 1;
    end
    xT = zeros([window size(x,2) tEnd]);

    numTimePoints = (tEnd/slideTime);
    tWindow = (0:window-1) + startIndex;
    
    for i = 1:numTimePoints
        slideShift = (slideTime*fs)*i;
        timeIndex = tWindow + slideShift;
        xT(:,:,i) = x(timeIndex,:);
    end
end
