function [fig, stats] = generate_figure_1_panel(inputs)
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
conditionStr = {'Manual Gameplay','Sham BCI','Passive Viewing'};

%% Compute and draw time-resolved CCA rhos for SRC Illustration for the three race conditions 
fs = 30;
slideTime = 5;
slidWindow = fs*slideTime;
slideShift = 1; 
raceLengths = cell2mat(cellfun(@length,Eeg,'uni',false));
nRaces = length(raceLengths);
minTime = min(raceLengths);
T = floor(minTime/fs -slideTime-1);
startIndex = 0 ;

for iRace = 1:nRaces
    eeg = Eeg{iRace};
    stimulus = Stimulus{iRace};
    for iTime = 1:(T/slideShift)

    timeIndex = (1:slidWindow) + (slideShift*fs)*iTime + startIndex;
    
    eeg_ = eeg(timeIndex,:);
    nanIndex = isnan(eeg_);
    eeg_(nanIndex) = 0;
    
    stimulus_ = stimulus(timeIndex,:);
    rhoThimeResolved(iRace, iTime,:) = computeCorrelation(eeg_*B,stimulus_*A);
    end
end

indexPlay_ = find(conditionIndex == 1);
indexBci_ = find(conditionIndex == 2);
indexWatch_ = find(conditionIndex == 3);

rhoTimePlay = rhoThimeResolved(indexPlay_,: ,:);
rhoTimeBci = rhoThimeResolved(indexBci_,: ,:);
rhoTimeWatch = rhoThimeResolved(indexWatch_,: ,: );

%% Plot the Tme resolved SRCs 
rhoTimePlaySum = sum(rhoTimePlay,3);
rhoTimeBciSum = sum(rhoTimeBci,3);
rhoTimeWatchSum = sum(rhoTimeWatch,3);

rhoTimePlaySumMean = mean(rhoTimePlaySum);
rhoTimeBciSumMean = mean(rhoTimeBciSum);
rhoTimeWatchSumMean = mean(rhoTimeWatchSum); 

rhoPlayStd = std(rhoTimePlaySum)/length(rhoTimePlaySum);
rhoBciStd = std(rhoTimeBciSum)/length(rhoTimeBciSum);
rhoWatchStd = std(rhoTimeWatchSum)/length(rhoTimeWatchSum);

X = (startIndex + slideShift):slideShift:T;

fig = figure(1);clf
hold on;
srcOffset = [0, 0, 0];
p1_ = plot(X, rhoTimePlaySumMean+srcOffset(3), 'Color',  [0 .5 1], 'LineWidth',1.5);
p2_ = plot(X,rhoTimeBciSumMean+srcOffset(2), 'Color',  [.25 .25 .8], 'LineWidth',1.5);
p3_ = plot(X, rhoTimeWatchSumMean+srcOffset(1), 'Color',  [.5 .0 .5], 'LineWidth',1.5);

% p1_.Color(4) = 0.1;
% p2_.Color(4) = 0.1;
% p3_.Color(4) = 0.1;

% stdshade(rhoTimePlaySum+srcOffset(3), .05, [0 .5 1])
% stdshade(rhoTimeBciSum+srcOffset(2), .05, [.25 .25 .8])
% stdshade(rhoTimeWatchSum+srcOffset(1), .05, [.5 .0 .5])

p1 = plot(X, repmat(mean(rhoTimePlaySumMean),T,1), '--', 'Color', [0 .5 1]);
p2 = plot(X, repmat(mean(rhoTimeBciSumMean),T,1), '--',  'Color', [.25 .25 .8]);
p3 = plot(X, repmat(mean(rhoTimeWatchSumMean),T,1), '--',  'Color', [.5 .0 .5]);
legend([p1_ p2_ p3_],{'Active', 'Sham Active', 'Passive'}, 'FontSize', 12);
legend boxoff

xPos = 0:30:T;
set(gca,'YTick',[-.5:.25:1], 'FontName','Arial','FontSize',8);
set(gca,'XTick', xPos, 'FontName','Arial','FontSize',7);
xlabel('Time (s)', 'FontSize', 15)
ylabel('Stimulus-Response Correlation', 'FontSize', 16)
ylim([-.25 .5]);
xlim([0 T]); 
stats=[];
box off
% t0 = title('C', 'FontSize', 15);
% set(t0,'Position',[-8 t0.Position(2) 0])

fig.PaperPositionMode = 'auto';
