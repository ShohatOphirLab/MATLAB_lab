%%

command = '"C:\Program Files\R\R-4.1.1\bin\x64\Rscript.exe" main_dynamic.R ';

%creat interaction matrix ,per frame features avarge 
%for spcific number of mvoies
jaabaFileName = 'registered_trx.mat';
param = struct();
param.interactionsNumberOfFrames = 60;
param.interactionsDistance = 8;
param.interactionsAnglesub = 0;
param.oneInteractionThreshold = 120;
param.startFrame = 0;
param.endFrame = 27001;
%i can change here to false and get undirected network parametrs
param.directed = false;
%param.interactionLength = true;
%do angelsub mean calculate angelsub as parametrs of interaction
%false mean only use distnace for interatcion
param.doAngelsub = true;
interactions = [];
noInteractions = [];




answer_change = questdlg('Would you like to run with Angelsub or withOut ?', ...
	'Angelsub or Not', ...
	'Angelsub','Not','Angelsub');
% Handle response
switch answer_change
    case 'Angelsub'
        disp([answer_change ' you choose with Angelsub '])
        param.doAngelsub = true;
    case 'Not'
        disp([answer_change ' you choose withOut Angelsub '])
        param.doAngelsub = false;
end


handles.allFolders = uipickfiles('Prompt', 'Select movies to run inteactions');
for i = 1:length(handles.allFolders)
    folderPath = handles.allFolders{i};
    if(not((isfile(fullfile(folderPath, 'AllinteractionWithAngelsub.mat')))|| (isfile(fullfile(folderPath, 'Allinteraction.mat')))))
    fileName = fullfile(folderPath, jaabaFileName);
    [COMPUTERPERFRAMESTATSSOCIAL_SUCCEEDED,savenames] = compute_perframe_stats_social_f('matname', fileName);
    %creat Allinteraction or AllinteractionWithAngelsub based on doAngelsub
    %give what frame have interactions
    [newInteractions, newNoInteractions] = computeAllMovieInteractionsAllinteraction(savenames, param);
    else 
        folderPath
    end
    
%     if(not(isfile(fullfile(folderPath, 'per_framefeatures_sum_allflies.csv'))))
%          fileName = fullfile(folderPath, "perframe");
%     all=[];
%     current_dir_cell_features=struct2cell(dir(fullfile(fileName)));
% for feature =3:length(current_dir_cell_features)
%         featureName=current_dir_cell_features{1,feature}
%         load(fullfile(fileName,featureName))
%         perFrameAvgAllFlies=zeros(1,param.endFrame);
% %calculating avarge
% for j=1:param.endFrame
%     sum_per_frame=sum(cellfun(@(v)v(j),data));
%     perFrameAvgAllFlies(j)=sum_per_frame;
% end
% %flipping 
%     horizen_perFrameAvgAllFlies=perFrameAvgAllFlies';
%     table_of_current_perframe = array2table(horizen_perFrameAvgAllFlies, 'VariableNames',{featureName});
%     all=horzcat(all,table_of_current_perframe);
% end
% 
%     fullPath2Csv=fullfile(folderPath,"per_framefeatures_sum_allflies.csv");
%     %avarge per frame of all features
%     writetable(all,fullPath2Csv)
%     else
%     end
end




    %where to save the tmp list of dirs the user choose
%     fullPath_files=fullfile(dname,"\choosen_files.csv");
%     writecell( handles.allFolders, fullPath_files);
    
    
     color ="";
    groupNameDir =[];
    colorValue=[];

    groupNameDir=handles.allFolders';

    
    numOfiles = length(handles.allFolders);

    for i =1:numOfiles
    s1='Select a color for ';
    
    [~,currentGroupName,~]=fileparts(groupNameDir(i));
    displayOrder =char(strcat(s1,{' '},currentGroupName));
    c = uisetcolor([1 1 0],displayOrder);
    color_in_char =[];
    color_in_char= sprintf(' %f', c)
    colorValue = [colorValue;c];
    end
    tables=table(groupNameDir,colorValue);
    
    dname = uigetdir(handles.allFolders{1},'where to save the list of files and colors you chooce?');
    fullPath_colors=fullfile(dname,"\choosen_files_colors.csv");
    writetable( tables, fullPath_colors);
    
    command = append(command,fullPath_colors) 
    [status,cmdout]=system(command,'-echo');
    

%%


