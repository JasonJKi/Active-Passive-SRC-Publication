close all; clear all;
rootDir = '../../'; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set figure inputs and outputs
eegType = 'eeg_jason_'; % specify eeg processing 
eegVersion = 'v1';

stimulusType = 'optical_flow'; % Set specification for stimulus 

leaveOneOutTrain = true;
crossValStatusStr = '';
if leaveOneOutTrain
    crossValStatusStr = '_cross_validated';
end

additionalStr = '_v0';
% additionalStr = ''; 

% load all computed values
computedValuesDir = [rootDir 'output/computed_values/'];
computedValueName = ['cca_analysis_pooled_eeg_jason_'...
                    eegVersion '_svd_reduction_' ...
                    stimulusType '_kx30_ky11' ...
                    crossValStatusStr additionalStr];
computedValuePath = [computedValuesDir computedValueName];
load(computedValuePath, 'input_for_analysis');

% load metadata of experiment conditions
computedValueMetadataPath = [computedValuesDir 'metadata_inputs_for_analysis_final'];
load(computedValueMetadataPath, 'metadata');
input_for_analysis.metadata = metadata;
input_for_analysis.conditionStr = {'Active Play','Sham Play','Passive Viewing'};
input_for_analysis.conditionStrXTick = {'  Active\newline   Play', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};
barColor = [0 1 0; 1 0 0; 0 0 1];
input_for_analysis.conditionColor = {[1 0 0],[0 0 1], [0 .75 0]};
input_for_analysis.deceptionColor = {[.1 .1 0], [.6 .45 .6]}; 

% load stimuls and eeg used in analysis
dataDir = [rootDir 'output/data_processed_for_analysis/'];  
load([dataDir eegType eegVersion], 'Eeg'); % [nSamples x nChannels]
load([dataDir stimulusType '_mean_trf'], 'X'); % [nSamples x temporal delay]
input_for_analysis.Eeg = Eeg; input_for_analysis.Stimulus = X;
input_for_analysis.locFile = 'JBhead96_sym.loc';

% Set figure output folder
figureDir = [rootDir 'output/figures/final/' stimulusType];
if strcmp(additionalStr, '_v0'); figureDir = 'output/figures/final/'; end
if ~exist(figureDir, 'dir'); mkdir(figureDir); end

% Set supplementary figure output folder
supFigureDir = ['output/figures/final/supplementary/'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figureSize = [15,410,850,570];
[fig4, stats4] = generate_figure_6(input_for_analysis, figureSize);

figureSize = [15,410,850,570];
[fig6, stats6] = generate_figure_s2(input_for_analysis, figureSize);
print([figureDir '/figure_8'],'-dpng','-r0');


[fig, stats] = generate_figure_6(inputs, windowSize)

% figure 7 
figureSize = [725,0,1180,1000];
[figS1b, statsS1b] = generate_figure_s1(input_for_analysis, figureSize,'alpha');
print([supFigureDir 'figure_7'],'-dpng','-r0');


% figure S3 - Mu activity. Compare powers for across condition for individual electrodes
figureSize = [730 280 1170 690];
[figS3a, statsS3a] = generate_figure_s3(input_for_analysis, figureSize,'alpha');
print([figureDir 'figure_9'],'-dpng','-r0');

figureSize = [1220,140,680,840];
[fig6, stats6] = generate_figure_6(input_for_analysis, figureSize);
print([figureDir '/figure_6'],'-dpng','-r0');

figureSize = [100 100 950 950];
[figS1a, statsS1b] = generate_figure_3_(input_for_analysis, figureSize);

load([dataDir eegType eegVersion], 'Eeg'); % [nSamples x nChannels]
load([dataDir stimulusType '_mean_trf'], 'X'); % [nSamples x temporal delay]
input_for_analysis.Eeg = Eeg; input_for_analysis.Stimulus = X;

figureSize = [420,461,1372,422];
[figS5, statsS5] = generate_figure_s6(input_for_analysis, figureSize);
print([supFigureDir 'figure_s5_deveid_vs_not_deceived'],'-dpng','-r0');

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optional figures
% figure S1 - power comparison for individual component
supFigureDir = ['output/figures/analysis/'];

figureSize = [725,0,1180,1000];
[figS1b, statsS1b] = generate_figure_s1(input_for_analysis, figureSize,'alpha');
print([supFigureDir 'figure_s1_alpha'],'-dpng','-r0');

% figure S4 - image motion
stimulusType = 'image_motion';
computedValueName = ['cca_analysis_pooled_eeg_jason_'...
                    eegVersion '_svd_reduction_' ...
                    stimulusType '_kx30_ky11' ...
                    crossValStatusStr];
computedValuePath = [computedValuesDir computedValueName];
load(computedValuePath, 'input_for_analysis');
load(computedValueMetadataPath, 'metadata');
input_for_analysis.metadata = metadata;
input_for_analysis.conditionStr = {'Active Play','Sham Play','Passive Viewing'};
input_for_analysis.conditionStrXTick = {'  Active\newline   Play', ...
    ' Sham\newline  Play', ...
    'Passive\newlineViewing'};

figureSize = [100 100 950 950];
[figS1a, statsS1a] = generate_figure_s4(input_for_analysis, figureSize);
print([supFigureDir '/figure_s1_' stimulusType],'-dpng','-r0');


figureSize = [805 333 987 550];
[figS5, statsS5] = generate_figure_s5(input_for_analysis, figureSize, 'deceived');
print([supFigureDir 'figure_s5_deceived'],'-dpng','-r0');

figureSize = [805 333 987 550];
[figS5, statsS5] = generate_figure_s5(input_for_analysis, figureSize, 'not deceived');
print([supFigureDir 'figure_s5_not deceived'],'-dpng','-r0');

