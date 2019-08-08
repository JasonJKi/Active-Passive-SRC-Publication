s% static strings for the naming and file designation
rootDir = '../../';
dataDir = 'data/supertuxkart-active-passive/';
conditionStrs = {
    'play'
    'bci'
    'watch'
    }
matStr = 'mat';
vidStr = 'avi'; 
xdfStr = 'xdf'; 
vidAppendStr = 'downsampled';
metadataDir = [rootDir dataDir 'metadata/']
surveyResponseTable = readtable([metadataDir 'engagement_reseponse_survey_final.xlsx']);

iFile = 1;
for j=13:35
    subjectNumStr = ['0' num2str(j)];
    for jj = 1:3
        % inpt data path
        conditionStr = conditionStrs{jj};
        
        % data directory and path handling
        subjectDir = [subjectNumStr '/' conditionStr '/'];
        xdfDir = [subjectDir xdfStr  '/'];
        matDir = [subjectDir matStr '/'];
        vidDir = [subjectDir vidStr '/downsampled/'];
        if ~exist([rootDir dataDir matDir])
            mkdir([rootDir dataDir matDir])
        end
        
        formatQuery = ['*.' xdfStr];
        
        xdfList = dir([rootDir dataDir xdfDir formatQuery]);
        vidList = dir([rootDir dataDir vidDir '*.' vidStr]);
        nFiles = length(xdfList);
        if nFiles < 1
            disp('no files to read')
            continue;
        end
        
        for jjj = 1:nFiles
            % xdf file name conventions and path
            xdfFlieName = xdfList(jjj).name;
            xdfFilePath = [rootDir dataDir xdfDir xdfFlieName];
            disp(['#' num2str(iFile) ' reading in stream from ' xdfFilePath])
            xdfFlieNameFull = xdfFlieName;
            xdfFlieName = xdfFlieName(1:end-4);

            % avi file names
            vidFileName = vidList(jjj).name;
            vidFilePath = [rootDir dataDir vidDir vidFileName];
            % parsing file name for meta data
            i_underscore =  strfind(xdfFlieName,'_');
            i_trial = i_underscore(end);
            trialStr = xdfFlieName(i_trial+1:end);
            dateStr = xdfFlieName([1:(i_underscore(1)-1), (i_underscore(1)+1):(i_underscore(2)-1), (i_underscore(2)+1):(i_underscore(3)-1)]);
            matFileName = [subjectNumStr '_' conditionStr  '_' trialStr '_' dateStr '.' matStr];
            subjectNum = str2num(subjectNumStr);  
            trialNum =  str2num(trialStr);            
            
            matFilePath = [matDir matFileName];

            indexSubject = find(surveyResponseTable.subjectNumber ==  subjectNum);
            mockBCISuccess = surveyResponseTable.MockBCISuccessful(indexSubject);
            usable = surveyResponseTable.usable(indexSubject);
            age = surveyResponseTable.Age(indexSubject);

            if strcmp(conditionStr,'play')
                engagementRating = surveyResponseTable.engagementPlay(indexSubject);
            elseif strcmp(conditionStr, 'bci')
                engagementRating = surveyResponseTable.engagementBci(indexSubject);
            elseif strcmp(conditionStr, 'watch')
                engagementRating = surveyResponseTable.engagementWatch(indexSubject);
            else
                engagementRating = nan;
            end
            databaseInfo(iFile,:) = {iFile, matDir, matFileName, xdfDir, xdfFlieNameFull, vidDir, vidFileName, dateStr, conditionStr, subjectNum, trialNum, engagementRating, mockBCISuccess, usable, age};
            iFile = iFile+1;
        end
    end
end

metadataTable = cell2table(databaseInfo);
metadataTable.Properties.VariableNames = {'fileID' 'matFileDir' 'matFileName' ...
    'xdfFileDir' 'xdfFileName' 'vidDir' ...
    'vidFileName' 'date' 'condition' 'subject' 'trial' 'engagementRating' 'MockBCISuccess' 'usable' 'age'};
writetable(metadataTable,[metadataDir 'metadataTableFinal.csv'])
save([metadataDir 'metadataTableFinal.mat'],'metadataTable')

% 
% 
% dataPath='C:/Users/JacekSuper/Dropbox/ARL/';
% dataPathSuper='D:/ARL/';
% 
% % Check existence of corresponding video features with eeg
% iFile = 1;
% for i = 13:35
%     subjStr=['0' num2str(i)];
%     for ii = 1:3
%         condStr=conditionStrs{ii};
%         % all mat files (both features and eeg) should be saved on the dropbox
%         matDataPath=[dataPath 'data/' subjStr '/'  condStr '/mat/'];
%         stimFilenames=dir([matDataPath '*-features-*.mat']);
%         nFiles = length(stimFilenames);
%         for iii = 1:nFiles
%             featureNames{iFile}=stimFilenames(iii).name;
%             strIndex=strfind(featureNames{iii},'-features')-1;
%             videoNames{iFile}=[featureNames{iii}(1:strIndex) '.avi'];
%             iFile = iFile + 1;
%         end  
%     end
% end
