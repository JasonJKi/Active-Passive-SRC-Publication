function imageFrame = stimulusFeatureOverlay(imageFrame, featureFrame)
%% overlay video feature on top of the frame
featureFrame(featureFrame<0) = 0;

frameFeatureOverlayed = heatmap_overlay(imageFrame ,featureFrame, 'jet');

imageFrame = uint8(myRescale(frameFeatureOverlayed,0,255));



