function [maxGroupInteractions, foldersNames] = runOneGroupInteractions(param, allFolders, groupName)
interactions = [];
noInteractions = [];
maxGroupInteractions = -1;

foldersNames = cell(length(allFolders) + 1, 2);
foldersNames{1, 1} = [groupName, ' length of interacions file names'];
foldersNames{1, 2} = [groupName, ' number of interacions file names'];

 
for i = 1:length(allFolders)
    folderPath = allFolders{i};
    fileName = fullfile(folderPath, param.jaabaFileName);
   [COMPUTERPERFRAMESTATSSOCIAL_SUCCEEDED,savenames] = compute_perframe_stats_social_f('matname', fileName);
    [newInteractions, newNoInteractions, txtFileName] = computeAllMovieInteractions_new(savenames, param);
    interactions = [interactions, newInteractions];
    noInteractions = [noInteractions, newNoInteractions];
end
