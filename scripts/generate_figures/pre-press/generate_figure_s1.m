function [fig, stats] = generate_figure_s1(inputs, windowSize, bandWidth)
%% Draw SRC for each of component for each viewing condition.
stats = struct;
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
textSizePanelTitle = 12;
textSizeLegend = 12;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;

% parse CCA and SRC variables
fieldNames = fieldnames(inputs);
structName = getVarName(inputs);
for i=1:length(fieldNames)
    eval([fieldNames{i} '=' structName '.' fieldNames{i} ';']);
end

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
    
%     rhoSRCThetaPower(i,:) = computeCorrelation(sum(rhoSRC(i,:)), sum(componentThetaPower(i,:)));
%     rhoSRCBetaPower(i,:) = computeCorrelation(sum(rhoSRC(i,:)), sum(componentBetaPower(i,:)));
%     rhoSRCAlphaPower(i,:) = computeCorrelation(sum(rhoSRC(i,:)), sum(componentAlphaPower(i,:)));

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

%% Perform comparison s. 
subjectIndex = 1:numSubjects;
componentPowers = componentPower_;
switch bandWidth
    case 'theta'
        componentPowers = componentThetaPower_;
    case 'alpha'
        componentPowers = componentAlphaPower_;
    case 'beta'
        componentPowers = componentBetaPower_;
end

componentPowerPlay_ = componentPowers(indexPlay,:);
componentPowerBci_ = componentPowers(indexBci,:);
componentPowerWatch_ = componentPowers(indexWatch,:);

AW1 = forwardModel(B, ryy);
locFile = 'JBhead96_sym.loc';

fig = figure(4); clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(3, 4, [.175 .1], [.250 0.125], [.175 .145]);
% [ha2, pos2] = tight_subplot(3, 4, [.215 .115], [.265 0.15], [.245 0.115]);
[ha3, pos3] = tight_subplot(3, 4, [.155 .025], [.125 .24], [.145 0.12]);

delete(ha1(5:end))
% delete(ha2(12))
delete(ha3(5:end))
panelLabel = char(65:90);

positionGroupAll= [];
nComp = 4
for i = 1:nComp;

    % Topoplot spatial weights of EEG
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

    h=text(-2,1,panelLabel(i),'FontSize',textSizePanelTitle, 'FontWeight','Normal');            

    t1 = title(['Component ' num2str(i)],'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    set(t1,'Position',[t1.Position(1)-.5 t1.Position(2)+.1 0])

%     t1 = title(panelLabel(i), 'FontSize', textSizePanelTitle, 'FontWeight','Normal');
%     set(t1,'Position',[t1.Position(1)-1.5 t1.Position(2)-.1 0])

% 
% 
%     % Plot Temporal Filter of Stimulus
%     axes(ha2(i));
%     fs = 30;
%     AH = forwardModel(A, rxx);
%     plot(0:fs, AH(:,i),'Color',barColor(1,:),'LineWidth', 2);
%     set(gca,'XTick',0:fs/2:fs,'XTickLabel',0:1000/2:1000, 'FontSize', 5);
%     xLim = get(gca,'Xlim');
%     yLim = get(gca,'Ylim');
%     set(gca,'XLim', xLim*.9);
%     set(gca,'YLim', yLim*.9);
%     minY = min(AW1(:,i));
%     maxY = max(AW1(:,i));
%     yMin = min(AH(:,i));yMax = max(AH(:,i));
%     ylim([yMin yMax]*1.2)
%     xlabel('time (ms)','FontSize',10)
%     box off
%     
     
    % Plot SRC for the 3 conditions
    axes(ha3(i));hold on;
    componentIndex = i;
    componentPowerPlay = componentPowerPlay_(:,componentIndex);
    componentPowerBci = componentPowerBci_(:,componentIndex);
    componentPowerWatch = componentPowerWatch_(:,componentIndex);
    componentPowerIndComponentAll = [componentPowerPlay componentPowerBci componentPowerWatch];

    yMax = max(max(componentPowerIndComponentAll));
    
    [pvalPlayBci, ~, zPlayBci] = signrank(componentPowerPlay, componentPowerBci);
    [pvalPlayWatch, ~, zPlayWatch] = signrank(componentPowerPlay, componentPowerWatch);
    [pvalWatchBci, ~, zWatchBci] = signrank(componentPowerBci, componentPowerWatch);
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
    set(ha3(i),'YTick', yPos, 'YTickLabel',yPos, 'XTick',[], 'XTickLabel', [], 'FontSize', textSizeXAxis);
    ylim([0 yMax*1.2]);
    xlim([.25 xPos(i,3)+.75])
    
    lineHeight = [0.0850 0.025 0.325];
    if i < 5
        sigstar(positions, pvals, 0, false,[],[],lineHeight);
    end
    if mod(i,4) == 1
        ylabel('Stimulus-Response Correlation','FontSize',textSizeYLabel);
    end
    box off

    if i == nComp
        l1 = legend(conditionStr,'Location','East','FontSize',textSizeLegend);
        legend boxoff
        set(l1,'Position',[0.7085    0.155    0.175     0.162])
    end
end
stats.pvalAll = pvalAll;
stats.zAll = zAll;
numSubjects = length(subjectIndex);
numConditions = length(unique(conditionIndexGrouped)); 
numComponents = size(componentPowerPlay,2);

componentPowerAll = [flatten(componentPowerPlay_) ; flatten(componentPowerBci_); flatten(componentPowerWatch_)];
componentIndex_ = repmat((1:numComponents)', numSubjects*numConditions,1);
subjectIndex_ = repmat(flatten(repmat((1:numSubjects)',numComponents,1)), numConditions,1);
conditionIndex_ = ones(numComponents,numSubjects,numConditions) ;
for i = 1:3; conditionIndex_(:,:,i) = conditionIndex_(:,:,i).*i; end;
conditionIndex_ = flatten(conditionIndex_);

% A two-way repeated-measures ANOVA with condition, and components as factors 
% shows an interaction effect (F = 2.16, df = 20, p = 0.003) indicating effect 
% of condition is varied across the 11 component
end
