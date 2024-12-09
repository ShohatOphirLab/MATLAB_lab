
function [maxGroupInteractions, foldersNames] = creat_expdata_onlycsv(param, allFolders, csvFileName, groupName)


interactions = [];
noInteractions = [];
maxGroupInteractions = -1;

foldersNames = cell(length(allFolders) + 1, 2);
foldersNames{1, 1} = [groupName, ' length of interacions file names'];
foldersNames{1, 2} = [groupName, ' number of interacions file names'];

 
for i = 1:length(allFolders)
    folderPath = allFolders{i};
    fileName = fullfile(folderPath, param.jaabaFileName);
    [COMPUTERPERFRAMESTATSSOCIAL_SUCCEEDED,savenames] = onlysavenames('matname', fileName);
    [filepath,~,~] = fileparts(savenames{1});
    txtFileNameLength = fullfile(filepath, ['interactionMatrix_frame_', num2str(param.startFrame), '_to_', num2str(param.endFrame), '_gap_', num2str(param.oneInteractionThreshold), '_interaction_length.txt']);
    txtFileNameNumber = fullfile(filepath, ['interactionMatrix_frame_', num2str(param.startFrame), '_to_', num2str(param.endFrame), '_gap_', num2str(param.oneInteractionThreshold), '_interaction_number.txt']);
    foldersNames{i + 1, 1} = txtFileNameLength;
    foldersNames{i + 1, 2} = txtFileNameNumber;
end