% main GH for correlation visualization and stats

% extracting name behaviors and condition list
[allBehaviors, allFeatures] = extractingNames();
[~, conditionName] = extractConditionName();

%%

%loading the data

cd(conditionName{4})
SmallVial = table2cell(readtable('myDataFileGrouped10_SmallVial.csv','VariableNamingRule','preserve'));
SmallVial = SmallVial(1:(size(SmallVial,1)-2),3:end);
cd(conditionName{3})
RegularVial = table2cell(readtable('myDataFileGrouped10_RegularVial.csv','VariableNamingRule','preserve'));
RegularVial = RegularVial(1:(size(RegularVial,1)-2),3:end);
cd(conditionName{2})
Bottle = table2cell(readtable('myDataFileGrouped10_Bottle.csv','VariableNamingRule','preserve'));
Bottle = Bottle(1:(size(Bottle,1)-2),3:end);
cd(conditionName{1})
Isolated = table2cell(readtable('myDataFileIsolated.csv','VariableNamingRule','preserve'));
Isolated = Isolated(1:(size(Isolated,1)-2),3:end);


%%
a = [2*ones(1,size(Isolated,1)) 3*ones(1,size(Bottle,1)) 4*ones(1,size(RegularVial,1)) 5*ones(1,size(SmallVial,1))];
color = [repmat([0.88,0.82,1],size(Isolated,1),1);
    repmat([0.68,0.54,1],size(Bottle,1),1);
    repmat([0.74,0.36,1],size(RegularVial,1),1);
    repmat([0.36,0.14,1],size(SmallVial,1),1);
    ];
%%
%allNamesfeaturesandbehaviors = [allBehaviors,bout+allBehaviors,interbout+allBehaviors,allFeatures];
allBehaviorsName = getOnlyName(allBehaviors);
allFeaturesName = getOnlyName(allFeatures);
boutNames = "bout"+allBehaviorsName;
interboutNames = "inter_bout"+allBehaviorsName;
allNamesfeaturesandbehaviors = [allBehaviorsName',boutNames',interboutNames',allFeaturesName'];

forBHfdr = {};
all_pvalues = [];
for ii = 1:length(allNamesfeaturesandbehaviors);

    b_mean = [Isolated{1:size(Isolated,1),ii}, Bottle{1:size(Bottle,1),ii},RegularVial{1:size(RegularVial,1),ii},SmallVial{1:size(SmallVial,1),ii}]*100;
    
    
    [r,p] = corr(a',b_mean',"type","Spearman");
    
    forBHfdr{1,ii} = [allNamesfeaturesandbehaviors(ii),p,r];
    all_pvalues(ii) = p;


end
%%
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(all_pvalues);
%%

correlation_table = {};
for ii = 1:length(allNamesfeaturesandbehaviors);

    b_mean = [Isolated{1:size(Isolated,1),ii}, Bottle{1:size(Bottle,1),ii},RegularVial{1:size(RegularVial,1),ii},SmallVial{1:size(SmallVial,1),ii}]*100;
    hi = h(ii);
    padj = adj_p(ii);
    
    correlationDispMCBHDH(a,b_mean,color,allNamesfeaturesandbehaviors(ii),hi,padj);
    
%     correlation_table{1,ii} = allNamesfeaturesandbehaviors(ii);
%     
%     correlation_table{2,ii} = padj;
%     
%     correlation_table{3,ii} = r;
%     
%     correlation_table{4,ii} = regressionEquation;
%     
%     correlation_table{5,ii} = 0;

end
% allNamesfeaturesandbehaviors = [allBehaviors,allFeatures];
% allBehaviorsName = getOnlyName(allBehaviors);
% allFeaturesName = getOnlyName(allFeatures);
% 
% allNamesfeaturesandbehaviors = [allBehaviorsName',allFeaturesName'];
% forBHfdr = {};
% for ii = 1:91
% 
% b_mean = [Isolated{1:size(Isolated,1),ii}, Bottle{1:size(Bottle,1),ii},RegularVial{1:size(RegularVial,1),ii},SmallVial{1:size(SmallVial,1),ii}]*100;
% 
% 
% [r,p] = corr(a',b_mean',"type","Spearman");
% 
% forBHfdr{1,ii} = [allNamesfeaturesandbehaviors(ii),p,r];
% 
% 
% 
% end
% 
% all_pvalues = [];
% for ii = 1:91
% 
% all_pvalues(ii) = forBHfdr{1, ii}{1, 2} ;
% end
% 
% [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(all_pvalues);
% 
% 
% correlation_table = {};
% for ii = 1:91
% 
% b_mean = [Isolated{1:size(Isolated,1),ii}, Bottle{1:size(Bottle,1),ii},RegularVial{1:size(RegularVial,1),ii},SmallVial{1:size(SmallVial,1),ii}]*100;
% hi = h(ii);
% padj = adj_p(ii);
% 
% [r,p,regressionEquation,pmodel] = correlationDispMCBHDH(a,b_mean,color,allNamesfeaturesandbehaviors(ii),hi,padj);
% 
% correlation_table{1,ii} = allNamesfeaturesandbehaviors(ii);
% 
% correlation_table{2,ii} = padj;
% 
% correlation_table{3,ii} = r;
% 
% correlation_table{4,ii} = regressionEquation;
% 
% correlation_table{5,ii} = pmodel;
% 
% end
%%
correlation_table = cell2table(correlation_table);
%%
fileName = "correlation table DH.csv"
cd("D:\Hadar\DH\New folder")
% Write the table to a CSV file
writetable(correlation_table,fileName)