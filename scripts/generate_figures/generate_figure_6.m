function [fig, stats] = generate_figure_6(inputs, windowSize)
% parse CCA and SRC variables
fieldNames = fieldnames(inputs);
structName = getVarName(inputs);
for i=1:length(fieldNames)
    eval([fieldNames{i} '=' structName '.' fieldNames{i} ';']);
end

% parse metadata variables
metadataFieldNames = fieldnames(metadata);
for i=1:length(metadataFieldNames)
    eval([metadataFieldNames{i} '= metadata.' metadataFieldNames{i} ';']);
end

numSubjects = length(deceptionIndex);
numConditions = length(unique(conditionIndexGrouped)); 

textSizeXAxis = 10;
textSizeYAxis = 10;
textSizeYLabel = 14;
textSizeXLabel = 18;
textSizePanelTitle = 16;
textSizeLegend = 16;
textSizePanelTitle = 14;
subjectColor = [.85 .75 .65];
errorBarColor = [0 0 0 ];
barColor = conditionColor;

%% Figure B,C,D now show theta (4-8 Hz), alpha (8-13), and beta (13-30) power in the component space
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
    
    for ii = 1:96
        eegPower(i,ii) = sum(eeg(keepIndex(:,ii),ii).^2)/lenEeg(ii);
%         eegAlphaPower(i,ii) = mean(abs(hilbert(filter(b,a,eeg(:,ii)))));
        eegThetaPower(i,ii) = mean(filter(thetab1,a1,eeg(:,ii)).^2);
        eegAlphaPower(i,ii) = mean(filter(alphab2,a2,eeg(:,ii)).^2);
        eegBetaPower(i,ii) = mean(filter(betab3,a3,eeg(:,ii)).^2);
    end
    for ii = 1:size(B,2)
        componentThetaPower(i,ii) = mean(filter(thetab1,a1,eeg_(:,ii)).^2);
        componentAlphaPower(i,ii) = mean(filter(alphab2,a2,eeg_(:,ii)).^2);
        componentBetaPower(i,ii) = mean(filter(betab3,a3,eeg_(:,ii)).^2);
    end
    componentPower(i,:) = mean(eeg_.^2);
end

numUniqueConditions = max(uniqueConditionIndex);
conditionIndex_ = zeros(numUniqueConditions,1);
for i = 1:numUniqueConditions
    indice = find(uniqueConditionIndex == i);
    eegPower_(i,:) = mean(eegPower(indice,:));
    eegAlphaPower_(i,:) = mean(eegAlphaPower(indice,:));
    componentPower_(i,:) = mean(componentPower(indice,:));
    componentThetaPower_(i,:) = mean(componentThetaPower(indice,:));
    componentAlphaPower_(i,:) = mean(componentAlphaPower(indice,:));
    componentBetaPower_(i,:) = mean(componentBetaPower(indice,:));
    rhoSRC_(i,:) = mean(rhoSRC(indice,:));
    conditionIndex_(i) = mean(uniqueConditionIndex(indice))';
