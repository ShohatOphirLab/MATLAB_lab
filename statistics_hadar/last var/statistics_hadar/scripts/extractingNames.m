function [allBehaviors, allFeatures] = extractingNames()

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

% tmp tmp
% extracting all the features per frame names
cd("perframe")
featurefileName = "*.mat";
d = dir(featurefileName);
featurefileName = {d.name};

allFeatures = featurefileName;

disp("seccesfully finish to extract behavior names and features name")
end