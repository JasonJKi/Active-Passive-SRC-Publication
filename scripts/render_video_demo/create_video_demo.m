% close all; clear all;
rootDir = '../../'; 
load_all_deps(rootDir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set figure inputs and outputs
eegType = 'eeg_jason_'; % specify eeg processing 
eegVersion = 'v1';

stimulusType = 'optical_flow'; % Set specification for stimulus 

leaveOneOutTrain = true;
crossValStatusStr = '';
if leaveOneOutTrain
    crossValStatusStr = '_cross_validated';
end

additionalStr = '_v0';
% additionalStr = ''; 

% load all computed values
computedValuesDir = 'output/computed_values/';
computedValueName = ['cca_analysis_pooled_eeg_jason_'...
                    eegVersion '_svd_reduction_' ...
                    stimulusType '_kx30_ky11' ...
                    crossValStatusStr additionalStr];
computedValuePath = [computedValuesDir computedValueName];
load(computedValuePath, 'input_for_analysis');
h = input_for_analysis.A;
w = input_for_analysis.B;
rxx = input_for_analysis.rxx;
ryy = input_for_analysis.ryy;

% load metadata of experiment conditions
computedValueMetadataPath = [computedValuesDir 'metadata_inputs_for_analysis_final'];
load(computedValueMetadataPath, 'metadata');
conditionStr = {'Active Play','Sham Play','Passive Viewing'};
conditionStrXTick = {'  Active\newline   Play', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};
barColor = [0 1 0; 1 0 0; 0 0 1];
conditionColor = {[1 0 0],[0 0 1], [0 .75 0]};
deceptionColor = {[.1 .1 0], [.6 .45 .6]}; 

% load stimuls and eeg used in analysis
dataDir = 'output/data_processed_for_analysis/';  
load([dataDir eegType eegVersion], 'Eeg'); % [nSamples x nChannels]
load([dataDir stimulusType '_mean_trf'], 'X'); % [nSamples x temporal delay]

locFile = 'JBhead96_sym.loc';
conditionIndex =input_for_analysis.conditionIndex;
indexPlay = find(conditionIndex == 1);
indexBci = find(conditionIndex == 2);
indexWatch = find(conditionIndex == 3);

fs = 30;
windowTime = 5;
slideTime = 1/5; 


%% 1) Align Bci Race 1
ind = indexBci;
Eeg_ = Eeg(ind);
X_ = X(ind);
[eegBci, stimBciTRF] = groupDataByRaceCondition_(Eeg_, X_, 0);
% Compute and draw time-resolved CCA rhos for SRC Illustration for the three race conditions 
[rhoThimeResolvedSRCBci] = computeTimeResolvedCCAForGroup_(eegBci, stimBciTRF, w, h, fs, windowTime, slideTime);

%% 2) Align Watch Race 2
%% Align Bci race 1
ind = indexWatch;
Eeg_ = Eeg(ind);
X_ = X(ind);
[eegWatch, stimWatchTRF] = groupDataByRaceCondition_(Eeg_, X_, 0);
% Compute and draw time-resolved CCA rhos for SRC Illustration for the three race conditions 
[rhoThimeResolvedSRCWatch] = computeTimeResolvedCCAForGroup_(eegWatch, stimWatchTRF, w, h, fs, windowTime, slideTime);

rhoThimeResolvedSRCMeanBci = squeeze(mean(rhoThimeResolvedSRCBci,3));
rhoThimeResolvedSRCMeanWatch = squeeze(mean(rhoThimeResolvedSRCWatch,3));

clear Eeg_ X_
%% 3) Compute and draw time-resolved CCA rhos for SRC Illustration for the three race conditions 
% [b,a] = butter(4, [4 8]/(fs/2),'bandpass'); % drift removal
[b,a] = butter(4, [8 13]/(fs/2),'bandpass'); % drift removal
% [b,a] = butter(4, [13 14.5]/(fs/2),'bandpass'); % drift removal
eegBciPower = computeTimeResolvedPower(eegBci, b, a, fs, windowTime, slideTime);
eegWatchPower = computeTimeResolvedPower(eegWatch, b, a, fs, windowTime, slideTime);

eegBciPowerMean = squeeze(mean(eegBciPower,3));
eegWatchPowerMean = squeeze(mean(eegWatchPower,3));

%% 4) Load Video
% load video
videoFilepath = [rootDir 'data\supertuxkart-active-passive\015\bci\avi\2017-11-29 20-00-39.avi'];
[video, videoGray, RawVideoInfo] = videoToMat(videoFilepath,[],1,'rgb',false);
[videoEpochIndex , durationVideo] = epochRaceTime_(video, RawVideoInfo.FrameRate);
videoEpochIndexBci = videoEpochIndex;
videoBci = video;
videoFilepath = [rootDir 'data\supertuxkart-active-passive\013\watch\avi\2017-11-28 17-33-22.avi'];
[video, videoGray, RawVideoInfo] = videoToMat(videoFilepath,[],1,'rgb',false);
[videoEpochIndex , durationVideo] = epochRaceTime_(video, RawVideoInfo.FrameRate);
videoEpochIndexWatch = videoEpochIndex;
videoWatch = video;
clear video

%% 5) Create\Load Video features
featureFilepath = [rootDir 'data\supertuxkart-active-passive\015\bci\mat\optic_flow_015_bci_02_112917.mat'];
feature = load(featureFilepath);
stimBci = shiftdim(feature.opticFlow, 2);

featureFilepath = [rootDir 'data\supertuxkart-active-passive\013\watch\mat\optic_flow_013_watch_02_112817.mat'];
feature = load(featureFilepath);
stimWatch = shiftdim(feature.opticFlow, 2);
clear feature

draw_video_demo
%% 6) Check that video and video features are properly overlayed Overlay feature with video
% if false
% video = videoBci(videoEpochIndexBci,:,:,:);
% feature = stimBci;
% figure
% 
% for i = 1:600
%     iFrame = i;
%     featureFrame = double(squeeze(feature(iFrame,:,:)));
%     featureFrame(featureFrame<0) = 0;
%     
%     videoFrame = double(squeeze(video(iFrame,:,:,:)));
%     imshow(frameFeatureOverlayed);
%     pause(1/fs)
% end
% 
% video = videoWatch(videoEpochIndexWatch,:,:,:);
% feature = stimWatch;
% figure
% 
% for i = 1:600
%     iFrame = i;
%     featureFrame = double(squeeze(feature(iFrame,:,:)));
%     featureFrame(featureFrame<0) = 0;
%     
%     videoFrame = double(squeeze(video(iFrame,:,:,:)));
% 
%     frameFeatureOverlayed = heatmap_overlay( videoFrame , featureFrame, 'jet');
%     
%     imshow(frameFeatureOverlayed);
%     pause(1/fs)
% end
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
