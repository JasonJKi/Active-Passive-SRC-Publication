function [fig, stats] = generate_figure_s1_2(inputs, windowSize)
%% Draw SRC and engagement rating of each viewing condition.

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

textSizeXAxis = 16;
textSizeYAxis = 16;
textSizeYLabel = 16;
textSizeXLabel = 18;
textSizePanelTitle = 15;
textSizeLegend = 16;
subjectColor = [.85 .75 .65];
barColor = conditionColor;
errorBarColor = [0 0 0];
panelLabel = char(65:90);

%% Computing statistics for rho (SRC) of each viewing conditions.
rhoPlay = rho(indexPlay,:);
rhoBci = rho(indexBci,:);
rhoWatch = rho(indexWatch,:);

rhoMeanPlay = mean(rhoPlay);
rhoMeanBci = mean(rhoBci);
rhoMeanWatch = mean(rhoWatch);

componentIndex = 1:size(A,2);
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

[pAnova, ~, statsAnova] = anovan(rhoSumAlll, [conditionIndexAll_ subjectIndexAll_], ...
    'random',2,'model','interaction', ...
    'varnames',{'condition' 'subject'}, ...
    'display', 'off');

stats.pAnova = pAnova;
stats.statsAnova = statsAnova;

%% Draw bar graph showing comparison of SRC for each viewing condition.
fig = figure(9);clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1, 4, [.05 .01], [.1 .1], [.1 .05]);
[ha2, pos1] = tight_subplot(1, 3, [.05 .01], [.6 .1], [.315 .05]);

axes(ha1(1));hold on
xPos = [1,2,3]; 
yPos = 0:.1:.3;

rhoSumMeanAll = sum(rhoMeanAll,2);
bar(xPos(1), rhoSumMeanAll(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), rhoSumMeanAll(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), rhoSumMeanAll(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');
errorbar(xPos, sum(rhoMeanAll,2), semAll,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

set(gca, 'XTick', xPos, 'XTickLabel', [], 'FontName', 'Arial', 'FontSize', textSizeXAxis, 'TickLabelInterpreter', 'tex')
set(gca, 'YTick', yPos, 'YTickLabel', yPos, 'FontName', 'Arial', 'FontSize', textSizeYAxis)
ylabel('Stimulus-Response Correlation', 'FontSize', textSizeYLabel)
groups = {[xPos(1) xPos(2)], [xPos(1) xPos(3)], [xPos(2) xPos(3)]};
sigstar(groups, pvalAll, 0, false);

box off
yMax = .15
ylim([0 yMax]);
xlim([.5 3.5]); 
xlabel('Overall');

t1 = title(panelLabel(1),'FontSize',textSizePanelTitle);
set(t1,'Position',[0.25 t1.Position(2) 0])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform comparison tests for each component
subjectIndex = 1:numSubjects;
numComponents = 3;
for i = 1:numComponents

    %% Plot SRC for the 3 conditions
    axes(ha1(i+1));hold on;
    componentIndex = i;
    rhoTestPlay = rhoPlay(:,componentIndex);
    rhoTestBci = rhoBci(:,componentIndex);
    rhoTestWatch = rhoWatch(:,componentIndex);
    rhoIndComponentAll = [rhoTestPlay rhoTestBci rhoTestWatch];

    
    [pvalPlayBci, ~, statsPlayBci] = signrank(rhoTestPlay, rhoTestBci, 'tail', 'right', 'method','approximate');
    [pvalPlayWatch, ~, statsPlayWatch] = signrank(rhoTestPlay, rhoTestWatch, 'tail', 'right', 'method','approximate');
    [pvalWatchBci, ~, statsWatchBci] = signrank(rhoTestBci, rhoTestWatch, 'tail', 'right', 'method','approximate');
    pvalAll_(:,i) = [pvalPlayBci pvalPlayWatch pvalWatchBci]';   
    zAll(:,i) = [statsPlayBci.zval statsPlayWatch.zval statsWatchBci.zval]';
    xPos(i,:) = (1:3); 
    
    bar(xPos(i,1), mean(rhoIndComponentAll(:,1)),'FaceColor', barColor{1}, 'EdgeColor', 'w');
    bar(xPos(i,2), mean(rhoIndComponentAll(:,2)),'FaceColor', barColor{2}, 'EdgeColor', 'w');
    bar(xPos(i,3), mean(rhoIndComponentAll(:,3)), 'FaceColor', barColor{3}, 'EdgeColor', 'w');

    groups = {[xPos(i,1) xPos(i,2)], [xPos(i,1) xPos(i,3)], [xPos(i,2) xPos(i,3)]};
    
    rhoIndComponentSemAll = std(rhoIndComponentAll)/sqrt(numSubjects);
    errorbar(xPos(i,:),mean(rhoIndComponentAll), rhoIndComponentSemAll','.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

    positions = groups;
    pvals = pvalAll_(:,i);
    xlabel(['Component ' num2str(i)])
    lineHeight = [0.050 0.22 0.5];
    sigstar(positions, pvals, 0, false,[],[],lineHeight);
    
    box off
    if i == 3
        l1 = legend(conditionStr,'Location','NorthWest','FontSize',textSizeLegend);
        
        set(l1,'Position', l1.Position + [0 -.30 0 0])
        legend boxoff
    end
    
    set(gca,'YTick', yPos, 'YTickLabel',[], 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    
    ylim([0 yMax]);
    xlim([.25 xPos(i,3)+.75])
    t1 = title(panelLabel(1+i),'FontSize',textSizePanelTitle);
    set(t1,'Position',[0.25 t1.Position(2) 0])

end


% Get EEG Forward Model
AW = forwardModel(B, ryy);
locFile = 'JBhead96_sym.loc';

for i = 1:numComponents
    
    plotHandle = ha2(i);
    val = AW(:,i);
    
    topoPlot = setMap(Topomap('JBhead96_sym.loc'));
    topoPlot.setPlotHandle(plotHandle);
    topoPlot.drawMaskHeadRing(.5);
    topoPlot.drawNoseAndEars(.5);
    topoPlot.formatPlot(plotHandle);
    topoPlot.draw(val);
    
    % set color axes for the topoplot
    colorMapVal = jet;
    minA = min(val);
    maxA = max(val);
    absMin = min(abs(minA),abs(maxA));
    absMax = max(abs(minA),abs(maxA));
    colorAxisRange = [-absMax absMax];
    cAxis = [-absMax 0 absMax];
    cAxisTickLabel = {num2str(absMin,3), '\muV', num2str(absMax,3)};
    topoPlot.setColorAxis(colorAxisRange, colorMapVal);
    

end

