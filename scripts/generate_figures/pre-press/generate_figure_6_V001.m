function [fig, stats] = generate_figure_6_(inputs, windowSize)
%% Draw SRC for each of component for each viewing condition.

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
textSizeYAxis = 12;
textSizeYLabel = 12;
textSizeXLabel = 19;
textSizePanelTitle = 13;
textSizeLegend = 12;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86]
barColor = conditionColor;
erpColor = [.1 .2 .3];

%% Computing statistics for rho (SRC) of each viewing conditions.
rhoPlay = rho(indexPlay,:);
rhoBci = rho(indexBci,:);
rhoWatch = rho(indexWatch,:);

%% Perform comparison tests. 
subjectIndex = 1:numSubjects;

rhoPlay_= rhoPlay(subjectIndex,:);
rhoBci_ = rhoBci(subjectIndex,:);
rhoWatch_ = rhoWatch(subjectIndex,:);

fig = figure; clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1, 3, [.025 .045], [.125 .125], [.1 0.05]);

positionGroupAll= [];
panelLabel = char(65:90);

fs = 30;
AH = forwardModel(A, rxx);
for i = 1:3

    %% Plot SRC for the 3 conditions
    axes(ha1(i));hold on;
    componentIndex = i;
    rhoTestPlay = rhoPlay(:,componentIndex);
    rhoTestBci = rhoBci(:,componentIndex);
    rhoTestWatch = rhoWatch(:,componentIndex);
    rhoIndComponentAll = [rhoTestPlay rhoTestBci rhoTestWatch];

    
    [pvalPlayBci, ~, zPlayBci] = signrank(rhoTestPlay, rhoTestBci, 'tail', 'right');
    [pvalPlayWatch, ~, zPlayWatch] = signrank(rhoTestPlay, rhoTestWatch, 'tail', 'right');
    [pvalWatchBci, ~, zWatchBci] = signrank(rhoTestBci, rhoTestWatch, 'tail', 'right');
    pvalAll(:,i) = [pvalPlayBci pvalPlayWatch pvalWatchBci]';   
    zAll(:,i) = [zPlayBci.zval zPlayWatch.zval zWatchBci.zval]';
    xPos(i,:) = (1:3); 
    
    b1 = bar(xPos(i,1), mean(rhoIndComponentAll(:,1)),'FaceColor', barColor{1}, 'EdgeColor', 'w');
    b2 = bar(xPos(i,2), mean(rhoIndComponentAll(:,2)),'FaceColor', barColor{2}, 'EdgeColor', 'w');
    b3 = bar(xPos(i,3), mean(rhoIndComponentAll(:,3)), 'FaceColor', barColor{3}, 'EdgeColor', 'w');

    groups = {[xPos(i,1) xPos(i,2)], [xPos(i,1) xPos(i,3)], [xPos(i,2) xPos(i,3)]};
    positionGroupAll = [positionGroupAll groups];
    
    rhoIndComponentSemAll = std(rhoIndComponentAll)/sqrt(numSubjects);
    errorbar(xPos(i,:),mean(rhoIndComponentAll), rhoIndComponentSemAll','.k')

    rhoTestPlaySigIndex = find(rhoTestPlay > 0);
    rhoTestBciSigIndex = find(rhoTestBci > 0 );
    rhoTestWatchSigIndex = find(rhoTestWatch > 0);
    
    subjIndex = (1:numSubjects)';
    subjStrPlay = num2str(subjIndex(rhoTestPlaySigIndex));
    subjStrBci = num2str(subjIndex(rhoTestBciSigIndex));
    subjStrWatch = num2str(subjIndex(rhoTestWatchSigIndex));
    
    rhoTestPlay_ = rhoTestPlay(rhoTestPlaySigIndex);
    rhoTestBci_ = rhoTestBci(rhoTestBciSigIndex);
    rhoTestWatch_ = rhoTestWatch(rhoTestWatchSigIndex);
    
    offSet = .05;

    positions = groups;
    pvals = pvalAll(:,i);

    t2 = title(['Component ' num2str(i)],'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    
    lineHeight = [0.0850 0.025 0.325];
    sigstar(positions, pvals, 0, false,[],[],lineHeight);

    if i == 1
        yMax = max(max(rhoIndComponentAll));
        yPos = (0:round(yMax/2,2): yMax *1.5);
        
        ylabel('Stimulus-Response Correlation','FontSize',textSizeYLabel);
    end
    
    set(ha1(i),'YTick', yPos, 'YTickLabel',yPos, 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    ylim([0 yMax*.7]);
    xlim([.25 xPos(i,3)+.75])
    box off
    
    if i == 3
        l1 = legend(conditionStr,'Location','NorthWest','FontSize',textSizeLegend);
        legend boxoff
%         set(l1,'Position',[15,640,790,340])
    end
end

numSubjects = length(subjectIndex);
numConditions = length(unique(conditionIndexGrouped)); 
numComponents = size(rhoPlay,2);

rhoAll = [flatten(rhoPlay_) ; flatten(rhoBci_); flatten(rhoWatch_)];
componentIndex_ = repmat((1:numComponents)', numSubjects*numConditions,1);
subjectIndex_ = repmat(flatten(repmat((1:numSubjects)',numComponents,1)), numConditions,1);
conditionIndex_ = ones(numComponents,numSubjects,numConditions) ;
for i = 1:3; conditionIndex_(:,:,i) = conditionIndex_(:,:,i).*i; end;
conditionIndex_ = flatten(conditionIndex_);

groupingIndex = [conditionIndex_ componentIndex_ subjectIndex_ ];
[pAnova, T , anovaStats, TERMS] = anovan(rhoAll, groupingIndex,...
    'random', 3, 'model', 'full', ...
    'var', {'condition', 'component', 'subject'}, ...
    'display', 'off');
stats.pAnova = pAnova;
stats.anovaStats = anovaStats;

% A two-way repeated-measures ANOVA with condition, and components as factors 
% shows an interaction effect (F = 2.16, df = 20, p = 0.003) indicating effect 
% of condition is varied across the 11 component
end
