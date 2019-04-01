function [fig, stats] = generate_figure_4(inputs, windowSize)
%% Draw SRC and engagement rating for deceived vs not deceived for "Sham Active" (pseudo BCI).

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

textSizexPos = 18;
textSizeYAxis = 16;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 15;
textSizeLegend = 16;
subjectColor = [.85 .75 .65];
errorBarColor = [0 0 0];
barColor = conditionColor;
%% Computing statistics for rho (SRC) of each viewing conditions.
rhoPlay = rho(indexPlay,:);
rhoBci = rho(indexBci,:);
rhoWatch = rho(indexWatch,:);

subjectNumber = (1:numSubjects)';
deceivedIndex = deceptionIndex == 1;
notDeceivedIndex = deceptionIndex == 0;
subjectNumberDeceived = subjectNumber(deceivedIndex);
subjectNumberNotDeceived = subjectNumber(notDeceivedIndex);
numSubjectDeceived = length(subjectNumberDeceived);
numSubjectNotDeceived = length(subjectNumberNotDeceived);

%% Indexing the SRC of each viewing condition for deceived and not deceived.
rhoMeanTestBciDeceived = mean(rhoBci(deceivedIndex, :));
rhoMeanTestPlayDeceived = mean(rhoPlay(deceivedIndex, :));
rhoMeanTestWatchDeceived = mean(rhoWatch(deceivedIndex, :));

rhoMeanTestBciNotDeceived = mean(rhoBci(notDeceivedIndex, :));
rhoMeanTestPlayNotDeceived = mean(rhoPlay(notDeceivedIndex, :));
rhoMeanTestWatchNotDeceived = mean(rhoWatch(notDeceivedIndex, :));

rhoSumPlayDeceived = sum(rhoPlay(deceivedIndex, :), 2);
rhoSumBciDeceived = sum(rhoBci(deceivedIndex, :), 2);
rhoSumWatchDeceived = sum(rhoWatch(deceivedIndex, :), 2);

rhoSumPlayNotDeceived = sum(rhoPlay(notDeceivedIndex, :), 2);
rhoSumBciNotDeceived = sum(rhoBci(notDeceivedIndex, :), 2);
rhoSumWatchNotDeceived = sum(rhoWatch(notDeceivedIndex, :), 2); 

semRhoPlayDeceived = stdError(rhoSumPlayDeceived);
semRhoBciDeceived = stdError(rhoSumBciDeceived);
semRhoWatchDeceived = stdError(rhoSumWatchDeceived);
semRhoDeceived = [semRhoPlayDeceived; semRhoBciDeceived; semRhoWatchDeceived;];

semRhoPlayNotDeceived = stdError(rhoSumPlayNotDeceived);
semRhoBciNotDeceived = stdError(rhoSumBciNotDeceived);
semRhoWatchNotDeceived = stdError(rhoSumWatchNotDeceived);
semRhoNotDeceived = [semRhoPlayNotDeceived; semRhoBciNotDeceived; semRhoWatchNotDeceived;];

%% Perform comparison tests. 
[pBciDeceivedNotDeveived, hBci, statsBciDeceivedNotDeveived]  = ranksum(rhoSumBciDeceived, rhoSumBciNotDeceived, 'tail', 'right', 'method','approximate');
[pWatchDeceivedNotDeveived, hWatch, statsWatchDeceivedNotDeveived] = ranksum(rhoSumWatchDeceived, rhoSumWatchNotDeceived, 'tail', 'right', 'method','approximate');
[pPlayDeceivedNotDeveived, hPlay, statsPlayDeceivedNotDeveived] = ranksum(rhoSumPlayDeceived, rhoSumPlayNotDeceived, 'tail', 'right', 'method','approximate');

stats.src.pBciDeceivedNotDeveived = pBciDeceivedNotDeveived;
stats.src.pWatchDeceivedNotDeveived = pWatchDeceivedNotDeveived;
stats.src.pPlayDeceivedNotDeveived = pPlayDeceivedNotDeveived;

stats.src.statsBciDeceivedNotDeveived = statsBciDeceivedNotDeveived;
stats.src.statsWatchDeceivedNotDeveived = statsWatchDeceivedNotDeveived;
stats.src.statsPlayDeceivedNotDeveived = statsPlayDeceivedNotDeveived;

