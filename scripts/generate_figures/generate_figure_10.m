function [fig, stats] = generate_figure_10(inputs, windowSize)
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

% figure parameters
textSizeXAxis = 10;
textSizeYAxis = 12;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 16;
textSizeLegend = 12;
textSizeTitle = 18;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;
erpColor = [.1 .2 .3];
panelLabel = char(65:90);

% get condition index
indexPlay = find(conditionIndex==1);
indexBci = find(conditionIndex==2);
indexWatch = find(conditionIndex==3);
indices = {indexPlay, indexBci, indexWatch};


occipitalIndex = [29:32 60:64 93:96];
occipitalIndex = [29:32];


fs = 30;
numPeaks = 50;
for i = 1:length(Stimulus)
    x = Stimulus{i};
    x = x(:,1);
    xDiff = diff(abs(x));
    [b, indx] = sort(xDiff, 'desc');
    peakIndex = indx(1:numPeaks);
    
    y = Eeg{i};
    
    yPeakMean = [];
    yPeakMax = [];
    for ii = 1:numPeaks
        n = length(y);
        ind = peakIndex(ii);
        epochInd = ind:ind + fs;
        if epochInd(end) > n
            epochInd = epochInd(1):n;
        end
        yPeakMean(ii) = nanmean(nanmean(y(epochInd,occipitalIndex)));
        yPeakMax(ii) = nanmean(max(y(epochInd,occipitalIndex)));

    end
        
    erpMean(i) = mean(yPeakMean);
    erpMax(i) = mean(yPeakMax);
    
end


stats = [];

val = erpMax;
rhoPlay = val(indexPlay);
rhoBci = val(indexBci);
rhoWatch = val(indexWatch);
 
rhoMeanPlay = rhoPlay;
rhoMeanBci = rhoBci;
rhoMeanWatch = rhoWatch;

componentIndex = 1;
rhoSumPlay = sum(rhoPlay(:,componentIndex),2);
rhoSumBci = sum(rhoBci(:,componentIndex),2);
rhoSumWatch = sum(rhoWatch(:,componentIndex),2);
rhoSumAll = [rhoSumPlay rhoSumBci rhoSumWatch];

rhoMeanAll = [rhoMeanPlay(componentIndex); ...
    rhoMeanBci(componentIndex); ...
    rhoMeanWatch(componentIndex) ];

semRhoPlay = stdError(rhoSumPlay);
semRhoBci = stdError(rhoSumBci);
semRhoWatch = stdError(rhoSumWatch);
semAll = [semRhoPlay; semRhoBci; semRhoWatch;];

%% Perform paired t between the 3 conditions. 
[pvalPlayBci, ~, statsPlayBci] = signrank(rhoSumPlay, rhoSumBci, 'method','approximate');
[pvalPlayWatch, ~, statsPlayWatch] = signrank(rhoSumPlay, rhoSumWatch, 'tail', 'right', 'method','approximate');
[pvalBciWatch, ~, statsWatchBci] = signrank(rhoSumBci, rhoSumWatch, 'tail', 'right', 'method','approximate');
pvalAll = [pvalPlayBci pvalPlayWatch pvalBciWatch];

stats.src.pvalPlayBci = pvalPlayBci;
stats.src.pvalPlayWatch = pvalPlayWatch;
stats.src.pvalBciWatch = pvalBciWatch;
stats.src.statsPlayBci = statsPlayBci;
stats.src.statsPlayWatch = statsPlayWatch;
stats.src.statsWatchBci = statsWatchBci;
%% one way repeated measures ANOVA
rhoSumAlll = [rhoSumPlay;rhoSumBci;rhoSumWatch];
conditionIndexAll_ = reshape(repmat((1:numConditions),numSubjects,1),[],1);
subjectIndexAll_ = repmat((1:numSubjects)',numConditions,1);

% [pAnova, ~, statsAnova] = anovan(rhoSumAlll, [conditionIndexAll_ subjectIndexAll_], ...
%     'random',2,'model','interaction', ...
%     'varnames',{'condition' 'subject'}, ...
%     'display', 'off');
% 
% stats.pAnova = pAnova;
% stats.statsAnova = statsAnova;

%% Draw bar graph showing comparison of SRC for each viewing condition.
fig = figure(3);clf;
fig.Position = windowSize;
% [ha1, pos1] = tight_subplot(1,2,[.05 .1],[.575 .05],[.12 .05]);
% axes(ha1(1));
subplot(1,1,1)
hold on

xPos = [1,2,3]; 
yPos = 0:.1:.3;

rhoSumMeanAll = sum(rhoMeanAll,2);
bar(xPos(1), rhoSumMeanAll(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), rhoSumMeanAll(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), rhoSumMeanAll(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');
errorbar(xPos, sum(rhoMeanAll,2), semAll,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

set(gca, 'XTick', xPos, 'XTickLabel', conditionStrXTick, 'FontName', 'Arial', 'FontSize', textSizeXAxis, 'TickLabelInterpreter', 'tex')
% set(gca, 'YTick', yPos, 'YTickLabel', yPos, 'FontName', 'Arial', 'FontSize', textSizeYAxis)
ylabel('Occipital ERP for Optical Flow Peaks', 'FontSize', textSizeYLabel)
groups = {[xPos(1) xPos(2)], [xPos(1) xPos(3)], [xPos(2) xPos(3)]};
sigstar(groups, pvalAll, 0, false);

box off
% ylim([0 .25]);
xlim([.5 3.5]); 

% t1 = title('A','FontSize',textSizePanelTitle);
% % set(t1,'Position',[-t1.Position(1)/10 t1.Position(2) 0])
% set(t1,'Position',[0 t1.Position(2) 0])




