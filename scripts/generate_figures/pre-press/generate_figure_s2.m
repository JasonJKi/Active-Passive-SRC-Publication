function [fig, stats] = generate_figure_s2(inputs, windowSize)
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
textSizeYAxis = 16;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 18;
textSizeLegend = 15;
textSizeTitle = 18;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
% barColor = [0 .5 .8; .25 .25 .8; .5 .5 .8];
barColor = conditionColor;

conditionStr = {'Active Play','Sham Play','Passive Viewing'};
conditionStrXTick = {'  Active\newlinePlay', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};
% get condition index
indexPlay = find(conditionIndex==1);
indexBci = find(conditionIndex==2);
indexWatch = find(conditionIndex==3);
indices = {indexPlay, indexBci, indexWatch};

% Compute temporal response of the canonical correlation components of EEG
fs = 30;
numComponents = 3;
for i = 1:3
    iCondition = i;
    subjectIndex = indices{iCondition};
    Eeg_ = Eeg(subjectIndex);
    Stimulus_ = Stimulus(subjectIndex);

    h=[];
    numSubjects = length(Eeg_);
    for iii = 1:numSubjects
            iSubject = iii;
            eeg = Eeg_{iSubject};
            nanIndex = isnan(eeg);
            eeg(nanIndex) = 0;
            eeg = eeg*B;
            stimulus = Stimulus_{iSubject};
        for ii = 1:numComponents
            y = eeg(:,ii);
            X = stimulus;
            h_ = y\X;
%             h(iii,ii,:) = h_ - repmat(mean(h_),1,length(h_));
            h(iii,ii,:) = h_;

%             h(iii,ii,:) = h_ - repmat(h_(1,1),1,length(h_));
        end
    end
    H{i} = h; 
end

fig = figure; clf
fig.Position = windowSize;
[ha2, pos2] = tight_subplot(1,3,[.15 .05],[.15 .15],[.10 .225]);
[ha1, pos1] = tight_subplot(1,3,[.15 .05],[.75 0.175],[.10 0.225]);

% Get EEG Forward Model
AW = forwardModel(B, ryy);
locFile = 'JBhead96_sym.loc';

for i = 1:3    
    for ii = 1:numComponents


        % plot corresponding temporal filter for each of the conditions

        axes(ha2(ii));hold on
        hAll = squeeze(H{i}(:,ii,(1:fs)));
