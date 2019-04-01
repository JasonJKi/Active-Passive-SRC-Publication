# Stimulus Response Analysis for active vs passive visual processing of video game

0) load_all_deps = loads all dependencies necessary for the current project

1) generate_data_index.m - creates metadata for each runs of supertuxkart
2) compute_video_features.m - computes various video features (TODO)
3) generate_data_for_analysis.m - creates organized data set for analysis of stimulus response correlation (SRC) 
4) compute_stimulus_response_correlation_cca_with_crossvalid - trains cca weights and computes SRC of individual race by leave-one-out cross validation process.
5) generate_all_figures.m = generates the figures for publication 

For access to eeg and video data
Download @ (TBD)
place the eeg and video file in the folder output/data_processed_for_analysis
