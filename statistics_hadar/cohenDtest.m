function cohenDtest(cellMeanData_transpose,saveRes)
    %% cohen test
    
    [conditionNames, conditionName] = extractConditionName();
    % (mean1-mean2)/std(1+2);
    cohenres = {};
    allCompare = {};
    compare = 1;
    
    for conditionType = 1:length(conditionNames);
        for typeCondition = 1:length(conditionNames);
            if conditionType ~= typeCondition
                group1 = conditionNames(conditionType);
                group2 = conditionNames(typeCondition);
            
                allCompare{compare} = group1+" vs. "+group2;
        
                for x=2:length(cellMeanData_transpose)
                    mean1 = cellMeanData_transpose{x,2*conditionType-1};
                    mean2 = cellMeanData_transpose{x,2*typeCondition-1};      
                    std1 = cellMeanData_transpose{x,2*conditionType};
                    std2 = cellMeanData_transpose{x,2*typeCondition};
                    mutalSTD = sqrt((std1^2+std2^2)/2);
                    cohendtest = (mean1-mean2)/mutalSTD;
                    cohenres{1,compare} = allCompare{compare};
                    cohenres{x,compare}=cohendtest;
                end
                compare = compare+1;
            end
        end
    end
    
    %%
    [allBehaviors, allFeatures] = extractingNames();
    allBehaviorsName = getOnlyName(allBehaviors);
    allFeaturesName = getOnlyName(allFeatures);
    boutNames = "bout_"+allBehaviorsName;
    interboutNames = "inter_bout_"+allBehaviorsName;
    allNamesfeaturesandbehaviors = [allBehaviorsName',boutNames',interboutNames',allFeaturesName'];
%%
    cd(saveRes);% fill   
    staCohenTbl = cell2table((cohenres));
    %%
    size(staCohenTbl)
    staCohenTbl.names = [allNamesfeaturesandbehaviors]';
    fileName = "cohentestNAMESPROBLEM.csv"
    % Write the table to a CSV file
    writetable(staCohenTbl,fileName)
end