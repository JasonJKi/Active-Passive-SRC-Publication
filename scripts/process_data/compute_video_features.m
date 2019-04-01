clear all; 
rootDir = '../../';
load_all_deps(rootDir); %load dependencies for the ARL project

dataDir = 'data/supertuxkart-active-passive/';
metadataTablePath = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataTablePath);
[nFiles, nVariables] = size(metadataTable);

outputDataDir = 'output/data_processed_for_analysis/';

%% videoFeatureExtractor.add(VideoFeatureMethod(MethodParameters)); Implement Video Feature Extraction Methods
videoFeatureExtractor = VideoFeatureExtractor(); % VideoFeatureExtractor object allows computing of multiple features at once.
resizeImage(videoFeatureExtractor,1/2)

% add feature extraction methods to the VideoFeatureExtractor
add(videoFeatureExtractor, OpticalFlow()); 
add(videoFeatureExtractor, OpticalFlow(opticalFlowHS())); 
add(videoFeatureExtractor, OpticalFlow(opticalFlowLK()));
add(videoFeatureExtractor, OpticalFlow(opticalFlowLKDoG()));
add(videoFeatureExtractor, ImageContrast(.1));
add(videoFeatureExtractor, TemporalContrast());
add(videoFeatureExtractor, DKLColor());
add(videoFeatureExtractor, ImageIntensity());
add(videoFeatureExtractor, Luminance());
add(videoFeatureExtractor, ImageOrientation([0 45 90 135]));
add(videoFeatureExtractor, ImageMotion([0 45 90 135]));
add(videoFeatureExtractor, VisualSalience(GBVSParams()));
add(videoFeatureExtractor, VisualSalience(IttiKochParams()));

%% loop through all the videos from supertuxkart dataset and compute video feature
indexRaceID = [1:74 104:139];
for iFile = indexRaceID
    
    % Get video metadata & Load file from specified path 
    fileDir = metadataTable.matFileDir{iFile};
    fileNamePrefix = 'epoched_video_';
    fileName = [fileNamePrefix metadataTable.matFileName{iFile}];
    inputFilePath = [rootDir dataDir fileDir fileName];
    disp(['loading video for feature extraction ' inputFilePath]);
    data = load(inputFilePath);
    
    % Execute all the methods that were added to the feature extractor.
    fs = data.fs;
    video = data.video;
    
    Features = compute(videoFeatureExtractor, video);

    for iFeature = 1:videoFeatureExtractor.numAddedMethods
        X = Features{iFeature}.Features;
        methodName = Features{iFeature}.methodName;
        extractionMethod = videoFeatureExtractor.addedMethods{iFeature};
        outputFilePath = [rootDir dataDir fileDir methodName fileName(14:end)];
        save(outputFilePath, 'X', 'fs', 'extractionMethod')
        disp(['saving ' methodName]);
        clear X
    end
        
    iter = iter + 1;    
    clear Features
end
