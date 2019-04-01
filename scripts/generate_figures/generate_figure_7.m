function [fig, stats] = generate_figure_7(inputs, windowSize)
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
textSizeXAxis = 12;
textSizeYAxis = 12;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 14;
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

fs = 30;
numComponents = 3;
RyyCond = cell(3,1);
for i = 1:3
    iCondition = i;
    raceIndex = indices{iCondition};
    eeg = Eeg(raceIndex);
    stimulus = Stimulus(raceIndex);
    
    % Compute covariance of eeg for each condition
    RyyCond{i} = nancov(cat(1,eeg{:}));
    h=[]; w=[];
    numRaces = length(raceIndex);
    for ii = 1:numRaces
        iRace = ii;
        
        % Compute
        x = stimulus{iRace};
        y = eeg{iRace};
        y(isnan(y)) = 0;

        u = x*A;
        v = y*B;
        
        for iii = 1:numComponents
            iComp = iii;
            
            % Compute stimulus response function from eeg canoncorr
            % component.
            r = v(:,iComp);
            s = x;
            h_ = (r\s)';
            h(iRace, :, iComp) = h_ - mean(h_);
            
            % Compute eeg spatial weights from temporal response of canoncorr
            % component.
            r = y;
            s = u(:,iComp);
            w_ = (s\r)';
            w(iRace, :, iComp) = w_;
            
        end
        
    end
    
    H{i} = h; 
    W{i} = w;
    
end

fig = figure(7); clf
fig.Position = windowSize;
[plotHandleGroup1, pos1] = tight_subplot(1,3,[.1 .125], [.85 .05], [0.125 0.05]);
[plotHandleGroup2, pos2] = tight_subplot(1,3,[.1 .125], [.7 .2], [0.125 0.05]);
[plotHandleGroup3, pos3] = tight_subplot(1,3,[.1 .125], [.34 .35], [0.15 0.05]);
[plotHandleGroup4, pos4] = tight_subplot(1,3,[.1 .025], [.1 .65], [.075 .05]);

topoplotIndexSham = (1:2:6);
topoplotIndexPassive = (2:2:6);
topoPlotIndex = {topoplotIndexSham, topoplotIndexPassive};
conditionPlotIndex = [2 3];

