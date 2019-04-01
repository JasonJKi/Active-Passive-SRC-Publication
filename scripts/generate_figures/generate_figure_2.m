function [fig, stats] = generate_figure_2(inputs, windowSize)
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
textSizeXLabel = 12;
textSizePanelTitle = 13;
textSizeLegend = 12;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;
erpColor = [.1 .2 .3];
panelLabel = char(65:90);

%% Perform comparison tests. 
subjectIndex = 1:numSubjects;
H = A;
W = B;
if exist('AReg','var')
    H = AReg;
    rxx = rxxReg;
    W = BReg;
    ryy = ryyReg;
end
A = forwardModel(W, ryy);

numComponentsToPlot = 4;
fig = figure(2); clf;
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1, numComponentsToPlot, [.05 .1], [.4 .00], [.075 .025]);
[ha2, pos2] = tight_subplot(1, numComponentsToPlot, [.05 .05], [.15 .5], [.075 .025]);

%% Plot topography of the forward model for each component
for i = 1:numComponentsToPlot
    
    val = A(:,i);
    if i == 3
        val = -val;
    end
 
    plotHandle = ha1(i);
    
    scalpPlot = ScalpPlot('JBhead96_sym.loc');
    scalpPlot.setMap();
    scalpPlot.setPlotHandle(plotHandle);
    scalpPlot.draw(val);
    
    % Draw color bar to indicate color axis scale.
    colorMapVal = jet;
    minVal = min(val);
    maxVal = max(val);
    absMin = min(abs(minVal),abs(maxVal));
    absMax = max(abs(minVal),abs(maxVal));
    meanVal = mean([minVal maxVal]);
    colorAxisRange = [minVal maxVal];
    cAxis = [minVal meanVal maxVal];
    cAxisTickLabel = {num2str(minVal, '%0.0f'), '\muV', num2str(maxVal,'%0.0f')};
    scalpPlot.setColorAxis(colorAxisRange, colorMapVal);
    scalpPlot.drawColorBar(cAxis, cAxisTickLabel, 'westoutside');
    
    text(-.8, .8 ,panelLabel(i),'FontSize',textSizePanelTitle, 'FontWeight','Normal');
    title(['Component ' num2str(i)], 'FontSize', textSizePanelTitle, 'FontWeight','Normal');
end

%% Plot temporal filter of the stimulus for each condition.
for i = 1:numComponentsToPlot
    axes(ha2(i));hold on;
    fs = 30;
    t = 0:fs-1;
    h = H(1:fs,i);
    
    if i == 3
        h = -h;
    end
    
    
    plot(t, h,'Color',erpColor ,'LineWidth', 2);
    
    
    if i == 1
        ylabel('Amplitude (a.u.)')
    end
    
    set(gca,'XTick',0:fs/2:fs-1,'XTickLabel',0:1000/2:1000, 'FontSize', textSizeXLabel);
    set(gca,'YTick',(-1:.5:1),'YTickLabel', (-1:.5:1), 'FontSize', textSizeXLabel);
    
    
    set(gca,'YLim', [-.75 .75]);
    
    minH = min(h);
    maxH = max(h);
    minT = (find(h == minH) - 1)/fs;
    maxT = (find(h == maxH) - 1)/fs;
    stats.peakTimes(i,:) = [minT maxT];
    stats.peaks(i,:) = [minH maxH];

    if i == 11
        l1 = legend(conditionStr,'Location','East','FontSize',textSizeLegend);
        legend boxoff
        set(l1,'Position',[0.7085    0.155    0.175     0.162])
    end
end

stats.pAnova = [];
stats.anovaStats = [];

end
