close all; clear all;
rootDir = '../'; 
addpath('generate_figures')
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

% Set supplementary figure output folder
supFigureDir = [rootDir 'output/figures/final/supplementary/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% figure 1 - experiement, data, analysis. 
% generate_figures/generate_figure_1.pptx (slide 8 final)

%% figure 2 - spatial forward model and temporal filter of stimulus.
figureSize = [11,513,800,483];
[fig2, stats2] = generate_figure_2(input_for_analysis, figureSize);
print([figureDir '/figure_2'],'-dpng','-r0');

%% figure 3 - Panel A. comparison of src/engagement rating across conditions.
% Panel B. comparison of src for individual components 
figureSize = [100 100 950 800];
[fig3, stats3] = generate_figure_3(input_for_analysis, figureSize);
print([figureDir '/figure_3'],'-dpng','-r0');

%% figure 4 - Panel A. comparison of src across deceived vs not deceived
% subjects. Panel B. comparison of engagement rating deceived vs not
% deceived.
figureSize = [100 100 950 500];
[fig4, stats4] = generate_figure_4(input_for_analysis, figureSize);
print([figureDir '/figure_4'],'-dpng','-r0');

%% figure 5 - Panel A. Comparison of Alpha power for each viewing condition.
% Panel B. Difference of Mu activity for Active vs Passive and Sham Active
% vs Passive.
figureSize = [730 280 1170 690];
[fig5, stats5] = generate_figure_5(input_for_analysis, figureSize,'alpha');
print([figureDir 'figure_5'],'-dpng','-r0');

%% figure 6 - Panel A. Comparison of broadband power across condition. Panel
% B. Comparison of alpha power across condition.
figureSize = [100,200,1000,650];
[fig6, stats6] = generate_figure_6(input_for_analysis, figureSize);
print([figureDir '/figure_6'],'-dpng','-r0');

%% figure 7 - Temporal response functions and Spatial Forward Models 
% A. Forward models and which electrodes they differ in
% B. TRFs 
figureSize = [8.2,48.2,945.6,950.4];
[fig7, stats7] = generate_figure_7(input_for_analysis, figureSize);
print([figureDir '/figure_7'],'-dpng','-r0');

%% figure 9
figureSize = [8.2,48.2,945.6,950.4];
[fig9, stats9] = generate_figure_9(input_for_analysis, figureSize);
print([figureDir '/figure_9'],'-dpng','-r0');

%% figure 8 - temporal contrast
stimulusType = 'temporal_contrast';
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
input_for_analysis.conditionColor = {[1 0 0],[0 0 1], [0 .75 0]};
input_for_analysis.deceptionColor = {[.2 .1 0], [.55 .45 .6]}; 
input_for_analysis.locFile = 'JBhead96_sym.loc';

% figureSize = [11,513,800,483];
% [fig2, stats2] = generate_figure_2_(input_for_analysis, figureSize);
% % print([figureDir '/figure_2'],'-dpng','-r0');
figureSize = [0 500 1000 400];
[fig, stats] = generate_figure_s1_2(input_for_analysis, figureSize);
print([figureDir '/figure_8'],'-dpng','-r0');

return