%         hAll = hAll_ - repmat(hAll_(1,:),length(hAll_),1);
        hMean = nanmean(hAll);
        y = hMean;
        x = 0:fs-1;
        sem = stdError(hAll);

        p(i) = plot(x,y,'Color',barColor{i});
        stdshade(hAll,.25, barColor{i}, x)
        set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', textSizeXAxis)

        yMin = min(hMean);yMax = max(hMean);
        if abs(yMin) > abs(yMax)
            yLim = abs(yMin);
        else
            yLim = abs(yMax);
        end
        ylim([-.75 .75] )
        set(gca,'color','none')
        
        xlabel('Time (ms)')
        
        if ii == 1
            set(gca,'YTick',-1:.5:1,'YTickLabel',num2str((-1:.5:1)','%0.2f'), 'FontSize', textSizeXAxis)
            ylabel('\muV')
        end
        
        box off
        title(['Component ' num2str(ii)],'FontSize',textSizePanelTitle,'FontWeight','Normal');
        
        panelLabel1 = char(65:90);
        text(-2,.9,panelLabel1(ii),'FontSize',textSizePanelTitle, 'FontWeight','Normal');            

        if i ==3
            %topoplot forward model of EEG Canoical component
            
            axes(ha1(ii));hold on
            colormap jet
            topoplot(AW(:,ii),locFile,'conv','off','style','map','whitebk','on','headrad','rim');
            xLim = get(gca,'Xlim');
            yLim = get(gca,'Ylim');
            set(gca,'XLim', xLim*1.1);
            set(gca,'YLim', yLim*1.1);
            minY = min(AW(:,i));
            maxY = max(AW(:,i));
            if abs(minY) > abs(maxY)
                yLim = abs(maxY);
            else
                yLim = abs(minY);
            end
            
            pos = get(ha1(ii),'pos');
            set(ha1(ii),'pos', [pos(1)-.06, pos(2)-0.575, pos(3), pos(4)])

        end
        
    end
    
    if i==3
        l1 = legend(p,conditionStr);
        set(l1,'FontSize',textSizeLegend)
        set(l1,'Location','NorthWest')
        set(l1, 'Box', 'off');
        set(l1, 'Position', [l1.Position(1)+.15 l1.Position(2) l1.Position(3) l1.Position(4)]);

        % <= Change This Line
        
    end
end

% Perform multiple comparison of H at each time point for the conditons
hPlay = H{1};
hBci = H{2};
hWatch = H{3};

for i = 1:numComponents
    for ii = 1:fs
        hPlay_  = squeeze(hPlay(:,i,ii));
        hBci_ = squeeze(hBci(:,i,ii));
        hWatch_ = squeeze(hWatch(:,i,ii));
        
        [pvalPlayBci(ii,i), HPlayBci(ii,i), statsPlayBci] = ranksum(hPlay_, hBci_, 'method','approximate');
        [pvalPlayWatch(ii,i), HPlayWatch, statsPlayWatch] = ranksum(hPlay_, hWatch_, 'method','approximate');
        [pvalBciWatch(ii,i), HWatchBci, statsWatchBci] = ranksum(hWatch_, hBci_, 'method','approximate');
        zPlayBci(ii,i) = statsPlayBci.zval;
        zPlayWatch(ii,i) = statsPlayWatch.zval;
        zWatchBci(ii,i) = statsWatchBci.zval;
        pAll = [pvalPlayBci(ii,i) pvalPlayWatch(ii,i) pvalBciWatch(ii,i)];
        [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pAll,.05,'dep','yes');
    
        pvalPlayBciCorrected(ii,i) = adj_p(1);
        pvalPlayWatchCorrected(ii,i) = adj_p(2);
        pvalWatchBciCorrected(ii,i) = adj_p(3);
        
        hPlayBciCorrected(ii,i) = h(1);
        hPlayWatchCorrected(ii,i) = h(2);
        hWatchBciCorrected(ii,i) = h(3);
    end
end


% Plot time points of the h where there is significant difference between
% conditions.
p1_ = [];p2_=[];p3_=[];
for i = 1:3
    axes(ha2(i)); hold on
    [hPlayBci(:,i), crit_p, adj_ci_cvrg, adj_pvalPlayBci]=fdr_bh(pvalPlayBci(:,i),.05,'dep','yes');
    [hPlayWatch(:,i), crit_p, adj_ci_cvrg, adj_pvalPlayWatch]=fdr_bh(pvalPlayWatch(:,i),.05,'dep','yes');
    [hBciWatch(:,i), crit_p, adj_ci_cvrg, adj_pvalBciWatch]=fdr_bh(pvalBciWatch(:,i),.05,'dep','yes');
%     pvalPlayBci_ = adj_pvalPlayBci;
%     pvalPlayWatch_ = adj_pvalPlayWatch;
%     pvalBciWatch_ = adj_pvalBciWatch;
    pvalPlayBci_ = pvalPlayBci(:,i);
    pvalPlayWatch_ = pvalPlayWatch(:,i);
    pvalBciWatch_ = pvalBciWatch(:,i);
    sigPlayBci = pvalPlayBci_<.05;
    sigPlayWatch = pvalPlayWatch_<.05;
    sigWatchBci =pvalBciWatch_<.05;
    indexPlayBci = find(sigPlayBci);
    indexPlayWatch = find(sigPlayWatch);
    indexWatchBci = find(sigWatchBci);
    p1=plot(indexPlayBci, repmat(.60,length(indexPlayBci),1),'.','Color',barColor{1});
    p2=plot(indexPlayWatch,repmat(.65,length(indexPlayWatch),1) ,'*','Color',barColor{2});
    p3=plot(indexWatchBci,repmat(.7,length(indexWatchBci),1) ,'*','Color',barColor{3});
    
    if ~isempty(p1); p1_=p1;end
    if ~isempty(p2); p2_=p2;end    
    if ~isempty(p3); p3_=p3;end
end
conditionStr = {'Manual Gameplay','Sham BCI','Passive Viewing', 'manual vs sham','manual vs passive', 'sham vs passive'};
legend([p(1) p(2) p(3) p1_ p2_ p3_],conditionStr,'FontSize',textSizeLegend)
legend boxoff  

stats=[];
fig.PaperPositionMode = 'auto';
