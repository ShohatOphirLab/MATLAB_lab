

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

command = '"C:\Program Files\R\R-4.2.0\bin\x64\Rscript.exe" creatExpNet.R ';
expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath = uigetdir(suggestedPath, 'Select folder to save csv file');
numOfGroups = length(expGroups);

prompt = {'insert height window size','insert width window size','insert font size','insert asterisk size'};
dlgtitle = 'parameters';
dims = [1 35];
definput = {'12','12','5','3'};
opts.Resize = 'on';
answer_size = inputdlg(prompt,dlgtitle,dims,definput,opts);
height= str2num(answer_size{1});
width =str2num(answer_size{2});
font =str2num(answer_size{3});
asterisk =str2num(answer_size{4});


answer_change = questdlg('Would you like to run from the beginning or only change visual?', ...
	'run or vizual', ...
	'change vizual','run from the beginning','run from the beginning');
% Handle response
switch answer_change
    case 'change vizual'
        disp([answer_change ' start running vizual soon '])
        change = 2;
    case 'run from the beginning'
        disp([answer_change ' lets start from the beginning '])
        change = 1;
end

answer_delete = questdlg('wish to delete paramters files at the end?', ...
	'delete or keep', ...
	'delete','keep','keep');
% Handle response
switch answer_delete
    case 'delete'
        disp([answer_delete ' will be deleted '])
        deleted = 1;
    case 'keep'
        disp([answer_delete ' wont be deleted '])
        deleted = 0;
end

answer_format = questdlg('what format do you want to save?', ...
	'pdf or jpeg', ...
	'pdf','jpeg','jpeg');
% Handle response
switch answer_format
    case 'pdf'
        disp([answer_format ' pdf choosen '])
        format =2;
    case 'jpeg'
        disp([answer_format ' jpeg choosen '])
        format = 1;
end
if (change == 1)
xlsxFileName = fullfile(savePath, ['expData_', num2str(param.startFrame), '_to_', num2str(param.endFrame), '.xlsx']);
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
    [maxGroupInteractions, foldersNames] = runOneGroupInteractions(param, allFolders, xlsxFileName, groupName);
    if size(foldersNames, 1) > size(data, 1)
        cellsToAdd = cell(size(foldersNames, 1) - size(data, 1), size(data, 2));
        data = [data; cellsToAdd];
    elseif size(foldersNames, 1) < size(data, 1)
        cellsToAdd = cell(size(data, 1) - size(foldersNames, 1), size(foldersNames, 2));
        foldersNames = [foldersNames; cellsToAdd];
    end
    data = [data, foldersNames];

    maxExperimentInteractions = max(maxExperimentInteractions, maxGroupInteractions);
end

maxInter = cell(size(data, 1), 1);
maxInter{1} = 'Max number of interaction';
maxInter{2} = maxExperimentInteractions;
data = [data, maxInter];
xlswrite(xlsxFileName, data);
end

color ="";
groupNameDir =[];
colorValue=[];

groupNameDir=expGroups';

for i =1:numOfGroups
s1='Select a color for ';
[~,currentGroupName,~]=fileparts(groupNameDir(i));
displayOrder =char(strcat(s1,{' '},currentGroupName));
c = uisetcolor([1 1 0],displayOrder);
color_in_char =[];
color_in_char= sprintf(' %f', c)
colorValue = [colorValue;c];
end
tables=table(groupNameDir,colorValue);
tables_params=table(height,width,font,asterisk,change,deleted,format);

OriginFolder = pwd;
folder=savePath;
if ~exist(folder, 'dir')
    mkdir(folder);
end
cd(folder)
baseFileName = 'color.xlsx';
path_of_xlsx = fullfile(folder, baseFileName);
writetable(tables,baseFileName)

baseFileName = 'params.xlsx';
path_of_xlsx_params = fullfile(folder, baseFileName);
writetable(tables_params,baseFileName)
cd(OriginFolder)
command = append(command,path_of_xlsx) 
[status,cmdout]=system(command,'-echo');