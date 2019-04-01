function [fig, stats] = generate_figure_s5(inputs, windowSize)
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
deceivedIndex = mockBciSuccessIndex == 1;
% if strcmp(deception,'deceived')
%      deceivedIndex = mockBciSuccessIndex == 1;
% else
%     deceivedIndex = mockBciSuccessIndex == 0;
% end
% figure parameters
textSizeXAxis = 12;
textSizeYAxis = 16;
textSizeYLabel = 18;
textSizeXLabel = 18;
textSizePanelTitle = 18;
textSizeLegend = 12;
textSizeTitle = 18;
subjectColor = [.85 .75 .65];
errorBarColor = [.65 .75 .86];
barColor = [0 .5 .8; .25 .25 .8; .5 .5 .8];
conditionStr = {'Active Play','Sham Play','Passive Viewing'};
conditionStrXTick = {'  Active\newlinePlay', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};
% get condition index
indexPlay = conditionIndex==1;
indexBci = conditionIndex==2;
indexWatch = conditionIndex==3;
conditionIndices = {indexPlay, indexBci, indexWatch};
conditionChosen = 2;

numSamples = cellfun('length',Eeg);
minSample = min(numSamples);
% Compute temporal response of the canonical correlation components of EEG
fs = 30;
numComponents = 3;
numChannels = 96;
lag = fs;

deceptionIndex = {deceivedIndex, ~deceivedIndex};
for i = 1:2
    conditionIndex_ = conditionIndices{conditionChosen};
    subjectIndex = deceptionIndex{i} & conditionIndex_;
    Eeg_ = Eeg(subjectIndex);
    Stimulus_ = Stimulus(subjectIndex);
    
    h=[];
    numSubjects = length(Eeg_);
    for ii = 1:numSubjects
        iSubject = ii;
        eeg = Eeg_{iSubject};
        nanIndex = isnan(eeg);
        eeg(nanIndex) = 0;
        stimulus = Stimulus_{iSubject}(:,1:end-1);
        
        [tStimWh, mu, invMat, whMat] = whiten(stimulus);

        for iii = 1:numChannels
            x = tStimWh(:,1);

            y = eeg(:,iii);
            r = xcorr(y,x,lag);
            crossCorr(:,ii,iii) = r;
        end
    end
    R{i} = crossCorr;
end
% figure;clf;hold on
% subplot(2,1,1)
% [acs, lags] = xcorr(x,'coeff');
% plot(lags/30,acs)
% xlim([-30 30])
% subplot(2,1,2)
% [acs, lags] = xcorr(e ,'coeff');
% plot(lags/30,acs)
% xlim([-30 30])

