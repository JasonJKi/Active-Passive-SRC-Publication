function [fig, stats] = generate_figure_3(inputs, windowSize)
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

%% Computing statistics for rho (SRC) of each viewing conditions.
rhoPlay = rho(indexPlay,:);
rhoBci = rho(indexBci,:);
rhoWatch = rho(indexWatch,:);
 
% deceivedSubjectIndex = find(deceptionIndex);
% numSubjects = length(deceivedSubjectIndex);
% rhoPlay = rhoPlay(deceivedSubjectIndex,:);
% rhoBci = rhoBci(deceivedSubjectIndex,:);  
% rhoWatch = rhoWatch(deceivedSubjectIndex,:);

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
fig = figure(3);clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1,2,[.05 .1],[.575 .05],[.12 .05]);
axes(ha1(1));hold on

xPos = [1,2,3]; 
yPos = 0:.1:.3;

rhoSumMeanAll = sum(rhoMeanAll,2);
bar(xPos(1), rhoSumMeanAll(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), rhoSumMeanAll(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), rhoSumMeanAll(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');
errorbar(xPos, sum(rhoMeanAll,2), semAll,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

set(gca, 'XTick', xPos, 'XTickLabel', conditionStrXTick, 'FontName', 'Arial', 'FontSize', textSizeXAxis, 'TickLabelInterpreter', 'tex')
set(gca, 'YTick', yPos, 'YTickLabel', yPos, 'FontName', 'Arial', 'FontSize', textSizeYAxis)
ylabel('Stimulus-Response Correlation', 'FontSize', textSizeYLabel)
groups = {[xPos(1) xPos(2)], [xPos(1) xPos(3)], [xPos(2) xPos(3)]};
sigstar(groups, pvalAll, 0, false);

box off
ylim([0 .25]);
xlim([.5 3.5]); 

t1 = title('A','FontSize',textSizePanelTitle);
% set(t1,'Position',[-t1.Position(1)/10 t1.Position(2) 0])
set(t1,'Position',[0 t1.Position(2) 0])

%%  Computing statistics for engagement rating of each viewing conditions.
engagementRatings = [engagementRatingPlay engagementRatingBci engagementRatingWatch];
meanEngagementRating = mean(engagementRatings);
semEngagementRatings = stdError(engagementRatings);

%% Perform paired t between the 3 conditions. 
[pvalPlayBci, HPlayBci, statsPlayBci] = signrank(engagementRatingPlay, engagementRatingBci, 'method','approximate');
[pvalPlayWatch, HPlayWatch, statsPlayWatch] = signrank(engagementRatingPlay, engagementRatingWatch, 'tail', 'right', 'method','approximate');
[pvalBciWatch, HWatchBci, statsWatchBci] = signrank(engagementRatingBci, engagementRatingWatch, 'tail', 'right', 'method','approximate');
pvalAllEngagement = [pvalPlayBci pvalPlayWatch pvalBciWatch];

stats.engagement.pvalPlayBci = pvalPlayBci;
stats.engagement.pvalPlayWatch = pvalPlayWatch;
stats.engagement.pvalBciWatch = pvalBciWatch;

stats.engagement.statsPlayBci = statsPlayBci;
stats.engagement.statsPlayWatch = statsPlayWatch;
stats.engagement.statsWatchBci = statsWatchBci;

%% Draw bar graph showing engagement rating between conditions
axes(ha1(2));hold on
xPos = [1,2,3]; 
offSet = .07;

bar(xPos(1), meanEngagementRating(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), meanEngagementRating(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), meanEngagementRating(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');

errorbar(xPos, meanEngagementRating, semEngagementRatings,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

yPos = (0:5:10);
set(gca,'XTick', xPos, 'XTickLabel',conditionStrXTick,'FontName','Arial','FontSize',textSizeXAxis,'TickLabelInterpreter', 'tex')
set(gca,'YTick', yPos, 'YTickLabel', yPos, 'FontName','Arial','FontSize',textSizeYAxis)

ylabel('Self-Reported Engagement', 'FontSize', textSizeYLabel);
ylim([0 10]);
xlim([.5 3.5]); 
box off;

%% Draw p-value for each comparison  between conditions
groups = {[xPos(1) xPos(2)], [xPos(1) xPos(3)], [xPos(2) xPos(3)]};
sigstar(groups,pvalAllEngagement, 0, false);

t2 = title('B','FontSize',textSizePanelTitle);
% set(t2,'Position',[-t2.Position(1)/10 t2.Position(2) 0])
set(t2,'Position',[0 t2.Position(2) 0])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform comparison tests for each component
subjectIndex = 1:numSubjects;
[ha3, pos1] = tight_subplot(1, 3, [.025 .045], [0.1 .575],[.12 .05]);

for i = 1:3

    %% Plot SRC for the 3 conditions
    axes(ha3(i));hold on;
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
    title(['Component ' num2str(i)],'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    
    lineHeight = [0.0850 0.025 0.325];
    sigstar(positions, pvals, 0, false,[],[],lineHeight);
    
    
    box off
    if i == 3
        legend(conditionStr,'Location','NorthWest','FontSize',textSizeLegend);
        legend boxoff
    end
    
    if i == 1
        yMax = max(max(rhoIndComponentAll));
        yPos = (0:.05: yMax *1.5);
        text(-.85,0.11,1, 'C','FontSize',textSizePanelTitle,'FontWeight', 'bold');
        set(ha3(i),'YTick', yPos, 'YTickLabel',yPos, 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
        ylabel('Stimulus-Response Correlation','FontSize',16,'FontName', 'Arial');
    else
        set(ha3(i),'YTick', yPos, 'YTickLabel',[], 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    end
    
    ylim([0 yMax*.7]);
    xlim([.25 xPos(i,3)+.75])
end

