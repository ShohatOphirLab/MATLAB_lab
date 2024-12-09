function [conditionNames, conditionName] = extractConditionName()
% conditionNames = name of the condition
% conditionName = path of the condition


% condition list names

conditionName = uipickfiles('Prompt', 'Select condition folders');
[suggestedPath, ~, ~] = fileparts(conditionName{1});

conditionNames = [];

conditionNames = conditionName';

for j = 1:length(conditionNames);
    fileNamePath = conditionNames(j);
    findStr = strfind(fileNamePath,"\"); % search for a specific str to extract conditionName
    findStr = cell2mat(findStr);
    vecLen = length(findStr);
    conditionNames{j} = conditionNames{j}(findStr(end)+1:end);
end

end