function [fig, stats] = generate_figure_6(inputs, windowSize)
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
textSizePanelTitle = 12;
textSizeLegend = 12;
textSizeTitle = 18;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = conditionColor;
erpColor = [.1 .2 .3];

% get condition index
indexPlay = find(conditionIndex==1);
indexBci = find(conditionIndex==2);
indexWatch = find(conditionIndex==3);
indices = {indexPlay, indexBci, indexWatch};

fs = 30;
dim = fs;
numComponents = 3;
for i = 1:numConditions
    iCondition = i;
    
    subjectIndex = indices{iCondition};
    Eeg_ = Eeg(subjectIndex);
    Stimulus_ = Stimulus(subjectIndex);
    eeg = cat(1,Eeg_{:});
    Ryy{i} = nancov(eeg);

    h=[];
    numSubjects = length(Eeg_);
    
    for ii = 1:numSubjects
        iSubject = ii;
        
        eeg = Eeg_{iSubject};
        eeg(isnan(eeg)) = 0;

        stimulus = Stimulus_{iSubject};
        stimulus = stimulus*A;
        
        % Compute the spatial weights of eeg.
        for iii = 1:numComponents
            X = eeg;
            y = stimulus(:,iii);
            h(ii,iii,:) = y\X;
        end
    end
    W_{i} = h; 
end

fig = figure(6); clf
fig.Position = windowSize;
[ha1, pos1] = tight_subplot(1,numComponents,[.15 .15],[.7 0.25],[.2 .15]);
[ha2, pos2] = tight_subplot(3,numComponents,[.0 .05],[.05 .35],[.1 .1]);
AH = forwardModel(A, rxx);

panelLabel1 = char(65:90);
panelLabel2 = char(68:90);

iter = 1
for i = 1:numConditions
    for ii = 1:numComponents
        if i == 1
            
            %Plot forward model of the canoncal temporal filters.
            axes(ha1(ii)); hold on
            
            AH_ = AH(1:fs,ii);
            t = 0:fs-1;

            plot(t, AH_,'Color',erpColor,'LineWidth', 2);
            set(gca,'XTick',0:fs/2:fs,'XTickLabel',0:1000/2:1000, 'FontSize', 8); 
            yMin = min(AH_);yMax = max(AH_);
            ylim([yMin yMax]*1.2)
            xlabel('time (ms)')
            title(['Component ' num2str(ii)], 'FontWeight', 'Normal', 'FontSize', textSizePanelTitle);

            yMax = max(AH_);
            yMaxIndex = find(AH_ == yMax);
            tMax(ii) = t(yMaxIndex)/fs;

            yMin = min(AH_);
            yMinIndex = find(AH_ == yMin);
            tMin(ii) = t(yMinIndex)/fs;

            h=text(-20,0+.7,panelLabel1(ii),'FontSize',textSizePanelTitle, 'FontWeight','Normal');            
        end

        subplotIndex = (i-1)*numComponents+ii;
        
        % Create topoplot for the each of the run conditions.
        axes(ha2(subplotIndex)); hold on
        wAll = squeeze(W_{i}(:,ii,:));
        wMean = nanmean(wAll);
        wMeanAll{i,ii} = wMean;
        AW = forwardModel(wMean',Ryy{i});
        locFile = 'JBhead96_sym.loc';
        topoplot(AW,locFile,'conv','off','style','map','whitebk','on','plotrad',0.45,'headrad',.45);
        
        % Reposition the topoplot to fit the entireity of x and y axes.
        xLim = get(gca,'Xlim');
        yLim = get(gca,'Ylim');
        set(gca,'XLim', xLim*1.1);
        set(gca,'YLim', yLim*1.1);

        % Create colorbar axis for the topoplot
        minY = min(AW);
        maxY = max(AW);
        if abs(minY) > abs(maxY)
            yLim = abs(maxY);
        else
            yLim = abs(minY);
        end

        cAxis = [-yLim, 0, yLim];
        cAxis = round(cAxis, 1);
        cAxisTickLabel = {cAxis(1), '\muV', cAxis(3)};
        cbh = colorbar('location','westoutside');
        colormap jet
        set(cbh,'YTick',cAxis,'YTickLabel',cAxisTickLabel,'TickLabelInterpreter', 'tex')
        set(cbh,'YLim',[-yLim*1.2, yLim*1.2])

        t1 = title(panelLabel2(iter), 'FontSize', textSizePanelTitle, 'FontWeight','Normal');
        set(t1,'Position',[t1.Position(1)-1 t1.Position(2)+.2 0])
        iter = iter + 1;
        
        % Add title for the each of the conditions.
        if mod(subplotIndex,3) == 1
            h=text(-2+.9,0-.5, conditionStr{i},'FontSize',textSizeYAxis);
            set(h,'Rotation',90);
        end
    end
end

comparisons = {'gameplay vs bci'; 'gameplay vs watch'; 'bci vs watch'};
comparisonIndex = [1 2; 1 3; 2 3];
for i = 1:3
    conditionIndex1 = comparisonIndex(i,1);
    conditionIndex2 = comparisonIndex(i,2);
    for ii = 1:3
        iComponent = ii;
        x = wMeanAll{conditionIndex1,iComponent}';
        y = wMeanAll{conditionIndex2,iComponent}';
        theta(i,ii) = acos((x'*y)/(sqrt(x'*x)*sqrt(y'*y)))*180;
    end
end
stats.theta=theta;
stats.tMax = tMax;
stats.tMin = tMin;
fig.PaperPositionMode = 'auto';    