[pvalPlayBciDeceived, HPlayBciDeceived, statsPlayBciDeceived] = signrank(rhoSumPlayDeceived, rhoSumBciDeceived, 'tail', 'right', 'method','approximate');
[pvalPlayWatchDeceived, HPlayBciWatchDeceived, statsPlayWatchDeceived] = signrank(rhoSumPlayDeceived, rhoSumWatchDeceived, 'tail', 'right', 'method','approximate');
[pvalWatchBciDeceived, HWatchBciDeceived, statsWatchBciDeceived] = signrank(rhoSumBciDeceived, rhoSumWatchDeceived, 'tail', 'right', 'method','approximate');

stats.src.pvalPlayBciDeceived = pvalPlayBciDeceived;
stats.src.pvalPlayWatchDeceived = pvalPlayWatchDeceived;
stats.src.pvalWatchBciDeceived = pvalWatchBciDeceived;

stats.src.statsPlayBciDeceived = statsPlayBciDeceived;
stats.src.statsPlayWatchDeceived = statsPlayWatchDeceived;
stats.src.statsWatchBciDeceived = statsWatchBciDeceived;

[pvalPlayBciNotDeceived, HPlayBciNotDeceived, statsPlayBciNotDeceived] = signrank(rhoSumPlayNotDeceived, rhoSumBciNotDeceived, 'tail', 'right', 'method','approximate');
[pvalPlayWatchNotDeceived, HPlayBciWatchNotDeceived, statsPlayWatchNotDeceived] = signrank(rhoSumPlayNotDeceived, rhoSumWatchNotDeceived, 'tail', 'right', 'method','approximate');
[pvalWatchBciNotDeceived, HWatchBciNotDeceived, statsWatchBciNotDeceived] = signrank(rhoSumBciNotDeceived, rhoSumWatchNotDeceived, 'tail', 'right', 'method','approximate');

stats.src.pvalPlayBciNotDeceived = pvalPlayBciNotDeceived;
stats.src.pvalPlayWatchNotDeceived = pvalPlayWatchNotDeceived;
stats.src.pvalWatchBciNotDeceived = pvalWatchBciNotDeceived;

stats.src.statsPlayBciNotDeceived = statsPlayBciNotDeceived;
stats.src.statsPlayWatchNotDeceived = statsPlayWatchNotDeceived;
stats.src.statsWatchBciNotDeceived = statsWatchBciNotDeceived;

fig = figure(4); clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1,2,[.05 .1],[.15 0.05],[.125 .05]);

%% Figure 3A - Draw bar graph of SRC for the three conditions and the deceived vs not deceived group 
axes(ha1(1));hold on
xPos = [1 2 4 5 7 8];
xPosOffset = .1;

rhoMeanAll1Deceived = [rhoMeanTestPlayDeceived; rhoMeanTestBciDeceived; rhoMeanTestWatchDeceived];
rhoMeanAll1NotDeceived = [rhoMeanTestPlayNotDeceived; rhoMeanTestBciNotDeceived; rhoMeanTestWatchNotDeceived];
rhoSumMeanAll1Deceived = sum(rhoMeanAll1Deceived,2);
rhoSumMeanAll1NotDeceived = sum(rhoMeanAll1NotDeceived,2);

