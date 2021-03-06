% This script analyzes preprocessing pipeline for eeg for most optimal and robust eeg signal.
% metadata for input data
rootDir = '../../';

dataDir = 'data/supertuxkart-active-passive/';
metadataTablePath  = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataTablePath);
[nRaces, nVariables] = size(metadataTable);

locFilename = 'JBhead96_sym.loc';
outFileEegName = 'eeg_jason_v1';
outputDataDir = 'output/data_processed_for_analysis/';

% EEG processing/ filtering logic
eyeArtifactRemovalStatus = true;
fs = 30;
if eyeArtifactRemovalStatus
    virtualeog=zeros(96,4);
    virtualeog([1 34],1)=1;
    virtualeog([2 35],2)=1;
    virtualeog(1,3)=1;
    virtualeog(2,3)=-1;
    virtualeog(33,4)=1;
    virtualeog(36,4)=-1;
end

nanBadChannelRejectionStatus = true;
nanBadSampleRejectionStatus = true;
rpcaStatus = true;

methods.nanBadChannelRejectionStatus = true;
methods.nanBadSampleRejectionStatus = true;
methods.rpcaStatus = true;
methods.eyeArtifactRemovalStatus = true;
methods.driftFilterStatus = true;

draw = false;
%% Step 1 - zero mean, drift filter and eyemovement regression on every run.
indexRaceID = [1:74 104:139];
iter = 1; 
Eeg = {};
for iRace = indexRaceID
    fileNamePrefix = 'epoched_eeg_';
    % Set and input and output path.
    matFileDir = metadataTable.matFileDir{iRace};
    matFileName = metadataTable.matFileName{iRace};
    matFilePath = [rootDir dataDir matFileDir fileNamePrefix matFileName];
    
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
    
    nameRaceStr = [fileIDNumStr '_' subjectNumStr '_' conditionStr '_' trialNumStr];

    % Load in the file.
    disp(['loading eeg for processing ' matFilePath]);
    eegMatStr = 'eegEpochedDownsampled'; 
    load(matFilePath, eegMatStr, 'fsEegNew');
    eval(['eeg = ' eegMatStr ';']);
    fs = fsEegNew; % sampling rate
    
    % Get dimension information for eeg.
    [nSamples, nChannels] = size(eeg);
    
    % High pass and 60hz bandstop line noise 
    eegFiltered = filterEeg(eeg,fs);
    eegProcessed = eegFiltered;
    
    % RPCA
    if rpcaStatus
        eegRPCA = inexact_alm_rpca(eegProcessed);
        eegProcessed = eegRPCA;
    end
    
    %     eegOffset1 = eegProcessed - repmat(eegProcessed(1,:),namples,1);

    % Mean subtraction
    eegOffset = eegProcessed - repmat(mean(eegProcessed,2),1,nChannels);
    eegProcessed = eegOffset;

    if eyeArtifactRemovalStatus
        % Remove eyemovement artefact
        eogVirtual = eegOffset*virtualeog;
        eegEyemovementRegressed = regressOut(eegProcessed',eogVirtual')';
        eegProcessed = eegEyemovementRegressed;
    end
    
    if nanBadSampleRejectionStatus
        % Remove samples based on the standard deviation of the sample across time.
        [eegBadSamplesRemoved, mask1] = removeTimeSeriesArtifact(eegProcessed, 5, 4 , fs);    
        eegProcessed = eegBadSamplesRemoved;
    end
    
    if nanBadChannelRejectionStatus
        % Remove samples based on the standard deviation of the sample across channels.
        [eegBadChannelsRemoved, mask2] = removeSpatialArtifact(eegBadSamplesRemoved, 3);
        eegProcessed = eegBadChannelsRemoved;
    end
    
    if draw
        % Draw plots of eeg before and after the artefact rejection and save.
        figA = figure('Position', get(0, 'Screensize'));
        subplot(2,1,1); imagesc(eegEyemovementRegressed'); caxis([-100 100]); title('before samples removed')
        subplot(2,1,2); imagesc(eegBadChannelsRemoved'); caxis([-100 100]); title('artefact removed')
        titleFigureStr = ['race ' fileIDNumStr ' subj ' subjectNumStr ' ' conditionStr ' ' trialNumStr];
        suptitle(titleFigureStr)
        
        pathFigureA = ['output/figures/preprocessing/processing_streamline_' outFileNamePrefix '/run_' nameRaceStr '.png'];
        saveas(figA,pathFigureA);pause(.01);close
        
        % Draw topolot of eeg after all preprocessing.
        eegBadChannelsRemoved_ = eegBadChannelsRemoved;
        eegBadChannelsRemoved_(isnan(eegBadChannelsRemoved)) = 0;
        
        figB = figure('Position', get(0, 'Screensize'));
        [U, S, V] = drawSVDTopoplot(eegBadChannelsRemoved_, locFilename);
        suptitle(titleFigureStr)
        pathFigureB = ['output/figures/preprocessing/topoplot_processed_' outFileNamePrefix '/run_' nameRaceStr '.png'];
        saveas(figB,pathFigureB); pause(.01); close
        
        figure
        [U, S, V] = drawSVDTopoplot(eegEyemovementRegressed, locFilename);
        
        figure
        [U, S, V] = drawSVDTopoplot(eegBadChannelsRemoved_, locFilename);
    end
     
%     disp(['saving processed eeg as ' outFilePath])    
%     save(outFilePath, 'eegProcessed', 'eegEyemovementRegressed', 'methods')
    conditionStrIndex{iter} = conditionStr;
    Eeg{iter} = eegProcessed;
    iter = iter + 1;
end
[conditionIndex,conditionNames] = grp2idx(conditionStrIndex');
save([outputDataDir outFileEegName], 'Eeg', 'conditionIndex');

