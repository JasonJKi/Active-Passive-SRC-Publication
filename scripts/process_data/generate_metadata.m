close all; clear all;clc
% This script analyzes preprocessing pipeline for eeg for most optimal and robust eeg signal.
% metadata for input data
rootDir = '../../';
dataDir = 'data/supertuxkart-active-passive/';
metadataTablePath  = [rootDir dataDir 'metadata/metadataTableFinal.mat'];
load(metadataTablePath);
[nRaces, nVariables] = size(metadataTable);

outputDataDir = 'output/data_processed_for_analysis/';


% indexRaceID = [1:74 104:139];
indexRaceID = 1:height(metadataTable);
iter = 1;
subjectIDunique = 1; prevSubjectID = 0;
for iFile = indexRaceID
    
    % Get file information from the metadata table
    fileDir = metadataTable.matFileDir{iFile};
    subjectID = metadataTable.subject(iFile);
    subjectIDStr = num2str(subjectID);
    trialNumber =  metadataTable.trial(iFile);
    trialNumberStr = num2str(trialNumber);
    conditionStr = metadataTable.condition{iFile};
    engagementRating = metadataTable.engagementRating(iFile);
    fileID = metadataTable.fileID(iFile);    
    mockBciSuccess = metadataTable.MockBCISuccess(iFile);
    fileIDStr = num2str(fileID);
    
    % Create metadata index for the working set of races.
    fileIDIndex(iter) = fileID;
    conditionStrIndex{iter} = conditionStr;
    trialNumberIndex(iter) = trialNumber;
    subjectIDIndex(iter)= subjectID;
    engagementRatingIndex(iter) = engagementRating;
    mockBciSuccessIndex(iter) = mockBciSuccess;

    uniqueConditionIDIndex{iter} = [conditionStr subjectIDStr];

    nRuns = iter;
    iter = iter + 1;
end

[conditionIndex,conditionNames] = grp2idx(conditionStrIndex);

indexPlay = find(conditionIndex == 1);
indexBci = find(conditionIndex == 2);
indexWatch = find(conditionIndex == 3);
 
indexAll = [subjectIDIndex' conditionIndex trialNumberIndex' engagementRatingIndex' mockBciSuccessIndex'];
indexAllPlay = indexAll(indexPlay,:);
indexAllBci = indexAll(indexBci,:);
indexAllWatch = indexAll(indexWatch,:);

subjectIDs = unique(subjectIDIndex);
numSubjects = length(subjectIDs);

[uniqueConditionIndex,uniqueConditionNames] = grp2idx(uniqueConditionIDIndex);
save([outputDataDir '/metadata'], 'uniqueConditionIndex', 'uniqueConditionNames', 'conditionIndex', 'subjectIDIndex', 'subjectIDs', 'engagementRatingIndex', 'mockBciSuccessIndex');


%% Prepare metadata for final inputs for analysis

numUniqueConditions = max(uniqueConditionIndex);
for i = 1:numUniqueConditions
    indice = find(uniqueConditionIndex == i);
    metadata.conditionIndexGrouped(i, :) = mean(conditionIndex(indice));
    metadata.engagementRatingIndex(i, :)  = mean(engagementRatingIndex(indice));
    deceptionIndex_(i, :)  = mean(mockBciSuccessIndex(indice));
    subjectIDIndex_(i,:) = mean(subjectIDIndex(indice));
end
metadata.indexPlay = find(metadata.conditionIndexGrouped == 1);
metadata.indexBci = find(metadata.conditionIndexGrouped == 2);
metadata.indexWatch = find(metadata.conditionIndexGrouped == 3);
metadata.engagementRatingPlay = metadata.engagementRatingIndex(metadata.indexPlay);
metadata.engagementRatingBci = metadata.engagementRatingIndex(metadata.indexBci);
metadata.engagementRatingWatch = metadata.engagementRatingIndex(metadata.indexWatch);
metadata.uniqueConditionIndex = uniqueConditionIndex;
metadata.mockBciSuccessIndex = mockBciSuccessIndex';
deceivedSubjectsIndex = subjectIDIndex_(find(deceptionIndex_ == 1))
deceivedSubjectID = unique(deceivedSubjectsIndex);
subjectIDs = unique(subjectIDIndex);
numSubjects = length(subjectIDs);
deceptionIndex = zeros(numSubjects, 1);
for i = 1:numSubjects
    if sum(subjectIDs(i) == deceivedSubjectID) == 1
        deceptionIndex(i) = 1;
    end
end
metadata.deceptionIndex = deceptionIndex;
save(['output/computed_values/metadata_inputs_for_analysis_final'],'metadata');


