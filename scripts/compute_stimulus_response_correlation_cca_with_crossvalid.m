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
stimulusName = 'temporal_contrast';
% stimulusName = 'optical_flow';
stimulusFileName = [stimulusName '_mean_trf.mat'];
load([dataDir stimulusFileName], 'X'); % X{i}(nSamples, nChannels)
load([dataDir 'metadata'],  'uniqueConditionIndex', 'conditionIndex') ;

%%  Organize the data by conditions
%  stimulus = cat(3, Stimulus{:});
stimulus = cat(1, X{:});
stimulus = double(stimulus(:,:,1));
eeg =  cat(1, Eeg{:});
nSamples = length(stimulus);

ky = 11;
kx = 11;
% [v, l] = eig(ryy1)
% ky = find(cumsum(diag(l))>0.99,1);
[A, B, rxx, ryy]= canonCorrShrinkageRegularized(stimulus, eeg, kx, ky , false);

%% Create index to perform leave one out cross validation 
crossValDataSplitRatio = cellfun('length',Eeg);
randomizeIndex = false;
crossValIndex = timeseriesCrossValidation(nSamples,crossValDataSplitRatio, randomizeIndex);

%% Compute canonical correlation 3 conditions of the game play by leave one (race) out cross validation. 
leaveOneOutTrain = true;
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

%% Generate surrogate data to create confidence interval of rhos on the trained CCA components 
nSurrogates = 1000;
surrogateIndex = 1:round(nSamples/30);
eegSurrogate = eeg(surrogateIndex,:);
eegSurrogate(isnan(eegSurrogate)) = 0;
eegSurrogate = generateSurrogateDataSet(eegSurrogate, nSurrogates);
stimulusSurrogate = generateSurrogateDataSet(stimulus(surrogateIndex,:), nSurrogates);
rhoSurrogate = bootstrapCorrelationDistribution(eegSurrogate,B,stimulusSurrogate,A);
% load([computedValueDir 'surrogate_rhos_' stimulusName], 'rhoAllSurrogate1'); % [height x width x nSamples]

%% Save Computed Values
input_for_analysis = sortRhosByCondition(rhoAllTest, uniqueConditionIndex, conditionIndex);
input_for_analysis.A = A;
input_for_analysis.B = B;
input_for_analysis.rxx = rxx;
input_for_analysis.ryy = ryy;
input_for_analysis.rhoSurrogate = rhoSurrogate;

crossValStatusStr = '';
if leaveOneOutTrain; crossValStatusStr = '_cross_validated';end
computedValuePath1 = [computedValueDir 'cca_analysis_pooled_' eegType version '_svd_reduction_' stimulusName '_kx' num2str(kx) '_ky' num2str(ky) crossValStatusStr];
save(computedValuePath1, 'input_for_analysis', 'rhoAllTest', 'conditionIndex', 'uniqueConditionIndex')

