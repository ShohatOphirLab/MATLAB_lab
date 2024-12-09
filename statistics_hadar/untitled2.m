%%
BoutLength = {};
interBout = {};

%%
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
%%
% getting all the paths and some other data
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

    condition{j} = conditionNames{condi};
 
    NumberofMovie{j} = j;
end

condition = condition';

NumberofMovie = NumberofMovie';

TMPtables=table(groupNameDir,NumberofMovie,condition);
%%
for numberMovie = 1:numOfGroups; 
        name_of_the_file = char(TMPtables{numberMovie,1});
        name_of_the_condition = TMPtables{numberMovie,3};
        number_of_movie = TMPtables{numberMovie,2};
           
        cd(name_of_the_file)
        for jj=1:length(allBehaviors);
            
            load(cell2mat(allBehaviors(jj)))
            
            for ii =1:length(allScores.postprocessed)
                data = cell2mat(allScores.postprocessed(ii)); % per fly
                counter = 0;
                bl_vector = {};
                first_bout = 0;
                for b =1:length(data)
                    if data(b)==1 & not(first_bout)
                        counter = 1;
                        first_bout = 1;
                    elseif data(b) == 1;
                        counter = counter+1;
                    elseif data(b)==0 & not(first_bout)
                        if counter>10
                            bl_vector = 
                            counter = 0;
                        end
                    end

                end 
            end

                 
        end
end