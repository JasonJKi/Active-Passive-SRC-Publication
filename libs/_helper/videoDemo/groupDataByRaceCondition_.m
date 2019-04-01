function [eeg, stim] = groupDataByRaceCondition_(Eeg, X, biggerGroup)

numTimeSamplesAll = cellfun('length',X);
idx = kmeans(numTimeSamplesAll',2);
grp1 = find(idx==1);
grp2 = find(idx==2);


if biggerGroup
    if mean(numTimeSamplesAll(grp1)) < mean(numTimeSamplesAll(grp2))
        grp = grp2;
    else
        grp = grp1;
    end
else
    if mean(numTimeSamplesAll(grp1)) > mean(numTimeSamplesAll(grp2))
        grp = grp2;
    else
        grp = grp1;
    end
    
end
numTimeSampleDesired = mode(numTimeSamplesAll(grp));

Eeg = Eeg(grp);
X = X(grp);
for i = 1:length(X)    
    eeg_ = double(Eeg{i});
    eeg_(isnan(eeg_)) = 0;
    stim_ = double(X{i});
    numTimeSample = length(stim_);
    
    if numTimeSample ~= numTimeSampleDesired
        p = numTimeSampleDesired;
        q = numTimeSample;
        eeg_ = resample(eeg_,numTimeSampleDesired,numTimeSample);
        stim_ = resample(stim_,numTimeSampleDesired,numTimeSample);
    end

    eeg(:,:,i) = eeg_;
    stim(:,:,i) = stim_;
end