%% Create topoplot for the each of the run conditions.
condIndex = 2; A1 = [];
for i = 1:numComponents
    iComp = i;
    w = W{condIndex}(:,:,iComp);

    
    for ii = 1:size(w,1)
        A1(ii,:,iComp) = forwardModel(w(ii,:)', ryy); % RyyCond{condIndex}
    end
    AMean = nanmean(A1(:,:,iComp));

    % Create topomap object to draw contour over electrodes.
    val = AMean;
    plotHandle = plotHandleGroup1(iComp);
    
    scalpPlot = ScalpPlot('JBhead96_sym.loc');
    scalpPlot.setMap();
    scalpPlot.setPlotHandle(plotHandle);
    scalpPlot.draw(val) 

    % set color axes for the topoplot
    minVal = min(val);
    maxVal = max(val);
    colorAxisRange = round([minVal, maxVal],1);

    scalpPlot.setColorAxis([minVal maxVal])
    
    % Draw color bar to indicate color axis scale.
    cAxis = [colorAxisRange(1), mean(colorAxisRange), colorAxisRange(2)];
    cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
    scalpPlot.drawColorBar(cAxis, cAxisTickLabel)
    
    text(-.9,.9, ['Component ' num2str(iComp)], 'FontSize',18)

    if i == 1
        h = text(-1.4, -.3, conditionStr(condIndex), 'FontWeight','Normal', 'FontSize', 12);
        set(h,'Rotation',90);
    end
    
    text(-2.1, .8,panelLabel(iComp), 'FontSize',textSizePanelTitle, 'FontWeight','Normal')    
end




condIndex = 3;A2 = [];
for i = 1:numComponents
    
    iComp = i;
    w = W{condIndex}(:,:,iComp);

    for ii = 1:size(w,1)
        A2(ii,:,iComp) = forwardModel(w(ii,:)', ryy); 
    end
    AMean = nanmean(A2(:,:,iComp));

    % Create topomap object to draw contour over electrodes.
    val = AMean;
    plotHandle = plotHandleGroup2(iComp);
    
    scalpPlot = ScalpPlot('JBhead96_sym.loc');
    scalpPlot.setMap();
    scalpPlot.setPlotHandle(plotHandle);
    scalpPlot.draw(val) 
        
    % set color axes for the topoplot
    minY = min(val);
    maxY = max(val);
    
    colorMapVal = jet;
    colorAxisRange = round([minY, maxY],1);
    scalpPlot.setColorAxis(colorAxisRange);
    
    % Draw color bar to indicate color axis scale.
    cAxis = [colorAxisRange(1), mean(colorAxisRange), colorAxisRange(2)];
    cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
    scalpPlot.drawColorBar(cAxis, cAxisTickLabel);
    
    if i == 1
        h = text(-1.4, -.5, conditionStr(condIndex), 'FontWeight','Normal', 'FontSize', 12);
        set(h,'Rotation',90);
    end
    
%     text(-2.1, .8,panelLabel(iComp+numComponents), 'FontSize',textSizePanelTitle, 'FontWeight','Normal')    
end







wBci = W{2};
wWatch = W{3};

for i = 1:numComponents
    iComp = i;
    
    AMean1 = nanmean(A1(:,:,iComp));
    AMean2 = nanmean(A2(:,:,iComp));

    ADifference = AMean1 - AMean2;
    
    % Create topomap object to draw contour over electrodes.
    val = ADifference;
    plotHandle = plotHandleGroup3(iComp);
    
    scalpPlot = ScalpPlot('JBhead96_sym.loc');
    scalpPlot.setMap();
    scalpPlot.setPlotHandle(plotHandle);
    scalpPlot.draw(val);
    
    % set color axes for the topoplot
    minY = min(ADifference);
    maxY = max(ADifference);
    
    colorMapVal = hot;
    colorAxisRange = round([minY, maxY],2);
    scalpPlot.setColorAxis(colorAxisRange, colorMapVal);
    
    % Draw color bar to indicate color axis scale.
    cAxis = [colorAxisRange(1), mean(colorAxisRange), colorAxisRange(2)];
    cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
    scalpPlot.drawColorBar(cAxis, cAxisTickLabel);

    for j = 1:96
        x = A1(:,j,iComp);
        y = A2(:,j,iComp);
        [pvalWBciWatch(j, iComp), WWatchBci, statsWatchBci] = ranksum(x, y, 'method','approximate');
        zWWatchBci(j, iComp) = statsWatchBci.zval;
    end

    isGreaterBci = (ADifference > 0)';
    isGreaterWatch = ~isGreaterBci;
    sigIndex = pvalWBciWatch(:,iComp) < .05;
    
    isGreaterBci = isGreaterBci & sigIndex;
    isGreaterWatch = isGreaterWatch & sigIndex;

    markerHandle1 = scalpPlot.drawOnElectrode(isGreaterBci,'^', [0 0 1]);
    markerHandle2 = scalpPlot.drawOnElectrode(isGreaterWatch, '^', [0 1 0]);
    
    if iComp == 1
        conditionStr = {'Sham > Passive (p < 0.05)', 'Passive > Sham (p < 0.05)'};
        markerHandles = [markerHandle1 markerHandle2];
        scalpPlot.drawMarkerLegend(markerHandles, conditionStr, 'northoutside');
    end
    
    if i == 1
        h = text(-1.1, -.4, 'Sham vs Passive', 'FontWeight','Normal', 'FontSize', 12);
        set(h,'Rotation',90);
    end
    
    text(-1.2, .8,panelLabel(iComp + numComponents*1), 'FontSize',textSizePanelTitle, 'FontWeight','Normal')
    
end

% plot corresponding temporal filter for each of the conditions 
hBci = H{2};
hWatch = H{3};
for i = 1:numComponents
    iComp = i;
    for ii = 1:2
        iCond = conditionPlotIndex(ii);
        
        h = H{iCond}(:,(1:fs),iComp);
        hMean = nanmean(h);

        y = hMean;
        x = 0:fs-1;
        
        axes(plotHandleGroup4(iComp));hold on
        p = plot(x,y,'Color',barColor{iCond});
        stdshade(h,.25, barColor{iCond}, x)
        set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', textSizeXAxis)
        
        ylim([-.75 .75] )
        set(gca,'color','none')
        
        xlabel('Time (ms)')
        
        if iComp == 1
            set(gca,'YTick',-1:.5:1,'YTickLabel',num2str((-1:.5:1)','%0.2f'), 'FontSize', textSizeXAxis);
            ylabel('\muV')
        end
        
        templPointsHandle(ii) = p;
        box off
    end
    
    %% Perform pairwise test to test difference of the temporal filters between sham play and passive.
    for j = 1:fs
        x = squeeze(hBci(:,j,iComp))';
        y = squeeze(hWatch(:,j,iComp))';

        [pvalHBciWatch(j, iComp), HWatchBci, statsWatchBci] = ranksum(x, y, 'method','approximate');
        zHWatchBci(j, iComp) = statsWatchBci.zval;
    
        % x = x(1:36);
        % y = y(1:36);
        % pairwiseTest = @(x,y) ranksum(x,y,'method','approximate');
        % [pvalHBootBciWatch(:, i, ii),bootsam] = bootstrp(1000,pairwiseTest,x,y);
        
    end
    
    maxPeak = max([max(nanmean(hBci(:,:,iComp))) max(nanmean(hWatch(:,:,iComp)))]);
    
    sigWatchBci = pvalHBciWatch(:,i)<.05;
    indexWatchBci = find(sigWatchBci);
    axes(plotHandleGroup4(iComp));
    templPointsHandle3=plot(indexWatchBci-1,repmat(maxPeak*1.1,length(indexWatchBci),1), '*', 'LineWidth', 2);
    
    if iComp == 3
        conditionStr = {'Sham Play','Passive Viewing', 'Sham vs Passive (p < 0.05)'};
        legend([templPointsHandle(1) templPointsHandle(2) templPointsHandle3],conditionStr, ...
            'Location', 'South', 'FontSize',textSizeLegend)
        legend boxoff
    end
    
    text(-3, .8,panelLabel(iComp + numComponents*2), 'FontSize',textSizePanelTitle, 'FontWeight','Normal')    
end

stats=[];
fig.PaperPositionMode = 'auto';
