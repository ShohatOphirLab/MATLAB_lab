command = '"C:\Program Files\R\R-4.1.2\bin\x64\Rscript.exe" creatExpNet.R ';
prompt = {'how many population:'};
dlgtitle = 'number of population';
dims = [1 35];
definput = {'2'};
answer = inputdlg(prompt,dlgtitle,dims,definput)
num_of_pop=str2double(char(answer))

prompt = {'insert height window size','insert width window size','insert font size','insert asterisk size','wish to delete the paramters file?(1-yes,0-no if no please remmber delete manually)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'12','12','5','3','0'};
answer_size = inputdlg(prompt,dlgtitle,dims,definput)


height= str2num(answer_size{1});
width =str2num(answer_size{2});
font =str2num(answer_size{3});
asterisk =str2num(answer_size{3});
delete =str2num(answer_size{5});

color ="";
group_name =[]
color_value=[];


for i =1:num_of_pop
s1='Select a color current group ';
s2 = uigetdir('C:\','choose the directory where the files of the experiment located');
group_name=strvcat(group_name,s2)
c = uisetcolor([1 1 0],s1)
color_in_char =[];
color_in_char= sprintf(' %f', c)

color_value = [color_value;c];
end
tables=table(group_name,color_value);
tables_params=table(height,width,font,asterisk,delete);

OriginFolder = pwd;
dname = uigetdir('C:\','please choose temporary directory to save paramter files');
folder = dname;
if ~exist(folder, 'dir')
    mkdir(folder);
end
cd(dname)
baseFileName = 'color.xlsx';
path_of_xlsx = fullfile(folder, baseFileName);
writetable(tables,baseFileName)

baseFileName = 'params.xlsx';
path_of_xlsx_params = fullfile(folder, baseFileName);
writetable(tables_params,baseFileName)
cd(OriginFolder)
command = append(command,path_of_xlsx) 
%[status,cmdout]=system(command,'-echo');
