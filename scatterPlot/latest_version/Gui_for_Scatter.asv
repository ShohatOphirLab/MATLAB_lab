
command = '"C:\Program Files\R\R-4.1.2\bin\x64\Rscript.exe" main.R ';
expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath =suggestedPath;
numOfGroups = length(expGroups);

prompt = {'insert height window size','insert width window size','insert font size','insert x-axis size(abs value)','insert dot size'};
dlgtitle = 'parameters';
dims = [1 35];
definput = {'12','12','5','3','1'};
opts.Resize = 'on';
answer_size = inputdlg(prompt,dlgtitle,dims,definput,opts);
height= str2num(answer_size{1});
width =str2num(answer_size{2});
font =str2num(answer_size{3});
xsize =str2num(answer_size{4});
dot =str2num(answer_size{5});


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

answer_format = questdlg('what is the formant you would like to save the results?', ...
	'pdf or jpeg', ...
	'pdf','jpeg','jpeg');
% Handle response
switch answer_format
    case 'pdf'
        disp([answer_format ' choosen '])
       format = 1;
    case 'jpeg'
        disp([answer_format ' choosen '])
        format = 2;
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
tables_params=table(height,width,font,xsize,change,deleted,dot,format);

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