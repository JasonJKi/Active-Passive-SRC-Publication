close all; clear all;
rootDir = '../';
load_all_deps(rootDir);

% specify eeg processing 
eegType = 'eeg_jason_'; 
eegVersion = 'v7';

% Set specification for stimulus 
stimulusType = 'optical_flow'

leaveOneOutTrain = true;
if leaveOneOutTrain; crossValStatusStr = '_cross_validated';else; crossValStatusStr = '';end

additionalStr = '_v0';
% additionalStr = '';
% load all computed values
computedValueName = ['cca_analysis_pooled_eeg_jason_v1_svd_reduction_' stimulusType '_kx30_ky11' crossValStatusStr additionalStr]
computedValuesDir = 'output/computed_values/';
% computedValueName = ['cca_analysis_pooled_eeg_jason_v1_svd_reduction_' stimulusType '_kx30_ky11_cross_validated_v0'];
computedValuePath = [computedValuesDir computedValueName];
load(computedValuePath, 'input_for_analysis');
dataDir = 'output/data_processed_for_analysis/';  
load([dataDir 'metadata'],  'uniqueConditionIndex', 'conditionIndex') ;

% load metadata of experiment conditions
computedValueMetadataPath = [computedValuesDir 'metadata_inputs_for_analysis_final'];
load(computedValueMetadataPath, 'metadata');
input_for_analysis.metadata = metadata;

% load stimuls and eeg used in analysis
dataDir = 'output/data_processed_for_analysis/';  
load([dataDir eegType eegVersion], 'Eeg'); % [nSamples x nChannels]
load([dataDir 'optical_flow_mean_trf'], 'X'); % [nSamples x temporal delay]
%%  Organize the data by conditions
%  stimulus = cat(3, Stimulus{:});
stimulus = cat(1, X{:});
stimulus = double(stimulus(:,:,1));
eeg =  cat(1, Eeg{:});
nSamples = length(stimulus);

ky = 11;
kx = 30;
A = input_for_analysis.A;
B = input_for_analysis.B;
% % [v, l] = eig(ryy1)
% % ky = find(cumsum(diag(l))>0.99,1);
% [A, B, rxx, ryy]= canonCorrShrinkageRegularized(stimulus, eeg, kx, ky , false);

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
asdf = sortRhosByCondition(rhoAllTest, uniqueConditionIndex, conditionIndex);
sum(asdf.rho - input_for_analysis.rho,2)