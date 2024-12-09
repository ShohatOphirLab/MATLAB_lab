command = '"C:\Program Files\R\R-4.1.2\bin\x64\Rscript.exe" gene_scatter_all.R ';
prompt = {'how many population:'};
dlgtitle = 'number of population';
dims = [1 35];
definput = {'2'};
answer = inputdlg(prompt,dlgtitle,dims,definput)
num_of_pop=str2double(char(answer))

prompt = {'insert height window size','insert width window size','insert dot size','insert font size','insert x-axis size(abs value)','change visual(1) or run(2)?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'12','12','4','5','3','2'};
answer_size = inputdlg(prompt,dlgtitle,dims,definput)


height= str2num(answer_size{1});
width =str2num(answer_size{2});
dot =str2num(answer_size{3});
font =str2num(answer_size{4});
xsize =str2num(answer_size{5});
change_or_run=str2num(answer_size{6});
color ="";
group_name =[]
color_value=[];


for i =1:num_of_pop
s1='Select a color for group number ';
s2 = uigetdir('C:\','choose your pop');
group_name=strvcat(group_name,s2)
s = append(s1,s2);
c = uisetcolor([1 1 0],s)
color_in_char =[];
color_in_char= sprintf(' %f', c)

color_value = [color_value;c];
end
tables=table(group_name,color_value);
tables_params=table(height,width,dot,font,xsize,change_or_run);

OriginFolder = pwd;
dname = uigetdir();
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
