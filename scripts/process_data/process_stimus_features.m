clear all; 
rootDir = '../../';

dataDir = 'data/supertuxkart-active-passive/';
metadataTablePath = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataTablePath);
[nFiles, nVariables] = size(metadataTable);

outputDataDir = 'output/data_processed_for_analysis/';
% extractionMethod = OpticalFlow();
% extractionMethod = OpticalFlow(opticalFlowHS());
% extractionMethod = OpticalFlow(opticalFlowLK());
% extractionMethod = OpticalFlow(opticalFlowLKDoG());
% extractionMethod = ImageContrast(.1);
% extractionMethod = TemporalContrast();
% extractionMethod = DKLColor();
% extractionMethod = ImageIntensity();
% extractionMethod = ImageMotion([0 45 90 135]);
% extractionMethod = ImageOrientation([0 45 90 135]);
% extractionMethod = VisualSalience(GBVSParams());
% extractionMethod = VisualSalience(IttiKochParams());
visualSalience = VisualSalience(IttiKochParams());
stimulusFeature = ([0 45 90 135]);
preview = true;
%% loop through all the videos from supertuxkart dataset and compute video feature
indexRaceID = [1:74 104:139];
iter = 1;
kernelSize = [5 5]
for iFile = indexRaceID
    methodName = visualSalience.methodName;
    % Get video metadata & Load file from specified path 
    fileDir = metadataTable.matFileDir{iFile};
    fileName = [methodName '_' metadataTable.matFileName{iFile}];
    visualSalienceFilePath = [rootDir dataDir fileDir fileName];
    disp(['loading: ' fileName])
    data = load(visualSalienceFilePath, 'X', 'fs');
    fs = data.fs;

    height = 80;
    width = 45;
    videoSalienceMap = data.X{1};  
    thresholdPercentiles = [10, 25, 50, 75, 90, 95, 99]; 
    tic
    for ii = 1:5        
        videoSalientAreaIndex(:,:,:,ii) = extractVisuallySalientAreaVideo(videoSalienceMap, [height, width], thresholdPercentiles(ii));
    end
    toc
    
    X{iter} = videoSalientAreaIndex;
    clear videoSalientAreaIndex
    iter  =  iter + 1;
end
stimulusForAnalysisPath = [outputDataDir stimulusFeatureType  methodName '_index'];
save(stimulusForAnalysisPath, 'X', 'fs')
return


for iFile = indexRaceID
    % Get video metadata & Load file from specified path 
    fileDir = metadataTable.matFileDir{iFile};
    fileName = [stimulusFeature.methodName '_' metadataTable.matFileName{iFile}];
    stimulusFeatureFilePath = [rootDir dataDir fileDir fileName];
    disp(['loading video features for processing: ' stimulusFeatureFilePath]);
    data = load(stimulusFeatureFilePath, 'X', 'fs');
    XIn = data.X;
    
    numFeatures = length(XIn);
    for iFeature = 1:numFeatures
        x = double(XIn{iFeature});
%         previewFrames(x,500);
        numParams = size(x,4);
        for iParam = 1:numParams          
            video = x(:,:,:,iParam);
            tic
            videoPooled = resizeVideo(video,1/2);
%             videoPooled = videoPool(video,kernelSize);
             toc
             xOut(:,:,:,iParam) = videoPooled;
            
%             videoResized = resizeVideo(videoPooled,5);
%             videoMean = videoMean2(video);
%             videoMeanPooled = videoMean2(videoPooled);
%             videoMeanNorm = zscore(videoMean); % normalize
%             videoMeanNormPooled = zscore(videoMeanPooled); % normalize
%             plot([videoMeanNorm,videoMeanNormPooled])
%             legend('norm', 'norm pooled')
%             previewFrames({video, videoResized},250)
%             xOut(:,:,iParam) = videoTRF(videoPooled, fs);

        end
        XOut{iter,iFeature} = single(xOut);
        clear xOut
    end
    iter = iter + 1;
end

numOutFeatures = size(XOut,2);
for iFeature = 1:numOutFeatures
    X = XOut(:,iFeature);
    featureTypeOutputName = extractionMethod.outputNames{iFeature};
    featureType = ['_' featureTypeOutputName];
    if strcmp(featureTypeOutputName, '')
        featureType = '';
    end
    stimulusForAnalysisPath = [outputDataDir stimulusFeatureType  featureType '_pooled'];
    save(stimulusForAnalysisPath, 'X', 'fs')
end
