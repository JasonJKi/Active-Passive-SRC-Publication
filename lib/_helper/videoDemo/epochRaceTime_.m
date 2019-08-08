function [videoEpochIndex , durationVideo] = epochRaceTime_(video, fsVideo)
localizedVideoView = localizeVideoView(video);
localizedVideoViewGrey = squeeze(mean(localizedVideoView,3));
meanVideoFlashEvent = videoMean2(localizedVideoViewGrey);
% Parse the flash events from the video and find the start and
% end index of the flash on screen.
[VideoFlashEvent] = parseVideoFlashEvents(meanVideoFlashEvent,0,0);

figure; clf
hold on;
plot(VideoFlashEvent.flashEvents);
h1 = plot(repmat(VideoFlashEvent.threshold,1,length(meanVideoFlashEvent)));
h2 = plot(VideoFlashEvent.flashFrameIndex,VideoFlashEvent.flashEvents(VideoFlashEvent.flashFrameIndex)','.');
h3 = plot([VideoFlashEvent.startIndex VideoFlashEvent.endIndex],VideoFlashEvent.flashEvents([VideoFlashEvent.startIndex VideoFlashEvent.endIndex]),'*k');
legend([h1 h2 h3],{'cutoff threshold', 'flash occurence' 'start & finish'},'Location','southwest');

videoEpochIndex = VideoFlashEvent.startIndex: VideoFlashEvent.endIndex;
nVideoEpochIndex = length(videoEpochIndex);
durationVideo = nVideoEpochIndex*(1/fsVideo);
end
