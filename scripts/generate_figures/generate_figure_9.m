function [fig, stats] = generate_figure_9(inputs, windowSize)
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
[plotHandleGroup1, pos1] = tight_subplot(2,3,[.01 .01], [.7 .05], [0.125 0.05]);
[plotHandleGroup2, pos2] = tight_subplot(2,3,[.01 .01], [.375 .375], [0.125 0.05]);
[plotHandleGroup3, pos3] = tight_subplot(2,3,[.01 .01], [.05 .7], [0.125 0.05]);
plotHandles = {plotHandleGroup1, plotHandleGroup2, plotHandleGroup3};

panelLabelIndex = [1 4 7 2 5 8 3 6 9];iter = 1;
%% Create topoplot for the each of the run conditions.
for i = 1:numComponents
    iComp = i;
     A = [];
    for ii = 1:numConditions
        
        iCond = ii;
        w = W{iCond}(:,:,iComp);
        
        for iii = 1:size(w,1)
            A(iii,:,iComp) = forwardModel(w(iii,:)', ryy); % RyyCond{iCond}
        end
        AMean = nanmean(A(:,:,iComp));

        % Create topomap object to draw contour over electrodes.
        val = AMean;
        plotHandle = plotHandles{iCond}(iComp);
        
        topoPlot = setMap(Topomap('JBhead96_sym.loc'));
        topoPlot.setPlotHandle(plotHandle);
        topoPlot.drawMaskHeadRing(.5);
        topoPlot.drawNoseAndEars(.5);
        topoPlot.formatPlot(plotHandle);
        topoPlot.draw(val);

        % set color axes for the topoplot
        minY = min(AMean);
        maxY = max(AMean);

        colorMapVal = jet;
        colorAxisRange = round([minY, maxY],1);
        topoPlot.setColorAxis(colorAxisRange, colorMapVal);

        % Draw color bar to indicate color axis scale.
        cAxis = [colorAxisRange(1), mean(colorAxisRange), colorAxisRange(2)];
        cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
        topoPlot.setColorBar(cAxis, cAxisTickLabel);

            
        if ii == 1
            title(['Component ' num2str(iComp)],'FontWeight','Normal', 'FontSize', textSizeYLabel)
        end
        
        if i == 1
            h = text(-2, -.6, conditionStr(iCond), 'FontWeight','Normal', 'FontSize', textSizeYLabel);
            set(h,'Rotation',90);
        end
        
        text(-1.5, .8, panelLabel(panelLabelIndex(iter)), 'FontSize',textSizePanelTitle, 'FontWeight','Normal')    
        iter = iter + 1;
        h = H{iCond}(:,(1:fs),iComp);
        hMean = nanmean(h);

        y = hMean;
        x = 0:fs-1;
        
        plotHandle = plotHandles{iCond}(iComp+numConditions);

        axes(plotHandle);hold on
        p = plot(x,y,'Color',barColor{iCond});
        stdshade(h,.25, barColor{iCond}, x)
        
        if iCond ==3
        set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', textSizeXAxis)
        xlabel('Time (ms)')
        else
            set(gca,'XTick',0:fs/5:fs,'XTickLabel',[], 'FontSize', textSizeXAxis)
        end
        ylim([-.75 .75] )
        set(gca,'color','none')
        
        
        if iComp == 1
            set(gca,'YTick',-1:.5:1,'YTickLabel',num2str((-1:.5:1)','%0.1f'), 'FontSize', textSizeXAxis);
            ylabel('Amplitude (a.u.)')
        end
        
        templPointsHandle(ii) = p;
        box off
        

    end

        
    stats = [];
end

