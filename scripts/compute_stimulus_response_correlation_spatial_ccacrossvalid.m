%% Stimulus and Neural Response Analysis during Active vs Passive State
% By Jason Ki
close all; clear all
rootDir = '../'
load_all_deps(rootDir)

%% Load Data
computedValueDir = 'output/computed_values/';
dataDir = 'output/data_processed_for_analysis/';  eegType = 'eeg_jason_'; version = 'v1'; 
load([dataDir  eegType version], 'Eeg'); % Eeg{i}(nSamples, nChannels)

% stimulusFileName = 'temporal_contrast_mean_trf.mat';
% stimulusName = 'temporal_contrast';
stimulusName = 'optical_flow_lK';
stimulusFileName = [stimulusName '.mat'];
load([dataDir stimulusFileName], 'X'); % X{i}(nSamples, nChannels)
load([dataDir 'metadata'],  'uniqueConditionIndex', 'conditionIndex') ;

%% Organize the data by conditions
% stimulus = cat(3, Stimulus{:});
stimulus = cat(1, X{:});
stimulus = resizeVideo(stimulus, 1/2);
[nFrames, height, width] = size(stimulus);
stimulus = double(stimulus);
stimulus = reshape(stimulus,[nFrames, height*width]);
eeg =  cat(1, Eeg{:});
eeg(isnan(eeg)) = 0;
nSamples = length(stimulus);

ky = 96;
kx = 240;
% [v, l] = eig(ryy1)
% ky = find(cumsum(diag(l))>0.99,1);
[A, B, rxx, ryy]= canonCorrShrinkageRegularized(stimulus, eeg, kx, ky , false);
MODEL = mTRFtrain(stimulus,eeg,30,1,0,800,.5);
weights = reshape(MODEL, [height, width, 25, 96]);

figure(1)
for i = 1:25
    for ii = 1:96
        imagesc(weights(:,:,i,ii))
        pause(.001)
    end
end
%% Create index to perform leave one out cross validation 
crossValDataSplitRatio = cellfun('length',Eeg);
randomizeIndex = false;
crossValIndex = timeseriesCrossValidation(nSamples,crossValDataSplitRatio, randomizeIndex);

%% Compute canonical correlation 3 conditions of the game play by leave one (race) out cross validation. 
leaveOneOutTrain = false;
numRums = length(Eeg);
rhoAllTest = zeros(numRums, ky);
for iFold = 1:numRums
    disp(iFold);
    trainIndex = find(crossValIndex ~= iFold);  
    testIndex = find(crossValIndex == iFold);  
    
    stimulusTest = stimulus(testIndex,:);
    stimulusTrain = stimulus(trainIndex,:);

    eegTrain = eeg(trainIndex,:);    
    eegTest = eeg(testIndex,:);    
    eegTest(isnan(eegTest)) = 0;
    
    if leaveOneOutTrain    
        [A_, B_, rxx, ryy] = canonCorrShrinkageRegularized(stimulusTrain, eegTrain, kx, ky , false); 
    else        
        A_ = A;
        B_ = B;
    end  

    U = stimulusTest*A_; V = eegTest *B_;
    rhoAllTest(iFold,:) = computeCorrelation(U,V);
end
