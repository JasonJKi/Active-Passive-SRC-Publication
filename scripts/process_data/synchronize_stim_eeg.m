clear all; close all; clf
rootDir = '../';
load_all_deps(rootDir); % Load dependencies for processing of stim and eeg, and computing cca.

% Get metadata table for all SuperTuxkart races to easily load in video
% and eeg data for processing.
dataDir = 'data/supertuxkart-active-passive/'
metadataPath  = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataPath);
nRaces = height(metadataTable); % total number of races recorded.

%% Static strings for file names and filepath designations.
% File types for loading and saving.
aviStr = 'avi'; % All videos are screen captured using OBS Studio at 30 fps 
                % and display monitor's aspect ratio of 16:9 and 720p (1280x720 px)
                % All captured videos were downsized and stored as avi 
                % format using HD Video Converter Factory Pro (Wonderfox
                % Inc.) to 320x180px.
xdfStr = 'xdf'; % EEG was recorded using BrainVision Series ActiChamp and the
                % data was collected using a third party software,
                % labstreaminglayer.
matStr = 'mat'; % All processed data will be output as .mat format

% Gameplay conditions.
conditionStrs = {
    'play'
    'bci'
    'watch'
    };

%% Processing streamline for EEG and Video all races.
for iRace = 1:nRaces
    
    % Assign filename and run type designation from the metadata table.
    % Assign xdf file path to read from.
    xdfDir = metadataTable.xdfFileDir{iRace};
    xdfFileName = metadataTable.xdfFileName{iRace};
    xdfFilePath = [rootDir dataDir xdfDir xdfFileName];

    % Assign video file path to read from.
    vidDir = metadataTable.vidDir{iRace};
    vidFileName = metadataTable.vidFileName{iRace};
    vidFilePath = [rootDir dataDir vidDir vidFileName];
    
    % Assign mat file path to output the epoched streams.
    matFileDir = metadataTable.matFileDir{iRace};
    matFileName = metadataTable.matFileName{iRace};
    matFilePath = [rootDir dataDir matFileDir matFileName];
    
    % Get race information and assign num and string variables.
    fileIDNum = metadataTable.fileID(iRace); 
    trialNum = metadataTable.trial(iRace);
    subjectNum = metadataTable.subject(iRace);
    subjectNumStr = num2str(subjectNum);
    trialNumStr = num2str(trialNum);
    fileIDNumStr = num2str(fileIDNum);
    dateStr = metadataTable.date{iRace};
    dateNum = str2double(dateStr);
    conditionStr = metadataTable.condition{iRace}; 
    trialStr = num2str(trialNum);

    %% 1a. Load in and process screen captured videos of the races.
    % VideoToMat converts raw video file to mat format file.
    resizeScale = .5; % Resize video according to the scale. 
    videoFormat = aviStr; % Define video format
    disp(['File ID: ' fileIDNumStr '. processing subject ' subjectNumStr ' ' conditionStr ' ' trialNumStr])
    disp(['Reading Video from: ' vidFilePath])
    [video, videoGray, RawVideoInfo] = videoToMat(vidFilePath,[],resizeScale,videoFormat);
    fsVideo = double(int16(RawVideoInfo.FrameRate));
    disp('Video successfully converted to mat')
    % video - is converted to rgb to gray scale.
    
    %% 1b. Epoch video from the flash occurences on screen.
    % Localize the video view to isolate the flash events in the
    % video and compute the mean of the flash events efficiently
    % using videoMean2.
    localizedVideoView = localizeVideoView(video);    
    localizedVideoViewGrey = squeeze(mean(localizedVideoView,3));
    meanVideoFlashEvent = videoMean2(localizedVideoViewGrey);
    
    % Parse the flash events from the video and find the start and
    % end index of the flash on screen.
    [VideoFlashEvent] = parseVideoFlashEvents(meanVideoFlashEvent,0,0);
    
    % Epoch Video
    videoEpochIndex = VideoFlashEvent.startIndex: VideoFlashEvent.endIndex;
    nVideoEpochIndex = length(videoEpochIndex);
    durationVideo = nVideoEpochIndex*(1/fsVideo);

    % Plot flash trigger for the video and stream for debugging
    % purpose.
    figure(iRace);clf;
    subplot(2,1,1)
    hold on;
    plot(VideoFlashEvent.flashEvents);
    h1 = plot(repmat(VideoFlashEvent.threshold,1,length(meanVideoFlashEvent)));
    h2 = plot(VideoFlashEvent.flashFrameIndex,VideoFlashEvent.flashEvents(VideoFlashEvent.flashFrameIndex)','.');
    h3 = plot([VideoFlashEvent.startIndex VideoFlashEvent.endIndex],VideoFlashEvent.flashEvents([VideoFlashEvent.startIndex VideoFlashEvent.endIndex]),'*k');
    legend([h1 h2 h3],{'cutoff threshold', 'flash occurence' 'start & finish'},'Location','southwest');
    title(['video: run #' fileIDNumStr ' ' subjectNumStr ' ' conditionStr ...
        ' ' trialNumStr ' n=(' num2str(VideoFlashEvent.nFlash) ') duration: ' num2str(durationVideo) 's'])
    pause(.01)

    %% 2a. Load in EEG and photodiode triggers from LSL.
    % Load xdf file to streams
    disp(['Loading LSL streams from: ' xdfFilePath])
    [streams,fileheader] = load_xdf(xdfFilePath);
    nStreams = length(streams);
 
    % Sort and assign streams
    disp('Following streams found:')
    for i = 1:nStreams
        streamName = streams{i}.info.name;
        stream = streams{i}.time_series';
        timestamp = streams{i}.time_stamps';
        disp(['    ' streamName])
        switch streamName
            case 'OBS Studio'
                Obs.timeseries = single(stream);
                Obs.timestamp = timestamp;
            case 'BrainAmpSeries'
                Eeg.timeseries = single(stream);
                Eeg.timestamp = timestamp;
            case 'BrainAmpSeries-Markers'
                Photodiode.timeseries = str2num(cell2mat(stream));
                Photodiode.timestamp = timestamp;
            case 'Keyboard'
                Keyboard.data = stream;
                Keyboard.timestamp = timestamp;
            case 'EyeLink'
                Eyelink.data = stream;
                Eyelink.timestamp = timestamp;
            otherwise
                continue
        end
    end
    
   %% 2b. Epoch eeg from the flash occurences recorded by phtodiode.
    % Figure out time of on-screen flashes from the photodiode
    trigger = Photodiode.timeseries;
    triggerTimestamp = Photodiode.timestamp;
    eventCodes=unique(trigger);
    flashEventCode=max(eventCodes);
    nFlashEventCode=length(eventCodes);
    
    if nFlashEventCode > 1
        disp('Epoching Flash Event From the photodioderiggers. on and off event')
        [flashIndices, startTime, endTime, nFlash, startIndex, endIndex] = ...
            parsePhotodiodeFlashEvents(trigger,flashEventCode,triggerTimestamp);
        
        subplot(2,1,2);hold on
        p1 = plot(trigger,'b','DisplayName',''); % plot all events
        p2 = plot(flashIndices,trigger(flashIndices),'g.');
        p3 = plot([startIndex endIndex],trigger([startIndex endIndex]),'k*');
    elseif nFlashEventCode == 1
        disp('Epoching Flash Event From the photodioderiggers. single event')
        lengthFlashTimestamp = length(triggerTimestamp);
        flashIndices = find(diff(triggerTimestamp) > .2)+1';
        if flashIndices(1) ~= 1;
            flashIndices = [1;  flashIndices];
        end
        onset_event_stamp=triggerTimestamp(flashIndices);
        triggerN=triggerTimestamp(flashIndices(end));
        triggerNMinus1=triggerTimestamp(flashIndices(end-1));
        triggerTimeDiff= mean(diff(onset_event_stamp))
        if abs((triggerTimeDiff - (triggerN - triggerNMinus1))) > triggerTimeDiff
            flashIndices(end) = [];
        end
        nFlash=length(flashIndices);
        subplot(2,1,2);hold on;
        plot(triggerTimestamp,'b')
        plot(flashIndices,triggerTimestamp(flashIndices),'r.')
    end
    pause(.01)

    %% cut up the EEG based on first and last triggers   
    flashEventTimestamp = triggerTimestamp(flashIndices);    
    startTime = flashEventTimestamp(1);
    endTime = flashEventTimestamp(end);
    durationEeg = endTime - startTime;
    eegEpochIndex = epochTimestamp(Eeg.timestamp,startTime,endTime);

    plotTitleStr = [fileIDNumStr ' ' subjectNumStr ' ' conditionStr ' ' trialNumStr];
    title(['photodiode: run #' plotTitleStr ' n=(' num2str(nFlash) ') duration ' num2str(durationEeg) 's'])
    figureName = ['output/figures/trigger/run_' fileIDNumStr '_' subjectNumStr '_' conditionStr '_' trialNumStr '.png'];
    saveas(figure(iRace),figureName)
   
    eegEpoched = Eeg.timeseries(eegEpochIndex,:);
    fsEeg = 5000;
    
    %% resample the eeg to the frame rate of the video
    eegEpochedDownsampled = resample(double(eegEpoched),fsVideo,fsEeg);
    nEEGresamplesKept = size(eegEpochedDownsampled,1);
    fsEegNew = fsVideo;

    %% logic bit to make the stim and eeg same length
    if nEEGresamplesKept > nVideoEpochIndex
        nSamplesToRemove = nEEGresamplesKept - nVideoEpochIndex;
        eegEpochedDownsampled = eegEpochedDownsampled(1:end-nSamplesToRemove,:);
    elseif nEEGresamplesKept < nVideoEpochIndex
        nSamplesToRemove = nVideoEpochIndex - nEEGresamplesKept;
        videoEpochIndex = videoEpochIndex(1:end - nSamplesToRemove);
    else
        % lengths match
    end
    
    %% Save synchronized EEG and Video
    videoEpoched = video(:,:,:,videoEpochIndex);
    save([rootDir dataDir matFileDir 'epoched_video_' matFileName ],'videoEpoched','RawVideoInfo','fsVideo','videoEpochIndex')
    save([rootDir dataDir matFileDir 'epoched_eeg_' matFileName ],'eegEpochedDownsampled','fsEegNew','durationEeg','eegEpochIndex')

%     %% 3. Compute video features.
%     [height,width,nChannels,nSamples] = size(videoEpoched);
%     videoGrayEpoched = videoGray(:,:,videoEpochIndex);
%     % Compute 2d optic flow. 
%     poolKernelSize = 2; % size of pooling kernel for dim reduction.
%     videoFeature = computeVideoFeature(@opticFlow, videoGrayEpoched, poolKernelSize)
%     opticFlow = videoOpticFlow(videoGrayEpoched, poolKernelSize);
%     save([matFileDir 'optic_flow_' matFileName],'opticFlow','durationVideo','fsVideo')
      
%     % Compute temporal contrast.
%     temporalContrast = diff(videoGrayEpoched,1,3);
%     zeroPaddingFirstFrame = zeros(height,width,1);
%     temporalContrast = cat(3,zeroPaddingFirstFrame,temporalContrast);
%     save([matFileDir 'temporal_contrast_' matFileName],'temporalContrast','durationVideo','fsVideo')

%     % Compute local contrast.
%     localContrast = videoLocalContrast(videoGrayEpoched);
%     save([matFileDir 'local_contrast_' matFileName],'localContrast','durationVideo','fsVideo')
end


