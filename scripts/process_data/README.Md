a. data processing 
Epoching
1. epoch_streams.m -  epoch streams based on the photodiode triggers from the video stimulus.
2. epoch_video.m - epoch video data based on the flash occuring in the top right side of the video.
Data handling
3. generate_metadata.m - handling information about all streams. It output csv file for the video/stimulus information.
Synchonization of time and sampling rate
4. synchronize_video_and_streams.m - synchronize and align samples for epoched streams and video 

b. EEG data processing
Denoising
- outlier rejection.
- rpca.
- low pass and notch filtering for drift removal and electrical noise.
- eye movement regression.

c. Video feature extraction
- optical flow
- temporal contrast
- local contrast
- etc.