end
componentIndex = 1:size(A,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
componentPowerPlay = componentPower_(indexPlay,:);
componentPowerBci = componentPower_(indexBci,:);
componentPowerWatch = componentPower_(indexWatch,:);

componentPowerMedianPlay = median(componentPowerPlay);
componentPowerMedianBci = median(componentPowerBci);
componentPowerMedianWatch = median(componentPowerWatch);
componentPowerMedian = [componentPowerMedianPlay(componentIndex); ...
    componentPowerMedianBci(componentIndex); ...
    componentPowerMedianWatch(componentIndex) ]';

componentPowerMeanPlay = mean(componentPowerPlay);
componentPowerMeanBci = mean(componentPowerBci);
componentPowerMeanWatch = mean(componentPowerWatch);

componentPowerMean = [componentPowerMeanPlay(componentIndex); ...
    componentPowerMeanBci(componentIndex); ...
    componentPowerMeanWatch(componentIndex) ]';

componentPowerSumPlay = sum(componentPowerPlay(:,componentIndex),2);
componentPowerSumBci = sum(componentPowerBci(:,componentIndex),2);
componentPowerSumWatch = sum(componentPowerWatch(:,componentIndex),2);
componentPowerSum = [componentPowerSumPlay componentPowerSumBci componentPowerSumWatch];

[pvalPlayBci, HPlayBci, statsPlayBci] = signrank(componentPowerSumPlay, componentPowerSumBci);
[pvalPlayWatch, HPlayBciWatch, statsPlayWatchi] = signrank(componentPowerSumPlay, componentPowerSumWatch);
[pvalWatchBci, HWatchBci, statsWatchBci] = signrank(componentPowerSumBci, componentPowerSumWatch);

pval = [pvalPlayBci pvalPlayWatch pvalWatchBci];

stats.power.pvalPlayBci = pvalPlayBci;
stats.power.pvalPlayWatch = pvalPlayWatch;
stats.power.pvalWatchBci = pvalWatchBci;
stats.power.statsPlayBci = statsPlayBci;
stats.power.statsPlayWatchi = statsPlayWatchi;
stats.power.statsWatchBci = statsWatchBci;

componentPowerSemPlay = std(componentPowerSumPlay)/sqrt(length(componentPowerSumPlay));
componentPowerSemBci = std(componentPowerSumBci)/sqrt(length(componentPowerSumBci));
componentPowerSemWatch = std(componentPowerSumWatch)/sqrt(length(componentPowerSumWatch));

componentPowerSem = [componentPowerSemPlay; componentPowerSemBci; componentPowerSemWatch];

numConditions = 3;
numSubjects = 18;

% one way anova
componentPowerSum = [componentPowerSumPlay; componentPowerSumBci; componentPowerSumWatch];
conditionIndex_ = reshape(repmat((1:numConditions),numSubjects,1),[],1);
subjectIndex_ = repmat((1:numSubjects)',numConditions,1);

%% Figure 5A 
fig = figure(6); 
fig.Position = windowSize;
clf;
% [ha1, pos1] = tight_subplot(1,4,[.05 .025],[.1 0.1],[.1 .05]);
subplot(2,4,1); hold on
% axes(ha1(1));hold on
xPos = [1,2,3]; 
yMax = max(componentPowerSum);
yMax = yMax + yMax/20
yPos = [0:yMax/3:yMax];
bar(xPos(1), sum(componentPowerMean(:,1)), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), sum(componentPowerMean(:,2)), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), sum(componentPowerMean(:,3)), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');

errorbar(xPos, sum(componentPowerMean), componentPowerSem','.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)



set(gca,'XTick', [], 'XTickLabel',[],'FontName','Arial','FontSize',textSizeXAxis)
yTick = get(gca,'YTick')
yTickLabel = cellstr(num2str(round(yTick*1000)', '%.0f\n'))
set(gca,'YTick', yTick, 'YTickLabel',yTickLabel,'FontName','Arial','FontSize',textSizeYAxis)

% set(gca,'YTick', yPos, 'YTickLabel',yPosStr,'FontName','Arial','FontSize',textSizeXAxis)
% set(gca,'YTick', yPos,'YTickLabel',yPosStr, 'FontName','Arial','FontSize',textSizeYAxis, 'TickLabelInterpreter', 'tex')
xlim([.5 3.5]); 
maxY = yPos(4);
ylim([0 maxY])
groups = {[1 2], [1 3], [2 3]};
H = sigstar(groups,pval, 0, false);
box off
% xlabel('Overall','FontSize',textSizePanelTitle);
panelLabel = char(65:90);

t1 = title(panelLabel(1),'FontSize',textSizePanelTitle);
set(t1,'Position',t1.Position + [-2 0 0])
ylabel('Broadband Power (\muV^{2})','FontSize',textSizeYLabel)

positionGroupAll= [];
nComp = 3
for i = 1:nComp;

    subplot(2,4,1+i);hold on;
    componentIndex = i;
    componentPowerPlay_ = componentPowerPlay(:,componentIndex);
    componentPowerBci_ = componentPowerBci(:,componentIndex);
    componentPowerWatch_ = componentPowerWatch(:,componentIndex);
    componentPowerIndComponentAll = [componentPowerPlay_ componentPowerBci_ componentPowerWatch_];

    yMax = max(max(componentPowerIndComponentAll));
    
    [pvalPlayBci, ~, zPlayBci] = signrank(componentPowerPlay_, componentPowerBci_);
    [pvalPlayWatch, ~, zPlayWatch] = signrank(componentPowerPlay_, componentPowerWatch_);
    [pvalWatchBci, ~, zWatchBci] = signrank(componentPowerBci_, componentPowerWatch_);
    pvalAll(:,i) = [pvalPlayBci pvalPlayWatch pvalWatchBci]';   
    zAll(:,i) = [zPlayBci.zval zPlayWatch.zval zWatchBci.zval]';
    xPos(i,:) = (1:3); 
    
    bar(xPos(i,1), mean(componentPowerIndComponentAll(:,1)),'FaceColor', barColor{1}, 'EdgeColor', 'w');
    bar(xPos(i,2), mean(componentPowerIndComponentAll(:,2)),'FaceColor', barColor{2}, 'EdgeColor', 'w');
    bar(xPos(i,3), mean(componentPowerIndComponentAll(:,3)), 'FaceColor', barColor{3}, 'EdgeColor', 'w');

    groups = {[xPos(i,1) xPos(i,2)], [xPos(i,1) xPos(i,3)], [xPos(i,2) xPos(i,3)]};
    componentPowerIndComponentSemAll = std(componentPowerIndComponentAll)/sqrt(numSubjects);
    errorbar(xPos(i,:),mean(componentPowerIndComponentAll), componentPowerIndComponentSemAll','.k')
    
    offSet = .05;
    positions = groups;
    pvals = pvalAll(:,i);

    ylim([0 maxY]);
    xlim([.25 xPos(i,3)+.75])
    
    yPos = (0:round(yMax/2,2): yMax *1.5);
    set(gca,'YTick', [], 'YTickLabel',[], 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);

    
    
    lineHeight = [0.0850 0.025 0.325];
    sigstar(positions, pvals, 0, false,[],[],lineHeight);
    t2 = title(panelLabel(1+i),'FontSize',textSizePanelTitle);
    set(t2,'Position',t2.Position + [-2 0 0])

    if i == nComp
        l1 = legend(conditionStr,'Location','NorthEast','FontSize',textSizeLegend);
        legend boxoff
    end
    

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
componentIndex = 1:size(A,2);

componentPowerPlay = componentAlphaPower_(indexPlay,:);
componentPowerBci = componentAlphaPower_(indexBci,:);
componentPowerWatch = componentAlphaPower_(indexWatch,:);

componentPowerMedianPlay = median(componentPowerPlay);
componentPowerMedianBci = median(componentPowerBci);
componentPowerMedianWatch = median(componentPowerWatch);
componentPowerMedian = [componentPowerMedianPlay(componentIndex); ...
    componentPowerMedianBci(componentIndex); ...
    componentPowerMedianWatch(componentIndex) ]';

componentPowerMeanPlay = mean(componentPowerPlay);
componentPowerMeanBci = mean(componentPowerBci);
componentPowerMeanWatch = mean(componentPowerWatch);

componentPowerMean_ = [componentPowerMeanPlay(componentIndex); ...
    componentPowerMeanBci(componentIndex); ...
    componentPowerMeanWatch(componentIndex) ]';

componentPowerSumPlay = sum(componentPowerPlay(:,componentIndex),2);
componentPowerSumBci = sum(componentPowerBci(:,componentIndex),2);
componentPowerSumWatch = sum(componentPowerWatch(:,componentIndex),2);
componentPowerSum = [componentPowerSumPlay componentPowerSumBci componentPowerSumWatch];

[pvalPlayBci, HPlayBci, statsPlayBci] = signrank(componentPowerSumPlay, componentPowerSumBci);
[pvalPlayWatch, HPlayBciWatch, statsPlayWatchi] = signrank(componentPowerSumPlay, componentPowerSumWatch);
[pvalWatchBci, HWatchBci, statsWatchBci] = signrank(componentPowerSumBci, componentPowerSumWatch);

pval = [pvalPlayBci pvalPlayWatch pvalWatchBci];

stats.power.pvalPlayBci = pvalPlayBci;
stats.power.pvalPlayWatch = pvalPlayWatch;
stats.power.pvalWatchBci = pvalWatchBci;
stats.power.statsPlayBci = statsPlayBci;
stats.power.statsPlayWatchi = statsPlayWatchi;
stats.power.statsWatchBci = statsWatchBci;

componentPowerSemPlay = std(componentPowerSumPlay)/sqrt(length(componentPowerSumPlay));
componentPowerSemBci = std(componentPowerSumBci)/sqrt(length(componentPowerSumBci));
componentPowerSemWatch = std(componentPowerSumWatch)/sqrt(length(componentPowerSumWatch));

componentPowerSem = [componentPowerSemPlay; componentPowerSemBci; componentPowerSemWatch];

numConditions = 3;
numSubjects = 18;

% one way anova
componentPowerSum = [componentPowerSumPlay; componentPowerSumBci; componentPowerSumWatch];
conditionIndex_ = reshape(repmat((1:numConditions),numSubjects,1),[],1);
subjectIndex_ = repmat((1:numSubjects)',numConditions,1);

subplot(2,4,5); hold on
% axes(ha1(1));hold on
xPos = [1,2,3]; 
yMax = max(componentPowerSum);
yMax = yMax + yMax/20;
yPos = [0:yMax/3:yMax];
bar(xPos(1), sum(componentPowerMean_(:,1)), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), sum(componentPowerMean_(:,2)), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), sum(componentPowerMean_(:,3)), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');

errorbar(xPos, sum(componentPowerMean_), componentPowerSem','.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

xlim([.5 3.5]); 
maxY = yPos(4);
ylim([0 maxY])

set(gca,'XTick', [], 'XTickLabel',[],'FontName','Arial','FontSize',textSizeXAxis)
yTick = get(gca,'YTick')
yTickLabel = cellstr(num2str(round(yTick*1000,1)', '%.1f\n'))
set(gca,'YTick', yTick, 'YTickLabel',yTickLabel,'FontName','Arial','FontSize',textSizeYAxis)


groups = {[1 2], [1 3], [2 3]};
H = sigstar(groups,pval, 0, false);
box off
xlabel('Overall','FontSize',textSizePanelTitle);
t3 = title(panelLabel(5),'FontSize',textSizePanelTitle);
set(t3,'Position',t3.Position + [-2 0 0])
ylabel('Alpha Power (\muV^{2})','FontSize',textSizeYLabel)

positionGroupAll= [];
nComp = 3
for i = 1:nComp;

    subplot(2,4,5+i);hold on;
    componentIndex = i;
    componentPowerPlay_ = componentPowerPlay(:,componentIndex);
    componentPowerBci_ = componentPowerBci(:,componentIndex);
    componentPowerWatch_ = componentPowerWatch(:,componentIndex);
    componentPowerIndComponentAll = [componentPowerPlay_ componentPowerBci_ componentPowerWatch_];

    yMax = max(max(componentPowerIndComponentAll));
    
    [pvalPlayBci, ~, zPlayBci] = signrank(componentPowerPlay_, componentPowerBci_);
    [pvalPlayWatch, ~, zPlayWatch] = signrank(componentPowerPlay_, componentPowerWatch_);
    [pvalWatchBci, ~, zWatchBci] = signrank(componentPowerBci_, componentPowerWatch_);
    pvalAll(:,i) = [pvalPlayBci pvalPlayWatch pvalWatchBci]';   
    zAll(:,i) = [zPlayBci.zval zPlayWatch.zval zWatchBci.zval]';
    xPos(i,:) = (1:3); 
    
    bar(xPos(i,1), mean(componentPowerIndComponentAll(:,1)),'FaceColor', barColor{1}, 'EdgeColor', 'w');
    bar(xPos(i,2), mean(componentPowerIndComponentAll(:,2)),'FaceColor', barColor{2}, 'EdgeColor', 'w');
    bar(xPos(i,3), mean(componentPowerIndComponentAll(:,3)), 'FaceColor', barColor{3}, 'EdgeColor', 'w');

    groups = {[xPos(i,1) xPos(i,2)], [xPos(i,1) xPos(i,3)], [xPos(i,2) xPos(i,3)]};
    componentPowerIndComponentSemAll = std(componentPowerIndComponentAll)/sqrt(numSubjects);
    errorbar(xPos(i,:),mean(componentPowerIndComponentAll), componentPowerIndComponentSemAll','.k')
    
    offSet = .05;
    positions = groups;
    pvals = pvalAll(:,i);

    yPos = (0:round(yMax/2,2): yMax *1.5);
    ylim([0 maxY]);
    xlim([.25 xPos(i,3)+.75])
    
    set(gca,'YTick', [], 'YTickLabel',[], 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    xlabel(['Component ' num2str(i)],'FontSize',textSizePanelTitle);

    sigstar(positions, pvals, 0, false,[],[],lineHeight);
    t4 = title(panelLabel(5+i),'FontSize',textSizePanelTitle);
    set(t4,'Position',t4.Position + [-2 0 0])

end

