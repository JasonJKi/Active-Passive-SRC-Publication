function [fig, stats] = generate_figure_s6(inputs, windowSize,deceptionStr)
% parse CCA and SRC variables
fieldNames = fieldnames(inputs);
structName = getVarName(inputs);
for i=1:length(fieldNames)
    eval([fieldNames{i} '=' structName '.' fieldNames{i} ';']);
    disp(fieldNames{i})
end


% parse metadata variables
metadataFieldNames = fieldnames(metadata);
for i=1:length(metadataFieldNames)
    eval([metadataFieldNames{i} '= metadata.' metadataFieldNames{i} ';']);
    disp(metadataFieldNames{i})
end
numSubjects = length(deceptionIndex);
numConditions = length(unique(conditionIndexGrouped)); 

if strcmp(deceptionStr,'deceived')
     deceivedIndex = mockBciSuccessIndex == 1;
else
    deceivedIndex = mockBciSuccessIndex == 0;
end
% figure parameters
textSizeXAxis = 12;
textSizeYAxis = 16;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 18;
textSizeLegend = 12;
textSizeTitle = 18;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;
conditionStr = {'Active Play','Sham Play','Passive Viewing'};
conditionStrXTick = {'  Active\newlinePlay', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};
% get condition index
indexPlay = conditionIndex==1;
indexBci = conditionIndex==2;
indexWatch = conditionIndex==3;
indices = {indexPlay, indexBci, indexWatch};

numSamples = cellfun('length',Eeg);
minSample = min(numSamples);
% Compute temporal response of the canonical correlation components of EEG
fs = 30;
numComponents = 3;
numChannels = 96;
lag = fs;

for i = 1:length(indices)
    iCondition = i;
    conditionIndex_ = indices{iCondition};
    subjectIndex = deceivedIndex & conditionIndex_;
    Eeg_ = Eeg(subjectIndex);
    Stimulus_ = Stimulus(subjectIndex);
    
    h=[];
    numSubjects = length(Eeg_);
    for ii = 1:numSubjects
        iSubject = ii;
        eeg = Eeg_{iSubject};
        nanIndex = isnan(eeg);
        eeg(nanIndex) = 0;
        stimulus = Stimulus_{iSubject}(:,1:end-1);
        
%         x = stimulus(:,1);
        [tStimWh, mu, invMat, whMat] = whiten(stimu/lus);
%         a = lpc(x,5);
%         est_x = filter([0 -a(2:end)],1,x);
%         e = x-est_x;
%          [acs, lags] = xcorr(e,'coeff');
        for iii = 1:numChannels
%             x = tStimWh(:,1);
            x = tStimWh(:,1);

            y = eeg(:,iii);
%             m = length(x);
            r = xcorr(y,x,lag);
%             r_ = r((-lag:lag)+m+1);
            crossCorr(:,ii,iii) = r;
        end
    end
    R{i} = crossCorr;
end
% figure;clf;hold on
% subplot(2,1,1)
% [acs, lags] = xcorr(x,'coeff');
% plot(lags/30,acs)
% xlim([-30 30])
% subplot(2,1,2)
% [acs, lags] = xcorr(e ,'coeff');
% plot(lags/30,acs)
% xlim([-30 30])

fig = figure(10); clf
fig.Position = windowSize;
stats = [];
ozElectrodes = {'oz','o1', 'o2'};
ozChannelIndices = [30, 29, 31];
plotIndex = 1;
for ii = 1:3
    subplot(1,3,ii); hold on
    for i = 1:3

        crossCorr = squeeze(R{i}(:,:,ozChannelIndices(ii)));
        yAll = crossCorr;
        y = mean(crossCorr');
        
        ind=(lag:2*lag);
        x=(ind-lag)/fs;

        plotIndex = plotIndex + 1;

        p(i) = plot(x',y(ind),'Color',barColor{i});
        stdshade(yAll(ind,:)',.25, barColor{i}, x);
%         stdshade(crossCorr,.25, barColor{i}, lags)
%         set(gca,'XTick',lags,'XTickLabel',lags, 'FontSize', textSizeXAxis)
        xlim([0 1])
        if i == 1
            title(ozElectrodes{ii})
        end
        
        if ii == 1
            ylabel(conditionStr{i})
        end
        
        if ii==9
        l1 = legend(p,conditionStr);
        set(l1,'FontSize',textSizeLegend)
        set(l1,'Location','NorthWest')
        set(l1, 'Box', 'off');
        set(l1, 'Position', [l1.Position(1)+.15 l1.Position(2) l1.Position(3) l1.Position(4)]);

        % <= Change This Line
        
        end
    end
end






