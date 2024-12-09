% main GH for correlation visualization and stats

% extracting name behaviors and condition list
[allBehaviors, allFeatures] = extractingNames();
[~, conditionName] = extractConditionName();

%%

%loading the data
cd(conditionName{5})
gh1 = table2cell(readtable('myDataFileGroupedHouse1.csv','VariableNamingRule','preserve'));
gh1 = gh1(1:(size(gh1,1)-2),3:end);
cd(conditionName{4})
gh3 = table2cell(readtable('myDataFileGroupedHouse3.csv','VariableNamingRule','preserve'));
gh3 = gh3(1:(size(gh3,1)-2),3:end);
cd(conditionName{3})
gh5 = table2cell(readtable('myDataFileGroupedHouse5.csv','VariableNamingRule','preserve'));
gh5 = gh5(1:(size(gh5,1)-2),3:end);
cd(conditionName{2})
gh10 = table2cell(readtable('myDataFileGroupedHouse10.csv','VariableNamingRule','preserve'));
gh10 = gh10(1:(size(gh10,1)-2),3:end);
cd(conditionName{1})
gh20 = table2cell(readtable('myDataFileGroupedHouse20.csv','VariableNamingRule','preserve'));
gh20 = gh20(1:(size(gh20,1)-2),3:end);


%%
a = [20*ones(1,size(gh20,1)) 10*ones(1,size(gh10,1)) 5*ones(1,size(gh5,1)) 3*ones(1,size(gh3,1)) 1*ones(1,size(gh1,1))];
colorsRGB = [
    repmat([0, 0.17, 0.52], size(gh20, 1), 1);   % RGB color for x = 20
    repmat([0, 0.22, 1], size(gh10, 1), 1);      % RGB color for x = 10
    repmat([0.24, 0.49, 1], size(gh5, 1), 1);     % RGB color for x = 5
    repmat([0.47, 0.65, 1], size(gh3, 1), 1);     % RGB color for x = 3
    repmat([0.75, 0.84, 1], size(gh1, 1), 1)      % RGB color for x = 1
];
%%

allBehaviorsName = getOnlyName(allBehaviors);
allFeaturesName = getOnlyName(allFeatures);

allNamesfeaturesandbehaviors = [allBehaviorsName',allFeaturesName'];

correlation_table = {};
for ii = 1:91

b_mean = [gh20{1:size(gh20,1),ii}, gh10{1:size(gh10,1),ii},gh5{1:size(gh5,1),ii},gh3{1:size(gh3,1),ii},gh1{1:size(gh1,1),ii}]*100;


[r,p,regressionEquation,Pmodel] = correlationDisp(a,b_mean,colorsRGB,allNamesfeaturesandbehaviors(ii));

correlation_table{1,ii} = allNamesfeaturesandbehaviors(ii);

correlation_table{2,ii} = p;

correlation_table{3,ii} = r;

correlation_table{4,ii} = regressionEquation;

correlation_table{5,ii} = Pmodel;

end
%%
fileName = "CorrelationDataFile.csv"
cd('H:\hadar\GH\correlation_gh\')
% Write the table to a CSV file
writetable(cell2table(correlation_table),fileName)
