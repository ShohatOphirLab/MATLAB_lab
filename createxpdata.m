function [maxGroupInteractions, foldersNames] = createxpdata(param, allFolders, groupName)
interactions = [];
noInteractions = [];
maxGroupInteractions = -1;

foldersNames = cell(length(allFolders) + 1, 2);
foldersNames{1, 1} = [groupName, ' length of interacions file names'];
foldersNames{1, 2} = [groupName, ' number of interacions file names'];

 
for i = 1:length(allFolders)
    folderPath = allFolders{i};
    fileName = fullfile(folderPath, param.jaabaFileName);
    foldersNames{i + 1, 1} = txtFileNameLength;
    foldersNames{i + 1, 2} = txtFileNameNumber;
end
