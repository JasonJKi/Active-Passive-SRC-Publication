clear all; 
rootDir = '../';
load_all_deps(rootDir); %load dependencies for the ARL project

dataDir = 'data/supertuxkart-active-passive/';
metadataTablePath = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataTablePath);
[nFiles, nVariables] = size(metadataTable);

outputDataDir = 'output/data_processed_for_analysis/';

availableFeatureExtractor = {
%     'optical_flow_old_vision_tb_hs', ...
%     'optical_flow_hs', ...
%     'optical_flow_lK', ...
%     'optical_flow_lkdog' ...
%     'optical_flow_original', ...
%     'temporal_contrast', ...
%     'luminance', ...
    'gbvs', ...
%     'pca'
    };


videoMatFilePath ='../data/supertuxkart-active-passive/013/play/mat/epoched_video_013_play_01_112817.mat';
data = load(videoMatFilePath,'videoEpoched','fsVideo');
fs = data.fsVideo;
video = data.videoEpoched;
%% videoFeatureExtractor.add(VideoFeatureMethod(MethodParameters)); Implement Video Feature Extraction Methods
videoFeatureExtractor = VideoFeatureExtractor(); % VideoFeatureExtractor object allows computing of multiple features at once.
videoFeatureExtractor.resizeImage(1.5) % Resizes images prior to processing
videoFeatureExtractor.add(ImageContrast());

% videoFeatureExtractor.add(ImageOrientation([0 45 90 135]))
% videoFeatureExtractor.add(ImageMotion([0 45 90 135]));


% % add feature extraction methods to the VideoFeatureExtractor
% videoFeatureExtractor
% videoFeatureExtractor.add(TemporalContrast());
videoFeatureExtractor.add(ImageContrast(.1));
% videoFeatureExtractor.add(OpticalFlow()); 
% videoFeatureExtractor.add(OpticalFlow(opticalFlowHS())); 
% videoFeatureExtractor.add(OpticalFlow(opticalFlowLK()));
% videoFeatureExtractor.add(OpticalFlow(opticalFlowLKDoG()));

% videoFeatureExtractor.add(ImageOrientation([0 45 90 135]));
% videoFeatureExtractor.add(DKLColor());
% videoFeatureExtractor.add(ImageIntensity());
% videoFeatureExtractor.add(Luminance());
gbvsParam = makeGBVSParams;
image_1 = double(imresize(video(:,:,:,500),1.5));
image_2 = double(imresize(video(:,:,:,501),1.5));
image_1_gray = rgbIntensity(image_1);
image_2_gray = rgbIntensity(image_2);
gbvs_1 = gbvs(image_1,gbvsParam);
% image_contrast_1 = R_contrast(gbvsParam, image_1_gray);
image_contrast_1 = myContrast( image_1_gray , round(size(image_1_gray,1) * .1) );
imagesc(image_contrast_1);
% videoFeatureExtractor.add(VisualSalience(makeGBVSParams()));
tic 
Features = compute(videoFeatureExtractor, video);
toc
previewVideos(Features{1}.Features)