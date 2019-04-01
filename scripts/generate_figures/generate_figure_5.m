function [fig, stats] = generate_figure_5(inputs, windowSize, bandWidth)
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
numElectrodes = size(Eeg{1},2);

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
panelLabel = char(65:90);

fs = 30;
[thetab1,a1] = butter(4, [4 8]/(fs/2),'bandpass'); % drift removal
[alphab2,a2] = butter(4, [8 13]/(fs/2),'bandpass'); % drift removal
[betab3,a3] = butter(4, [13 14.5]/(fs/2),'bandpass'); % drift removal

% freqz(b,a,[],fs);    
for i = 1:length(Eeg)
    eeg = Eeg{i};
    stimulus = Stimulus{i};
    
    nanIndex = isnan(eeg);
    eeg(nanIndex) = 0;
    eeg_ = eeg*B;
    
    nanIndex_ = isnan(eeg_);
    eeg_(nanIndex_) = 0;
    keepIndex = eeg ~= 0;
    lenEeg = sum(keepIndex);
    
    stimulus_ = stimulus*A;
    rhoSRC(i,:) = computeCorrelation(eeg_,stimulus_);
    
    for ii = 1:numElectrodes
        eegPower(i,ii) = sum(eeg(keepIndex(:,ii),ii).^2)/lenEeg(ii);
        eegThetaPower(i,ii) = mean(filter(thetab1,a1,eeg(:,ii)).^2);
        eegAlphaPower(i,ii) = mean(filter(alphab2,a2,eeg(:,ii)).^2);
        eegBetaPower(i,ii) = mean(filter(betab3,a3,eeg(:,ii)).^2);
    end

    componentPower(i,:) = mean(eeg_.^2);
end


numUniqueConditions = max(uniqueConditionIndex);
conditionIndex_ = zeros(numUniqueConditions,1);
for i = 1:numUniqueConditions
    indice = find(uniqueConditionIndex == i);
    eegPower_(i,:) = mean(eegPower(indice,:));
    eegAlphaPower_(i,:) = mean(eegAlphaPower(indice,:));
    eegThetaPower_(i,:) = mean(eegThetaPower(indice,:));
    eegBetaPower_(i,:) = mean(eegBetaPower(indice,:));
    rhoSRC_(i,:) = mean(rhoSRC(indice,:));
    conditionIndex_(i) = mean(uniqueConditionIndex(indice))';
end

switch bandWidth
    case 'band'
        eegPower = eegPower_;
    case 'theta'
        eegPower = eegThetaPower_;
    case 'alpha'
        eegPower = eegAlphaPower_;
    case 'beta'
        eegPower = eegBetaPower_;
end

eegPowerPlay_ = eegPower(indexPlay,:);
eegPowerBci_ = eegPower(indexBci,:);
eegPowerWatch_ = eegPower(indexWatch,:);

meanEegPowerPlay = mean(eegPowerPlay_);
meanEegPowerBci = mean(eegPowerBci_);
meanEegPowerWatch = mean(eegPowerWatch_);
meanEegPower = cat(1, meanEegPowerPlay, meanEegPowerBci, meanEegPowerWatch);

for iElectrode = 1:numElectrodes
    i = iElectrode;
    [pvalPlayBci(i), ~, statsPlayBci] = signrank(eegPowerPlay_(:,i), eegPowerBci_(:,i), 'method','approximate');
    [pvalPlayWatch(i), ~, statsPlayWatch] = signrank(eegPowerPlay_(:,i),eegPowerWatch_(:,i),  'tail', 'left', 'method','approximate');
    [pvalWatchBci(i), ~, statsWatchBci] = signrank(eegPowerBci_(:,i), eegPowerWatch_(:,i),  'tail', 'left', 'method','approximate');
    zPlayBci(i) = statsPlayBci.zval;
    zPlayWatch(i) = statsPlayWatch.zval;
    zWatchBci(i) = statsWatchBci.zval;
end    

