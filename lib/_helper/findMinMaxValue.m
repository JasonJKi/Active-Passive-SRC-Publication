function [minVal, maxVal, absMax] = findMinMaxValue(val,n)
minVal = 0;
maxVal = 0;
for i = 1:n
    x = val(i,:);
    currentMinVal = min(x);
    currentMaxVal = max(x);
    currentMinVal = round(currentMinVal,1);
    currentMaxVal = round(currentMaxVal,1);
    
    if currentMaxVal > maxVal
        maxVal = currentMaxVal;
    end
    
    if currentMinVal < minVal
        minVal = currentMinVal;
    end
    
    absMax = max(abs(maxVal),(minVal));
end