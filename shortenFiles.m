
prompt = {'Enter start frame:','Enter end frame:'};
title = 'Enter Frames';
dims = [1 35];
definput = {'0','inf'};
answer = inputdlg(prompt,title,dims,definput);


allFolders = uipickfiles('Prompt', 'Select Folders To Fix');
for i = 1:length(handles.allFolders)
    folderPath = allFolders{i};

end