pvalPlayBci_ =fdr(pvalPlayBci);
pvalPlayWatch_ =fdr(pvalPlayWatch);
pvalWatchBci_ =fdr(pvalWatchBci);

pvalCorrectedPairedTests = [pvalPlayWatch_; pvalWatchBci_; pvalPlayBci_];
fig = figure(5); clf
fig.Position = windowSize;
[plotHandleGroup1, ~] = tight_subplot(1,numConditions,[.0 .05],[.6 0.1],[.1 .1]);
[plotHandleGroup2, ~] = tight_subplot(1,numConditions,[.0 .05],[0.15 .55],[.1 .1]);


% get max value of mean power across condition.
[minVal, maxVal, absMax] = findMinMaxValue(meanEegPower,numConditions);
for i = 1:numConditions
    %% Create  for each conditions.
    val = meanEegPower(i,:);
    
    % Set color axes for the headplot 
    colorMapVal = flipud(hot);
    colorAxisRange = [0 maxVal];
    cAxis = [0, maxVal/2, maxVal];
    cAxisTickLabel = {0 , '\muV', num2str(maxVal,3)};

    plotHandle = plotHandleGroup1(i);
    headPlot = setMap(HeadPlot('JBhead96_sym.loc'));
    headPlot.setPlotHandle(plotHandle);
    headPlot.drawMaskHeadRing(.5);
    headPlot.drawNoseAndEars(.5);
    headPlot.formatPlot(plotHandle);
    headPlot.draw(val);
    
    
    headPlot.setColorAxis(colorAxisRange, colorMapVal); % set color axis range.
    if  i == 1; headPlot.setColorBar(cAxis,cAxisTickLabel); end % Create color axes.
    
    title(conditionStr{i},'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    text(-.8, .8, panelLabel(i),'FontSize',textSizePanelTitle, 'FontWeight','Normal');

    % set(t1,'Position',[t1.Position(1)-.5 t1.Position(2)+.1 0])
end

comparisonIndex = [1 3; 2 3; 1 2]; 
numComparison = length(comparisonIndex);

for i = 1:numComparison
    x1 = meanEegPower(comparisonIndex(i,1),:);
    x2 = meanEegPower(comparisonIndex(i,2),:);
    meanEegPowerDifference(i,:) = -abs(x1-x2);
end

[minVal, maxVal, absMax] = findMinMaxValue(meanEegPowerDifference,numComparison);
comparisonStr = {'Active vs Passive' , 'Sham vs Passive', 'Active vs Sham'}; 
for i = 1:numComparison
    
    val = meanEegPowerDifference(i,:);
    plotHandle = plotHandleGroup2(i);
    
    % Create topomap object to draw contour over electrodes.
    headPlot = setMap(HeadPlot('JBhead96_sym.loc'));
    headPlot.setPlotHandle(plotHandle);
    headPlot.drawMaskHeadRing(.5);
    headPlot.drawNoseAndEars(.5);
    headPlot.formatPlot(plotHandle);
    headPlot.draw(val);
    
    % Draw significant points
    pval = pvalCorrectedPairedTests(i,:);
    sigValIndex = pval < .05;
    symbolStr = '^';
    headPlot.drawOnElectrode(sigValIndex, symbolStr); % plot on siginficnt points
    if  i == 1; headPlot.drawMarkerLegend({'p < 0.05'} ,'southeastoutside'); end
    
    % set color axes for the headplot 
    colorMapVal = hot;
    colorAxisRange = [minVal 0];
    headPlot.setColorAxis(colorAxisRange, colorMapVal);
    
    % Draw color bar to indicate color axis scale.
    if  i == 1;
        cAxis = [minVal, minVal/2, 0];
        cAxisTickLabel = {num2str(minVal,3) , '\muV', 0};
        headPlot.setColorBar(cAxis, cAxisTickLabel);
    end
    
    title(comparisonStr{i},'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    text(-.8, .8 ,panelLabel(i+numComparison),'FontSize',textSizePanelTitle, 'FontWeight','Normal');

end

stats = [];

