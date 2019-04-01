function [fig, stats] = generate_figure_4(inputs, windowSize)
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

muRhoSurrogate = mean(rhoSurrogate);
stdRhoSurrogate = std(rhoSurrogate);

AW1 = forwardModel(B, ryy);
locFile = 'JBhead96_sym.loc';

fig = figure(4); clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(3, 4, [.175 .1], [.250 0.125], [.14 .20]);
[ha2, pos2] = tight_subplot(3, 4, [.215 .115], [.265 0.15], [.245 0.115]);
[ha3, pos3] = tight_subplot(3, 4, [.155 .025], [.125 .24], [.145 0.12]);

delete(ha1(12))
delete(ha2(12))
delete(ha3(12))

positionGroupAll= [];
panelLabel = char(65:90);

fs = 30;
AH = forwardModel(A, rxx);
for i = 1:11

    %% Topoplot spatial weights of EEG
    axes(ha1(i)); 
    warning('off','all');
    topoplot(AW1(:,i),locFile,'conv','off','style','map','whitebk','on','plotrad',0.45,'headrad',.45);
    xLim = get(gca,'Xlim');
    yLim = get(gca,'Ylim');
    set(gca,'XLim', xLim*1.1);
    set(gca,'YLim', yLim*1.1);
    minY = min(AW1(:,i));
    maxY = max(AW1(:,i));
    if abs(minY) > abs(maxY)
        yLim = abs(maxY);
    else
        yLim = abs(minY);
    end
    cAxis = [-yLim, 0, yLim];
    cAxis = round(cAxis, -1);
    cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
    cbh = colorbar('location','westoutside');
    colormap jet
    set(cbh,'YTick',cAxis,'YTickLabel',cAxisTickLabel,'TickLabelInterpreter', 'tex')
    set(cbh,'YLim',[-yLim*1.2, yLim*1.2])

    t1 = title(panelLabel(i), 'FontSize', textSizePanelTitle, 'FontWeight','Normal');
    set(t1,'Position',[t1.Position(1)-1.5 t1.Position(2)-.1 0])
       
    %% Plot Temporal Filter of Stimulus
    axes(ha2(i));
    AH_ = AH(1:fs,i);
    t = 0:fs-1;
    
    plot(t, AH_,'Color',erpColor ,'LineWidth', 2);
    set(gca,'XTick',0:fs/2:fs,'XTickLabel',0:1000/2:1000, 'FontSize', 5);

    xLim = get(gca,'Xlim');
    yLim = get(gca,'Ylim');
    set(gca,'XLim', xLim*.9);
    set(gca,'YLim', yLim*.9);

    yMin = min(AH_);yMax = max(AH_);
    ylim([yMin yMax]*1.2)
    xlabel('time (ms)','FontSize',10)
    box off
        
    t2 = title(['Component ' num2str(i)],'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    set(t2,'Position',[t2.Position(1)-15 t2.Position(2)+.1 0])
    
    %% Plot SRC for the 3 conditions
    axes(ha3(i));hold on;
    componentIndex = i;
    rhoTestPlay = rhoPlay(:,componentIndex);
    rhoTestBci = rhoBci(:,componentIndex);
    rhoTestWatch = rhoWatch(:,componentIndex);
    rhoIndComponentAll = [rhoTestPlay rhoTestBci rhoTestWatch];

    yMax = max(max(rhoIndComponentAll));
    
    [pvalPlayBci, ~, zPlayBci] = signrank(rhoTestPlay, rhoTestBci, 'tail', 'right');
    [pvalPlayWatch, ~, zPlayWatch] = signrank(rhoTestPlay, rhoTestWatch, 'tail', 'right');
    [pvalWatchBci, ~, zWatchBci] = signrank(rhoTestBci, rhoTestWatch, 'tail', 'right');
    pvalAll(:,i) = [pvalPlayBci pvalPlayWatch pvalWatchBci]';   
    zAll(:,i) = [zPlayBci.zval zPlayWatch.zval zWatchBci.zval]';
%     xPos(i,:) = [1:3] + ((i-1)*3.5);
    xPos(i,:) = (1:3); 
    
    b1 = bar(xPos(i,1), mean(rhoIndComponentAll(:,1)),'FaceColor', barColor{1}, 'EdgeColor', 'w');
    b2 = bar(xPos(i,2), mean(rhoIndComponentAll(:,2)),'FaceColor', barColor{2}, 'EdgeColor', 'w');
    b3 = bar(xPos(i,3), mean(rhoIndComponentAll(:,3)), 'FaceColor', barColor{3}, 'EdgeColor', 'w');

    groups = {[xPos(i,1) xPos(i,2)], [xPos(i,1) xPos(i,3)], [xPos(i,2) xPos(i,3)]};
    positionGroupAll = [positionGroupAll groups];
%     b4 = bar(xPos(i,:), repmat(CI(i),3,1),'FaceColor', [.9 .9 .9],'FaceAlpha',.5,'EdgeColor', 'w');
    
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

    yPos = (0:round(yMax/2,2): yMax *1.5);
    set(ha3(i),'YTick', yPos, 'YTickLabel',yPos, 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    ylim([0 yMax*.7]);
    xlim([.25 xPos(i,3)+.75])
    

    lineHeight = [0.0850 0.025 0.325];
    if i < 5
        sigstar(positions, pvals, 0, false,[],[],lineHeight);
    end
    if mod(i,4) == 1
        ylabel('Stimulus-Response Correlation','FontSize',textSizeYLabel);
    end
    box off

    if i == 11
        l1 = legend(conditionStr,'Location','East','FontSize',textSizeLegend);
        legend boxoff
        set(l1,'Position',[0.7085    0.155    0.175     0.162])
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
