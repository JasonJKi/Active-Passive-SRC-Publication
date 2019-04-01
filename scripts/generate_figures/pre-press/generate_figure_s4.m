function [fig, stats] = generate_figure_s4(inputs, windowSize)
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

textSizeXAxis = 18;
textSizeYAxis = 16;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 15;
textSizeLegend = 16;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;

edgeColorDeceived = deceptionColor{1};
edgeColorNotDeceived = deceptionColor{2};

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

% semRhoPlay_ = std(rhoPlay)/sqrt(length(rhoPlay));
% semRhoBci_ = std(rhoBci)/sqrt(length(rhoBci));
% semRhoWatch_ = std(rhoWatch)/sqrt(length(rhoWatch));
% semAll_ = [semRhoPlay_; semRhoBci_; semRhoWatch_;];

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
fig = figure(8);clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(2,2,[.05 .1],[.15 0.05],[.125 .05]);
% subplot(1,2,1);hold on
axes(ha1(1));hold on

xPos = [1,2,3]; 
yPos = 0:.1:.3;

% bar(xPos,rhoMeanAll, .6, 'stacked', 'EdgeColor', 'w','FaceAlpha', 0.75);
rhoSumMeanAll = sum(rhoMeanAll,2);
bar(xPos(1), rhoSumMeanAll(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), rhoSumMeanAll(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), rhoSumMeanAll(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');

% plot(repmat(xPos(1), numSubjects, 1), rhoSumAll(:,1) ,'.' , 'Color', subjectColor, 'Markers', 15);
% plot(repmat(xPos(2), numSubjects, 1), rhoSumAll(:,2) ,'.' , 'Color', subjectColor, 'Markers', 15);
% plot(repmat(xPos(3), numSubjects, 1), rhoSumAll(:,3) ,'.' , 'Color', subjectColor, 'Markers', 15);

% offSet = .05;
% subjStr = num2str((1:numSubjects)');
% plot(xPos, rhoSumAll ,'.','Markers',25);
% text(repmat(xPos(1), numSubjects, 1)'+offSet, rhoSumPlay, subjStr, 'FontSize', 10)
% text(repmat(xPos(2), numSubjects, 1)'+offSet, rhoSumBci, subjStr, 'FontSize', 10)
% text(repmat(xPos(3), numSubjects, 1)'+offSet, rhoSumWatch, subjStr, 'FontSize', 10)
% colormap(parula)

% errorbar(repmat(xPos,11,1), cumsum(rhoMeanAll'), semAll','.k')
errorbar(xPos, sum(rhoMeanAll,2), semAll,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)

set(gca,'XTick', [], 'XTickLabel',[],'FontName','Arial','FontSize',textSizeXAxis,'TickLabelInterpreter', 'tex')
set(gca,'YTick', yPos, 'YTickLabel', yPos, 'FontName','Arial','FontSize',textSizeYAxis)
ylabel('Stimulus-Response Correlation', 'FontSize', textSizeYLabel)
groups = {[1 2], [1 3], [2 3]};

% groups = {{conditionStrXTick{1},conditionStrXTick{2}},{conditionStrXTick{1},conditionStrXTick{3}},{conditionStrXTick{3},conditionStrXTick{2}}};
sigstar(groups, pvalAll, 0, false);

box off
ylim([0 .25]);
xlim([.5 3.5]); 

t1 = title('A','FontSize',textSizePanelTitle);
set(t1,'Position',[t1.Position(1)/6 t1.Position(2) 0])

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
% subplot(1,2,2);hold on
axes(ha1(2));hold on
xPos = [1,2,3]; 
offSet = .07;

% bar(xPos,rhoMeanAll, .6, 'stacked', 'EdgeColor', 'w','FaceAlpha', 0.75);
bar(xPos(1), meanEngagementRating(1), .6, 'FaceColor', barColor{1}, 'EdgeColor', 'w');
bar(xPos(2), meanEngagementRating(2), .6, 'FaceColor', barColor{2}, 'EdgeColor', 'w');
bar(xPos(3), meanEngagementRating(3), .6, 'FaceColor', barColor{3}, 'EdgeColor', 'w');

% plot(repmat(xPos(1), numSubjects, 1), engagementRatings(:,1) ,'.' , 'Color', subjectColor, 'Markers', 15);
% plot(repmat(xPos(2), numSubjects, 1), engagementRatings(:,2) ,'.' , 'Color', subjectColor, 'Markers', 15);
% plot(repmat(xPos(3), numSubjects, 1), engagementRatings(:,3) ,'.' , 'Color', subjectColor, 'Markers', 15);

% plot(xPos, engagementRatings ,'.','Markers',25);
% text(repmat(xPos(1), length(engagementRatingPlay),1)'+offSet, engagementRatingPlay, subjStr,'FontSize',10)
% text(repmat(xPos(2), length(engagementRatingBci),1)'+offSet, engagementRatingBci, subjStr,'FontSize',10)
% text(repmat(xPos(3), length(engagementRatingWatch),1)'+offSet, engagementRatingWatch, subjStr,'FontSize',10)
% colormap(parula)

errorbar(xPos, meanEngagementRating, semEngagementRatings,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2)
% errorbar( xPos, meanEngagementRating, semEngagementRatings','.k');

yPos = (0:5:10);
set(gca,'XTick', [], 'XTickLabel',[],'FontName','Arial','FontSize',textSizeXAxis,'TickLabelInterpreter', 'tex')
set(gca,'YTick', yPos, 'YTickLabel', yPos, 'FontName','Arial','FontSize',textSizeYAxis)

ylabel('Self-Reported Engagement', 'FontSize', textSizeYLabel);
ylim([0 10]);
xlim([.5 3.5]); 
box off;

%% Draw p-value for each comparison  between conditions
groups = {[1 2], [1 3], [2 3]};
sigstar(groups,pvalAllEngagement, 0, false);

t2 = title('B','FontSize',textSizePanelTitle);
set(t2,'Position',[t2.Position(1)/6 t2.Position(2) 0])

%% Computing statistics for rho (SRC) of each viewing conditions.
rhoPlay1 = rho(indexPlay,:);
rhoBci = rho(indexBci,:);
rhoWatch1 = rho(indexWatch,:);

subjectNumber = (1:numSubjects)';
deceivedIndex = deceptionIndex == 1;
notDeceivedIndex = deceptionIndex == 0;
subjectNumberDeceived = subjectNumber(deceivedIndex);
subjectNumberNotDeceived = subjectNumber(notDeceivedIndex);
numSubjectDeceived = length(subjectNumberDeceived);
numSubjectNotDeceived = length(subjectNumberNotDeceived);

%% Indexing the SRC of each viewing condition for deceived and not deceived.
rhoMeanTestBciDeceived = mean(rhoBci(deceivedIndex, :));
rhoMeanTestPlayDeceived = mean(rhoPlay1(deceivedIndex, :));
rhoMeanTestWatchDeceived = mean(rhoWatch1(deceivedIndex, :));

rhoMeanTestBciNotDeceived = mean(rhoBci(notDeceivedIndex, :));
rhoMeanTestPlayNotDeceived = mean(rhoPlay1(notDeceivedIndex, :));
rhoMeanTestWatchNotDeceived = mean(rhoWatch1(notDeceivedIndex, :));

rhoSumPlayDeceived = sum(rhoPlay1(deceivedIndex, :), 2);
rhoSumBciDeceived = sum(rhoBci(deceivedIndex, :), 2);
rhoSumWatchDeceived = sum(rhoWatch1(deceivedIndex, :), 2);

rhoSumPlayNotDeceived = sum(rhoPlay1(notDeceivedIndex, :), 2);
rhoSumBciNotDeceived = sum(rhoBci(notDeceivedIndex, :), 2);
rhoSumWatchNotDeceived = sum(rhoWatch1(notDeceivedIndex, :), 2); 

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

%% Figure 3A - Draw bar graph of SRC for the three conditions and the deceived vs not deceived group 
axes(ha1(3));hold on
xPos = [1 2 4 5 7 8];
xPosOffset = .1;

rhoMeanAll1Deceived = [rhoMeanTestPlayDeceived; rhoMeanTestBciDeceived; rhoMeanTestWatchDeceived];
rhoMeanAll1NotDeceived = [rhoMeanTestPlayNotDeceived; rhoMeanTestBciNotDeceived; rhoMeanTestWatchNotDeceived];
rhoSumMeanAll1Deceived = sum(rhoMeanAll1Deceived,2);
rhoSumMeanAll1NotDeceived = sum(rhoMeanAll1NotDeceived,2);

% b1 = bar(xPos([1 3 5]),rhoMeanAll1Deceived, 'stacked', 'EdgeColor', 'w', 'FaceAlpha', 0.7, 'BarWidth', .2);
% b2 = bar(xPos([2 4 6]),rhoMeanAll1NotDeceived, 'stacked', 'EdgeColor', 'w', 'FaceAlpha', 0.7, 'BarWidth', .2);

b1 = bar(xPos(1), rhoSumMeanAll1Deceived(1), 'FaceColor', barColor{1},  'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b3 = bar(xPos(3), rhoSumMeanAll1Deceived(2), 'FaceColor', barColor{2},'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b5 = bar(xPos(5), rhoSumMeanAll1Deceived(3), 'FaceColor', barColor{3}, 'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b2 = bar(xPos(2), rhoSumMeanAll1NotDeceived(1), 'FaceColor', barColor{1}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);
b4 = bar(xPos(4), rhoSumMeanAll1NotDeceived(2), 'FaceColor', barColor{2}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);
b6 = bar(xPos(6), rhoSumMeanAll1NotDeceived(3),  'FaceColor', barColor{3}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);
b7 = bar(10, 0,  'FaceColor', [1 1 1], 'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b8 = bar(10, 0,  'FaceColor', [1 1 1], 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);


rhoDeceived = [rhoSumPlayDeceived rhoSumBciDeceived rhoSumWatchDeceived];
rhoNotDeceived = [rhoSumPlayNotDeceived rhoSumBciNotDeceived rhoSumWatchNotDeceived];

% p1 = plot(repmat(xPos(1), numSubjectDeceived, 1), rhoDeceived(:,1) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% plot(repmat(xPos(3), numSubjectDeceived, 1), rhoDeceived(:,2) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% plot(repmat(xPos(5), numSubjectDeceived, 1), rhoDeceived(:,3) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% p2 = plot(repmat(xPos(2), numSubjectNotDeceived, 1), rhoNotDeceived(:,1) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);
% plot(repmat(xPos(4), numSubjectNotDeceived, 1), rhoNotDeceived(:,2) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);
% plot(repmat(xPos(6), numSubjectNotDeceived, 1), rhoNotDeceived(:,3) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);

eb1 = errorbar(xPos([1 3 5]), rhoSumMeanAll1Deceived, semRhoDeceived, '.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb1, .15)
eb2 =errorbar(xPos([2 4 6]), rhoSumMeanAll1NotDeceived, semRhoNotDeceived,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb2, .15)

% p1 = plot(xPos([1 3 5]), rhoDeceived ,'.','Markers',30);
% p2 = plot(xPos([2 4 6]), rhoNotDeceived, 'x','Markers',13, 'LineWidth',3);
% offSet = .07;
% text(repmat(xPos(1), length(rhoSumPlayDeceived),1)'+offSet, rhoSumPlayDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(2), length(rhoSumPlayNotDeceived),1)'+offSet, rhoSumPlayNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)
% text(repmat(xPos(3), length(rhoSumBciDeceived),1)'+offSet, rhoSumBciDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(4), length(rhoSumBciNotDeceived),1)'+offSet, rhoSumBciNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)
% text(repmat(xPos(5), length(rhoSumWatchDeceived),1)'+offSet, rhoSumWatchDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(6), length(rhoSumWatchNotDeceived),1)'+offSet, rhoSumWatchNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)
groups = [xPos(1:2); xPos(3:4); xPos(5:6)];

groupsCellDeveivedVsNotDeceived = {xPos(3:4)};
sigstar(groupsCellDeveivedVsNotDeceived, pBciDeceivedNotDeveived, 1, false, '-r');

% groupsCellConditionDeveived = {xPos([1 5]); xPos([3 5])};
% sigstar(groupsCellConditionDeveived, [pvalPlayWatchDeceived pvalWatchBciDeceived], 1, false);

xPos =  mean(groups,2);
set(gca,'XTick', xPos, 'XTickLabel',conditionStrXTick,'FontName','Arial','FontSize',textSizeXAxis,'TickLabelInterpreter', 'tex')
legend boxoff;
yPos = 0:.1:.3;
set(gca,'YTick', yPos,'YTickLabel', yPos, 'FontName','Arial','FontSize',textSizeYAxis)
ylabel('Stimulus-Response Correlation', 'FontSize', textSizeYLabel)
legend([b7 b8],{'Deceived', 'Not Deceived'},'Location','northeast','FontSize',textSizeLegend);
legend boxoff

box off
ylim([0 .35]);
xlim([0 9])

t1 = title('C','FontSize',textSizePanelTitle);
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

engagementMeanTestBciDeceived = mean(engagementRatingPlay(deceivedIndex));
engagementMeanTestPlayDeceived = mean(engagementRatingBci(deceivedIndex));
engagementMeanTestWatchDeceived = mean(engagementRatingWatch(deceivedIndex));

engagementMeanTestBciNotDeceived = mean(engagementRatingPlay(notDeceivedIndex));
engagementMeanTestPlayNotDeceived = mean(engagementRatingBci(notDeceivedIndex));
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
axes(ha1(4));hold on
xPos = [1 2 4 5 7 8];
xPosOffset = [];

engagementMeanAll1Deceived = [engagementMeanTestPlayDeceived engagementMeanTestBciDeceived engagementMeanTestWatchDeceived]';
engagementMeanAll1NotDeceived = [engagementMeanTestBciNotDeceived engagementMeanTestPlayNotDeceived engagementMeanTestWatchNotDeceived]';

b1 = bar(xPos(1), engagementMeanTestPlayDeceived, 'FaceColor',  barColor{1},  'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b3 = bar(xPos(3), engagementMeanTestBciDeceived, 'FaceColor', barColor{2},'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);
b5 = bar(xPos(5), engagementMeanTestWatchDeceived, 'FaceColor', barColor{3}, 'EdgeColor', edgeColorDeceived, 'LineWidth' ,1.5);

b2 = bar(xPos(2), engagementMeanTestBciNotDeceived, 'FaceColor', barColor{1}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);
b4 = bar(xPos(4), engagementMeanTestPlayNotDeceived, 'FaceColor', barColor{2}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);
b6 = bar(xPos(6), engagementMeanTestWatchNotDeceived,  'FaceColor', barColor{3}, 'EdgeColor', edgeColorNotDeceived, 'LineWidth' ,1.5);

engagementDeceivedAll = [engagementPlayDeceived engagementBciDeceived engagementWatchDeceived];
engagementNotDeceivedAll = [engagementPlayNotDeceived engagementBciNotDeceived engagementWatchNotDeceived];

% offSet = .07;
% p3 = plot(xPos([1 3 5]), engagementDeceivedAll ,'.','Markers',30);
% p4 = plot(xPos([2 4 6]), engagementNotDeceivedAll, 'x','Markers',13, 'LineWidth',3);
% 
% plot(repmat(xPos(1), numSubjectDeceived, 1), engagementDeceivedAll(:,1) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% plot(repmat(xPos(3), numSubjectDeceived, 1), engagementDeceivedAll(:,2) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% plot(repmat(xPos(5), numSubjectDeceived, 1), engagementDeceivedAll(:,3) ,'o' , 'Color', subjectColor/1.5, 'Markers', 2.5, 'LineWidth',3);
% plot(repmat(xPos(2), numSubjectNotDeceived, 1), engagementNotDeceivedAll(:,1) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);
% plot(repmat(xPos(4), numSubjectNotDeceived, 1), engagementNotDeceivedAll(:,2) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);
% plot(repmat(xPos(6), numSubjectNotDeceived, 1), engagementNotDeceivedAll(:,3) ,'x' , 'Color', subjectColor/1.5, 'Markers', 10, 'LineWidth',1);

eb1 = errorbar(xPos([1 3 5]), engagementMeanAll1Deceived, semEngagementDeceived, '.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb1, .15)
eb2 =errorbar(xPos([2 4 6]), engagementMeanAll1NotDeceived, semEngagementNotDeceived,'.', 'Color', errorBarColor, 'MarkerSize', 5,'LineWidth',2);
alpha(eb2, .15)


% text(repmat(xPos(1), length(engagementPlayDeceived),1)'+offSet, engagementPlayDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(2), length(engagementPlayNotDeceived),1)'+offSet, engagementPlayNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)
% text(repmat(xPos(3), length(engagementBciDeceived),1)'+offSet, engagementBciDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(4), length(engagementBciNotDeceived),1)'+offSet, engagementBciNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)
% text(repmat(xPos(5), length(engagementWatchDeceived),1)'+offSet, engagementWatchDeceived, subjectNumberDeceivedStr,'FontSize',12)
% text(repmat(xPos(6), length(engagementWatchNotDeceived),1)'+offSet, engagementWatchNotDeceived, subjectNumberNotDeceivedStr,'FontSize',12)

groups = [xPos(1:2); xPos(3:4); xPos(5:6)];
set(gca,'XTick', mean(groups,2), 'XTickLabel',conditionStrXTick,'FontName','Arial','FontSize',textSizeXAxis,'TickLabelInterpreter', 'tex')
set(gca,'YTick', 0:5:10,'YTickLabel', 0:5:10, 'FontName','Arial','FontSize',textSizeYAxis)
ylabel('Self-Reported Engagement', 'FontSize', textSizeYLabel)

groupsCellDeveivedVsNotDeceived = {xPos(3:4)};
sigstar(groupsCellDeveivedVsNotDeceived, pBciDeceivedNotDeveived, 0, false, '-r');

% groupsCellConditionDeveived = {xPos([1 5]); xPos([3 5])};
% sigstar(groupsCellConditionDeveived, [pvalPlayWatchDeceived pvalWatchBciDeceived], 0, false);

box off
ylim([0 15]);
xlim([0 9]);

t2 = title('D','FontSize',textSizePanelTitle);
set(t2,'Position',[-t2.Position(1)/6 t2.Position(2) 0])