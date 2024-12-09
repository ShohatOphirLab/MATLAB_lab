%%

command = '"C:\Program Files\R\R-4.1.2\bin\x64\Rscript.exe" main_for_hcluster.R ';

cd D:\MATLAB\runAll\litalHcluster

prompt = {'insert font size'};
dlgtitle = 'parameters';
dims = [1 35];
definput = {'12'};
opts.Resize = 'on';
answer_size = inputdlg(prompt,dlgtitle,dims,definput,opts);
font= str2num(answer_size{1});
tables_params=table(font);

baseFileName = 'params.xlsx';
path_of_xlsx_params = fullfile(pwd, baseFileName);
writetable(tables_params,baseFileName)

[status,cmdout]=system(command,'-echo');
    