fig = figure(10); clf
fig.Position = windowSize;
stats = [];
ozElectrodes = {'oz','o1', 'o2'};
ozChannelIndices = [30, 29, 31];
plotIndex = 1;
deceptionColors = {[1 0 0], [0 0 1]}
deceptionStr = {'Deceived' 'Not Deceived'}
for i = 1:3
    subplot(1,3,i); hold on
    for ii = 1:2
        crossCorr = squeeze(R{ii}(:,:,ozChannelIndices(i)));
        yAll = crossCorr;
        y = mean(crossCorr');
        
        ind=(lag:2*lag);
        x=(ind-lag)/fs;

        plotIndex = plotIndex + 1;

        p(ii) = plot(x',y(ind),'Color',deceptionColors{ii});
        stdshade(yAll(ind,:)',.25, deceptionColors{ii}, x);
        xlim([0 1])
    end
    title(ozElectrodes{i})
    if i==3
        l1 = legend(p,deceptionStr);
        set(l1,'FontSize',textSizeLegend)
        set(l1,'Location','NorthWest')
        set(l1, 'Box', 'off');
        set(l1, 'Position', [l1.Position(1)+.15 l1.Position(2) l1.Position(3) l1.Position(4)]);
    end
end

% 
% 
% % Perform multiple comparison of H at each time point for the conditons
% hPlay = H{1};
% hBci = H{2};
% hWatch = H{3};
% 
% for i = 1:numComponents
%     for ii = 1:fs
%         hPlay_  = squeeze(hPlay(:,i,ii));
%         hBci_ = squeeze(hBci(:,i,ii));
%         hWatch_ = squeeze(hWatch(:,i,ii));
%         
%         [pvalPlayBci(ii,i), HPlayBci(ii,i), statsPlayBci] = ranksum(hPlay_, hBci_, 'method','approximate');
%         [pvalPlayWatch(ii,i), HPlayWatch, statsPlayWatch] = ranksum(hPlay_, hWatch_, 'method','approximate');
%         [pvalBciWatch(ii,i), HWatchBci, statsWatchBci] = ranksum(hWatch_, hBci_, 'method','approximate');
%         zPlayBci(ii,i) = statsPlayBci.zval;
%         zPlayWatch(ii,i) = statsPlayWatch.zval;
%         zWatchBci(ii,i) = statsWatchBci.zval;
%         pAll = [pvalPlayBci(ii,i) pvalPlayWatch(ii,i) pvalBciWatch(ii,i)];
%         [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pAll,.05,'dep','yes');
%     
%         pvalPlayBciCorrected(ii,i) = adj_p(1);
%         pvalPlayWatchCorrected(ii,i) = adj_p(2);
%         pvalWatchBciCorrected(ii,i) = adj_p(3);
%         
%         hPlayBciCorrected(ii,i) = h(1);
%         hPlayWatchCorrected(ii,i) = h(2);
%         hWatchBciCorrected(ii,i) = h(3);
%     end
% end
% 
% 
% % Plot time points of the h where there is significant difference between
% % conditions.
% p1_ = [];p2_=[];p3_=[];
% for i = 1:3
%     axes(ha2(i)); hold on
%     [hPlayBci(:,i), crit_p, adj_ci_cvrg, adj_pvalPlayBci]=fdr_bh(pvalPlayBci(:,i),.05,'dep','yes');
%     [hPlayWatch(:,i), crit_p, adj_ci_cvrg, adj_pvalPlayWatch]=fdr_bh(pvalPlayWatch(:,i),.05,'dep','yes');
%     [hBciWatch(:,i), crit_p, adj_ci_cvrg, adj_pvalBciWatch]=fdr_bh(pvalBciWatch(:,i),.05,'dep','yes');
%     pvalPlayBci_ = adj_pvalPlayBci;
%     pvalPlayWatch_ = adj_pvalPlayWatch;
%     pvalBciWatch_ = adj_pvalBciWatch;
% %     pvalPlayBci_ = pvalPlayBci(:,i);
% %     pvalPlayWatch_ = pvalPlayWatch(:,i);
% %     pvalBciWatch_ = pvalBciWatch(:,i);
%     sigPlayBci = pvalPlayBci_<.05;
%     sigPlayWatch = pvalPlayWatch_<.05;
%     sigWatchBci =pvalBciWatch_<.05;
%     indexPlayBci = find(sigPlayBci);
%     indexPlayWatch = find(sigPlayWatch);
%     indexWatchBci = find(sigWatchBci);
%     p1=plot(indexPlayBci, -.75*sigPlayBci(indexPlayBci)-.05 ,'.','Color',barColor(:,1));
%     p2=plot(indexPlayWatch,-.75*sigPlayWatch(indexPlayWatch)-.1 ,'*','Color',barColor(:,2));
%     p3=plot(indexWatchBci,-.75*sigWatchBci(indexWatchBci)-.15 ,'*','Color',barColor(:,3));
%     
%     if ~isempty(p1); p1_=p1;end
%     if ~isempty(p2); p2_=p2;end    
%     if ~isempty(p3); p3_=p3;end
% end
% conditionStr = {'Manual Gameplay','Sham BCI','Passive Viewing', 'manual vs sham','manual vs passive', 'sham vs passive'};
% legend([p(1) p(2) p(3) p1_ p2_ p3_],conditionStr,'FontSize',textSizeLegend)
% legend boxoff  
% 
% stats=[];
% fig.PaperPositionMode = 'auto';
% 
% 
% 
