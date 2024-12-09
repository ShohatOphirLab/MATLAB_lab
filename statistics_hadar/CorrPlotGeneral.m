function CorrPlotGeneral()
% main GH for correlation visualization and stats

% extracting name behaviors and condition list
[allBehaviors, allFeatures] = extractingNames();
[conditionNames, conditionName] = extractConditionName();

% choosing colors
[Gcolor, scalingFactors] = ChooseColorAndNumber(conditionName)
%%
% Initialize a cell array to hold your dynamic variables
dynamicVariables = {};
ConditionSizeA = {};
% Generate variables dynamically and add them to the cell array
for jn = 1:length(conditionName) % You can change the number of variables as needed
    variableName = sprintf(conditionNames{jn}, jn);
    cd(conditionName{jn})
    variableValue = table2cell(readtable("myDataFile" +variableName +".csv",'VariableNamingRule','preserve')); % Replace with your actual data or value generation
    dynamicVariables{1,jn} = variableName;
    dynamicVariables{2,jn} =variableValue(1:(size(variableValue,1)-2),3:end);
    dynamicVariables{3,jn} =variableValue;
    ConditionSizeA{jn} = ones(1,size(variableValue(1:(size(variableValue,1)-2),3:end),1)) ;
end


%%
a = [];
color = [];
for jj = 1:length(scalingFactors);
    a = [a,[scalingFactors(jj)*ConditionSizeA{jj}]];
    color = [color;[repmat(Gcolor(jj,:),length(ConditionSizeA{jj}),1)]];

end

%%
%allNamesfeaturesandbehaviors = [allBehaviors,bout+allBehaviors,interbout+allBehaviors,allFeatures];
allBehaviorsName = getOnlyName(allBehaviors);
allFeaturesName = getOnlyName(allFeatures);
boutNames = "bout"+allBehaviorsName;
interboutNames = "inter_bout"+allBehaviorsName;
allNamesfeaturesandbehaviors = [allBehaviorsName',boutNames',interboutNames',allFeaturesName'];
%%
forBHfdr = {};
all_pvalues = [];
b_mean = [];

for ii = 1:length(allNamesfeaturesandbehaviors);
    b_mean = [];
    for jj = 1:length(scalingFactors);
        b_mean = [b_mean,[dynamicVariables{2,jj}{1:size(dynamicVariables{2,jj},1),ii}].*100];
    end
   %b_mean = [dynamicVariables{2,1}{1:size(dynamicVariables{2,1},1),ii}, dynamicVariables{2,2}{1:size(dynamicVariables{2,2},1),ii},dynamicVariables{2,3}{1:size(dynamicVariables{2,3},1),ii},dynamicVariables{2,4}{1:size(dynamicVariables{2,4},1),ii}]*100;
 
    
    [r,p] = corr(a',b_mean',"type","Spearman");
    
    forBHfdr{1,ii} = [allNamesfeaturesandbehaviors(ii),p,r];
    all_pvalues(ii) = p;


end
% %%
% all_pvalues = [];
% for ii = 1:length(allNamesfeaturesandbehaviors);
% ii
% all_pvalues(ii) = forBHfdr{1, ii}{1, 2} ;
% end
%%
 choose_answer = questdlg('Full Data or Good Visualization?:', ...
	    'optionts', ...
	    'Full Data','Good Visualization','Good Visualization');
    % Handle response
    switch choose_answer
        case 'Full Data'
            
            change = 1;
        case 'Good Visualization'
            
            change = 2;
    end
    %%
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(all_pvalues);
%%
correlation_table = {};
FatherFolder = uipickfiles('Prompt', 'Select father folder for saving');
FatherFolder = FatherFolder{1};
%%
for ii = 1:length(allNamesfeaturesandbehaviors);
    b_mean = [];
    for jj = 1:length(scalingFactors);
        b_mean = [b_mean,[dynamicVariables{2,jj}{1:size(dynamicVariables{2,jj},1),ii}].*100];
    end
   % b_mean = [gh20{1:size(gh20,1),ii}, gh10{1:size(gh10,1),ii},gh5{1:size(gh5,1),ii},gh3{1:size(gh3,1),ii},gh1{1:size(gh1,1),ii}]*100;
    hi = h(ii);
    padj = adj_p(ii);
    if hi
        if  change == 1;
            [r,p,regressionEquation,pmodel] = DispCorrandLM(a,b_mean,color,allNamesfeaturesandbehaviors(ii),hi,padj,FatherFolder);
        elseif  change == 2;
            [r,p,regressionEquation,pmodel] = goodVis_DispCorrandLM(a,b_mean,color,allNamesfeaturesandbehaviors(ii),hi,padj,FatherFolder,scalingFactors,conditionNames);
        end
    end
    correlation_table{1,ii} = allNamesfeaturesandbehaviors(ii);
    
    correlation_table{2,ii} = padj;
    
    correlation_table{3,ii} = r;
    
   % correlation_table{4,ii} = regressionEquation;

   % correlation_table{5,ii} = pmodel;

end
%%
correlation_table = cell2table(correlation_table);
%%
fileName = "Correlation Table.csv"
cd(FatherFolder)
% Write the table to a CSV file
writetable(correlation_table,fileName)