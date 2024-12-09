function WidthFormat4Personality(cd_for_saved_data,WhatSex)
%WhatSex = 1;
%% width format for personalty project
cellBehavior={};
counter = 0;

%% tmp tmp
% extracting all the behavior scores names

% select example scores file for extracting names:
expGroups = uipickfiles('Prompt', 'Select experiment scores file');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath =suggestedPath;

cd(savePath)
scoresfileName = "scores_*.mat";
d_scores = dir(scoresfileName);
scoresfileName = {d_scores.name};
allBehaviors = scoresfileName;

% extracting all the features per frame names
cd("perframe")
featurefileName = "*.mat";
d = dir(featurefileName);
featurefileName = {d.name};

allFeatures = featurefileName;


%% getting all the paths and some other data
% partly from lital script: "creat_pathcsv.m"
expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
[suggestedPath, ~, ~] = fileparts(expGroups{1});
savePath =suggestedPath;
numOfGroups = length(expGroups);


groupNameDir = [];

groupNameDir = expGroups';
NumberofMovie = {1:numOfGroups}';
condition = {};

for j = 1:numOfGroups;
    fileNamePath = groupNameDir(j); % all path file name
    findStr = strfind(fileNamePath,"\"); % search for a specific str to extract conditionName
    findStr = cell2mat(findStr);
    vecLen = length(findStr);
    char_fileNamePath = char(fileNamePath);
    condition{j} = char_fileNamePath(findStr(vecLen-1)+1:findStr(vecLen)-1);
    if strfind(char_fileNamePath,"Male");
       sex{j} = "Males";
    elseif strfind(char_fileNamePath,"Female");
        sex{j} = "Females";
    else
        sex{j} = [];
    end

    NumberofMovie{j} = j;
end

condition = condition';
sex = sex';
NumberofMovie = NumberofMovie';

TMPtables=table(groupNameDir,NumberofMovie,condition,sex);

 %%

for numberMovie = 1:numOfGroups; 
    name_of_the_file = char(TMPtables{numberMovie,1});
    name_of_the_condition = TMPtables{numberMovie,3};
    number_of_movie = TMPtables{numberMovie,2};
 
    cd(name_of_the_file)
    for jj=1:length(allBehaviors);
        
        load(cell2mat(allBehaviors(jj)))
        
        
        ii = length(allScores.postprocessed);
        
               
        for numFly=1:ii

            behavoirPerFlieScore = allScores.postprocessed{1,numFly};
            cellBehavior{numFly+counter,1}=numFly; % cellBehavior(1)="fly";
            cellBehavior{numFly+counter,2}=name_of_the_file; % cellBehavior(2)="name of the file";
            cellBehavior{numFly+counter,3}=numberMovie; % cellBehavior(3)="movie number";
            cellBehavior{numFly+counter,4}=char(TMPtables.sex{numberMovie}); %TMPtables(numberMovie,4); % cellBehavior(4)="sex";
            cellBehavior{numFly+counter,5}=name_of_the_condition; % cellBehavior(5)="condition";

            cellBehavior{numFly+counter,jj+5}={behavoirPerFlieScore}; % cellBehavior(7)="scores";
                       
           
        end
         
    end
    % here will be the features loop

    cd("perframe")

    for jj=1:length(allFeatures);

        load(cell2mat(allFeatures(jj)), 'data')

        for numFly=1:ii
            cellBehavior{numFly+counter,5+length(allBehaviors)+jj} = data{numFly};
        end


    end

    counter=counter+ii;
end
%%
% Convert cell to a table and use first row as variable names

Title_old=["fly","name of the file","movie number","sex","condition"];
TitleNames = [Title_old,allBehaviors,allFeatures]; 
allDatainTbl = cell2table((cellBehavior),'VariableNames',TitleNames);

% Write the table to a CSV file
%writetable(allDatainTbl,'myDataFile.csv')
%% extract only valid behaviors
%fullTable = cat(1, fly.segs.table);

varNames = regexprep(regexprep(allDatainTbl.Properties.VariableNames, '.mat', ''), ' ', '_');

allDatainTbl.Properties.VariableNames = varNames;

if WhatSex==1;
    fly.validBehaviors = readtable('D:\Fly_personality_Oren\Code\females_behavior.xlsx');
elseif WhatSex == 2;
    fly.validBehaviors = readtable('D:\Fly_personality_Oren\Code\behaviors_males');
end
removeMovies = [];
fly.dict = dictionary(fly.validBehaviors.Var1, fly.validBehaviors.Var2);
allDatainTbl(:, fly.dict(allDatainTbl.Properties.VariableNames) == 0) = [];

allDatainTbl(ismember(allDatainTbl.movie_number, removeMovies), :) = [];
%% save as mat

cd(cd_for_saved_data)
% if the above is to big (more than 2 GB)
save -V7.3 allDatainTbl.mat allDatainTbl
%end