b1 = bar(xPos(1), rhoSumMeanAll1Deceived(1), 'FaceColor', barColor{1},  'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
b3 = bar(xPos(3), rhoSumMeanAll1Deceived(2), 'FaceColor', barColor{2},'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
b5 = bar(xPos(5), rhoSumMeanAll1Deceived(3), 'FaceColor', barColor{3}, 'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
b2 = bar(xPos(2), rhoSumMeanAll1NotDeceived(1), 'FaceColor', barColor{1}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);
b4 = bar(xPos(4), rhoSumMeanAll1NotDeceived(2), 'FaceColor', barColor{2}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);
b6 = bar(xPos(6), rhoSumMeanAll1NotDeceived(3),  'FaceColor', barColor{3}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);
b7 = bar(10, 0,  'FaceColor', [1 1 1], 'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
b8 = bar(10, 0,  'FaceColor', [1 1 1], 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);

rhoDeceived = [rhoSumPlayDeceived rhoSumBciDeceived rhoSumWatchDeceived];
rhoNotDeceived = [rhoSumPlayNotDeceived rhoSumBciNotDeceived rhoSumWatchNotDeceived];

eb1 = errorbar(xPos([1 3 5]), rhoSumMeanAll1Deceived, semRhoDeceived, '.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb1, .15)
eb2 =errorbar(xPos([2 4 6]), rhoSumMeanAll1NotDeceived, semRhoNotDeceived,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb2, .15)

groups = [xPos(1:2); xPos(3:4); xPos(5:6)];
groupsCellDeveivedVsNotDeceived = {xPos(3:4)};
sigstar(groupsCellDeveivedVsNotDeceived, pBciDeceivedNotDeveived, 1, false, '-r');

xPos =  mean(groups,2);
set(gca,'XTick', xPos, 'XTickLabel',conditionStrXTick,'FontName','Arial','FontSize',textSizexPos,'TickLabelInterpreter', 'tex')
legend boxoff;
yPos = 0:.1:.3;
set(gca,'YTick', yPos,'YTickLabel', yPos, 'FontName','Arial','FontSize',textSizeYAxis)
ylabel('Stimulus-Response Correlation', 'FontSize', textSizeYLabel)
legend([b7 b8],{'Deceived', 'Not Deceived'},'Location','northeast','FontSize',textSizeLegend);
legend boxoff

box off
ylim([0 .35]);
xlim([0 9])

t1 = title('A','FontSize',textSizePanelTitle);
set(t1,'Position',[-t1.Position(1)/6 t1.Position(2) 0])

%% Computing statistics for engagement rating of each viewing conditions.
engagementPlayDeceived = engagementRatingPlay(deceivedIndex);
engagementBciDeceived = engagementRatingBci(deceivedIndex);
engagementWatchDeceived = engagementRatingWatch(deceivedIndex);

semEngagementPlayDeceived = stdError(engagementPlayDeceived);
semEngagementBciDeceived = stdError(engagementBciDeceived);
semEngagementWatchDeceived = stdError(engagementWatchDeceived);
semEngagementDeceived = [semEngagementPlayDeceived semEngagementBciDeceived semEngagementWatchDeceived];

engagementPlayNotDeceived = engagementRatingPlay(notDeceivedIndex);
engagementBciNotDeceived = engagementRatingBci(notDeceivedIndex);
engagementWatchNotDeceived = engagementRatingWatch(notDeceivedIndex);

semEngagementPlayNotDeceived = stdError(engagementPlayNotDeceived);
semEngagementBciNotDeceived = stdError(engagementBciNotDeceived);
semEngagementWatchNotDeceived = stdError(engagementWatchNotDeceived);
semEngagementNotDeceived = [semEngagementPlayNotDeceived semEngagementBciNotDeceived semEngagementWatchNotDeceived];

engagementMeanTestPlayDeceived = mean(engagementRatingPlay(deceivedIndex));
engagementMeanTestBciDeceived = mean(engagementRatingBci(deceivedIndex));
engagementMeanTestWatchDeceived = mean(engagementRatingWatch(deceivedIndex));

engagementMeanTestPlayNotDeceived = mean(engagementRatingPlay(notDeceivedIndex));
engagementMeanTestBciNotDeceived = mean(engagementRatingBci(notDeceivedIndex));
engagementMeanTestWatchNotDeceived = mean(engagementRatingWatch(notDeceivedIndex));

[pBciDeceivedNotDeveived, hBci, statsBciDeceivedNotDeveived]  = ranksum(engagementBciDeceived, engagementBciNotDeceived, 'tail', 'right','method','approximate');
[pWatchDeceivedNotDeveived, hWatch, statsWatchDeceivedNotDeveived] = ranksum(engagementWatchDeceived, engagementWatchNotDeceived, 'tail', 'right','method','approximate');
[pPlayDeceivedNotDeveived, hPlay, statsPlayDeceivedNotDeveived] = ranksum(engagementPlayDeceived, engagementPlayNotDeceived, 'tail', 'right','method','approximate');
stats.engagement.pBciDeceivedNotDeveivedEngagement = pBciDeceivedNotDeveived;
stats.engagement.pWatchDeceivedNotDeveived = pWatchDeceivedNotDeveived;
stats.engagement.pPlayDeceivedNotDeveived = pPlayDeceivedNotDeveived;
stats.engagement.statsBciDeceivedNotDeveived = statsBciDeceivedNotDeveived;
stats.engagement.statsWatchDeceivedNotDeveived = statsWatchDeceivedNotDeveived;
stats.engagement.statsPlayDeceivedNotDeveived = statsPlayDeceivedNotDeveived;

[pvalPlayBciDeceived, HPlayBciDeceived, statsPlayBciDeceived] = signrank(engagementPlayDeceived, engagementBciDeceived, 'tail', 'right','method','approximate');
[pvalPlayWatchDeceived, HPlayBciWatchDeceived, statsPlayWatchDeceived] = signrank(engagementPlayDeceived, engagementWatchDeceived, 'tail', 'right','method','approximate');
[pvalWatchBciDeceived, HWatchBciDeceived, statsWatchBciDeceived] = signrank(engagementBciDeceived, engagementWatchDeceived, 'tail', 'right','method','approximate');
stats.engagement.pvalPlayBciDeceived = pvalPlayBciDeceived;
stats.engagement.pvalPlayWatchDeceived = pvalPlayWatchDeceived;
stats.engagement.pvalWatchBciDeceived = pvalWatchBciDeceived;
stats.engagement.statsPlayBciDeceived = statsPlayBciDeceived;
stats.engagement.statsPlayWatchDeceived = statsPlayWatchDeceived;
stats.engagement.statsWatchBciDeceived = statsWatchBciDeceived;

[pvalPlayBciNotDeceived, HPlayBciNotDeceived, statsPlayBciNotDeceived] = signrank(engagementPlayNotDeceived, engagementBciNotDeceived, 'tail', 'right','method','approximate');
[pvalPlayWatchNotDeceived, HPlayBciWatchNotDeceived, statsPlayWatchNotDeceived] = signrank(engagementPlayNotDeceived, engagementWatchNotDeceived, 'tail', 'right','method','approximate');
[pvalWatchBciNotDeceived, HWatchBciNotDeceived, statsWatchBciNotDeceived] = signrank(engagementBciNotDeceived, engagementWatchNotDeceived, 'tail', 'right' ,'method','approximate');
stats.engagement.pvalPlayBciNotDeceived = pvalPlayBciNotDeceived;
stats.engagement.pvalPlayWatchNotDeceived = pvalPlayWatchNotDeceived;
stats.engagement.pvalWatchBciNotDeceived = pvalWatchBciNotDeceived;
stats.engagement.statsPlayBciNotDeceived = statsPlayBciNotDeceived;
stats.engagement.statsPlayWatchNotDeceived = statsPlayWatchNotDeceived;
stats.engagement.statsWatchBciNotDeceived = statsWatchBciNotDeceived;
%% Figure 3B - Draw bar graph of engagement rating for the three conditions and the deceived vs not deceived group 
axes(ha1(2));hold on
xPos = [1 2 4 5 7 8];

engagementMeanAll1Deceived = [engagementMeanTestPlayDeceived engagementMeanTestBciDeceived engagementMeanTestWatchDeceived]';
engagementMeanAll1NotDeceived = [engagementMeanTestPlayNotDeceived engagementMeanTestBciNotDeceived  engagementMeanTestWatchNotDeceived]';

bar(xPos(1), engagementMeanTestPlayDeceived, 'FaceColor',  barColor{1},  'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
bar(xPos(3), engagementMeanTestBciDeceived, 'FaceColor', barColor{2},'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);
bar(xPos(5), engagementMeanTestWatchDeceived, 'FaceColor', barColor{3}, 'EdgeColor', deceptionColor{1}, 'LineWidth' ,1.5);

bar(xPos(2), engagementMeanTestPlayNotDeceived, 'FaceColor', barColor{1}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);
bar(xPos(4), engagementMeanTestBciNotDeceived, 'FaceColor', barColor{2}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);
bar(xPos(6), engagementMeanTestWatchNotDeceived,  'FaceColor', barColor{3}, 'EdgeColor', deceptionColor{2}, 'LineWidth' ,1.5);

eb1 = errorbar(xPos([1 3 5]), engagementMeanAll1Deceived, semEngagementDeceived, '.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb1, .15)
eb2 =errorbar(xPos([2 4 6]), engagementMeanAll1NotDeceived, semEngagementNotDeceived,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb2, .15)

groups = [xPos(1:2); xPos(3:4); xPos(5:6)];
set(gca,'XTick', mean(groups,2), 'XTickLabel',conditionStrXTick,'FontName','Arial','FontSize',textSizexPos,'TickLabelInterpreter', 'tex')
set(gca,'YTick', 0:5:10,'YTickLabel', 0:5:10, 'FontName','Arial','FontSize',textSizeYAxis)
ylabel('Self-Reported Engagement', 'FontSize', textSizeYLabel)

groupsCellDeveivedVsNotDeceived = {xPos(3:4)};
sigstar(groupsCellDeveivedVsNotDeceived, pBciDeceivedNotDeveived, 0, false, '-r');

box off
ylim([0 15]);
xlim([0 9]);

t2 = title('B','FontSize',textSizePanelTitle);
set(t2,'Position',[-t2.Position(1)/6 t2.Position(2) 0])
end