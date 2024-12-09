

param = struct();
param.interactionsNumberOfFrames = 60;
param.interactionsDistance = 8;
param.interactionsAnglesub = 0;
param.oneInteractionThreshold = 120;
param.startFrame = 0;
param.endFrame = 27000;
param.directed = false;
param.jaabaFileName = 'registered_trx.mat';
maxExperimentInteractions = -1;

expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath = uigetdir(suggestedPath, 'Select folder to save csv file');
numOfGroups = length(expGroups);

xlsxFileName = fullfile(savePath, ['expData_', num2str(param.startFrame), '_to_', num2str(param.endFrame),'only_paths', '.xlsx']);
groupNumber = [{'Number of groups'; numOfGroups}; cell(numOfGroups - 1, 1)];
groupNames = cell(numOfGroups + 1, 1);
groupNames{1} = 'Groups names';
groupLength = cell(numOfGroups + 1, 1);
groupLength{1} = 'Number of movies';
data = [groupNumber, groupNames, groupLength];
for i = 1:numOfGroups
    [~, groupName, ~] = fileparts(expGroups{i});
    data{i + 1, 2} = groupName;
    d = dir(expGroups{i});
    isub = [d(:).isdir];
    allFolders = {d(isub).name}';
    allFolders(ismember(allFolders,{'.','..'})) = [];
    allFolders = fullfile(expGroups{i}, allFolders);
    data{i + 1, 3} = length(allFolders);
    [maxGroupInteractions, foldersNames] = creat_expdata_onlycsv(param, allFolders, xlsxFileName, groupName);
    if size(foldersNames, 1) > size(data, 1)
        cellsToAdd = cell(size(foldersNames, 1) - size(data, 1), size(data, 2));
        data = [data; cellsToAdd];
    elseif size(foldersNames, 1) < size(data, 1)
        cellsToAdd = cell(size(data, 1) - size(foldersNames, 1), size(foldersNames, 2));
        foldersNames = [foldersNames; cellsToAdd];
    end
    data = [data, foldersNames];

end


xlswrite(xlsxFileName, data);
