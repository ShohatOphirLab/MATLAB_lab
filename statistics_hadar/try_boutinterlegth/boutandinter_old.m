function boutandinter()
% main for 
% needed scripts:
% calculate_boutstats_out
% uipickfiles
% inutulaize
%compute_behavior_logic_out
% before starting to run, should do add folders and subfolders for my
% scripts: D:\Hadar\try_boutinterlegth
allBehaviors = extractingNames();

[conditionNames, conditionName] = extractConditionName();

%%
final_meanBout = [];
for condi = 1:length(conditionNames)
    handles = initialize();
    for_stat_bout = {};
    tmp_bout = {};
    tmp_interbout = {};
    for_stat_interbout = {};
    rowMeans_bout = [];
    rowMeans_inter = [];
    cd(conditionName{condi})
    expGroups = uipickfiles('Prompt', 'Select experiment files');
    for numberGroup = 1:length(expGroups)
        cd (cell2mat(expGroups(numberGroup)))
        dir = cell2mat(expGroups(numberGroup));
        
        load("registered_trx.mat");
        fps = trx.fps;
        counter = 0;
        for behave = 1:length(allBehaviors) % to over all behaviors
            file_bout = "bout length " + cell2mat(allBehaviors(behave));
            file_interbout = "inter bout " + cell2mat(allBehaviors(behave));
            behavior_data = load(cell2mat(allBehaviors(behave)));
            behavior_logic = handles.behaviorlogic;
            behaviornot = handles.behaviornot;
            [bout_lengths inter_bout_lengths ]=calculate_boutstats_out(behavior_data,behavior_logic,behaviornot);
            get_mean_bout = 0;
            get_mean_interbout = 0;

            for j=1:length(bout_lengths);
                get_mean_bout = get_mean_bout + mean(bout_lengths{1,j}); % sum per movie mean per fly
                get_mean_interbout = get_mean_interbout + mean(inter_bout_lengths{1,j}); % sum per movie mean per fly
            end

            value_bout = (get_mean_bout/j)/fps;
            value_inter = (get_mean_interbout/j)/fps;
            % dir, file, value
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for_stat_bout{numberGroup,behave+counter} = dir;
            for_stat_bout{numberGroup,behave+1+counter} = file_bout;
            for_stat_bout{numberGroup,behave+2+counter} = value_bout;

            for_stat_interbout{numberGroup,behave+counter} = dir;
            for_stat_interbout{numberGroup,behave+1+counter} = file_interbout;
            for_stat_interbout{numberGroup,behave+2+counter} = value_inter;
            counter = counter+2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tmp_bout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior per movie
            tmp_bout{numberGroup+1,1} = cell2mat(expGroups(numberGroup)); % cd 
            tmp_bout{numberGroup+1,behave+1} = (get_mean_bout/j)/fps; % total per behavior

            tmp_interbout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior
            tmp_interbout{numberGroup+1,1} = cell2mat(expGroups(numberGroup)); % cd 
            tmp_interbout{numberGroup+1,behave+1} = (get_mean_interbout/j)/fps; % total per behavior

        end
      
    end
      for behave = 1:length(allBehaviors)
        % tmp_bout{numberGroup+2,behave+1} =  mean(cell2mat(tmp_bout(2:end,behave+1)),'omitnan');
        % tmp_interbout{numberGroup+2,behave+1} = mean(cell2mat(tmp_interbout(2:end,behave+1)),'omitnan');
        rowMeans_bout(behave) =  mean(cell2mat(tmp_bout(2:end,behave+1)),'omitnan');
        rowMeans_inter(behave) = mean(cell2mat(tmp_interbout(2:end,behave+1)),'omitnan');
      end
      
   cun = 1; 
    for col=3:3:size(for_stat_interbout,2);
        nanIndices_bout = isnan([for_stat_bout{:,col}]);
        nanIndices_interbout = isnan([for_stat_interbout{:,col}]);
        if any(nanIndices_bout)
            tmp = cell2mat(for_stat_bout(:,col));
            tmp(find(nanIndices_bout)) = rowMeans_bout(cun);
            for_stat_bout(:,col) = num2cell(tmp);
        end
        if any(nanIndices_interbout)
            tmp = cell2mat(for_stat_interbout(:,col));
            tmp(find(nanIndices_interbout)) = rowMeans_inter(cun);
            for_stat_interbout(:,col) = num2cell(tmp);
        end
        
        cun = cun+1;
   
    
    end
    hadar = load('D:\MATLAB\runAll\try_boutinterlegth\title_csv.mat');
    cd(conditionName{condi})
    %save the csv file of all behavior per condition
    fileNamebout = "bout_length_scores.csv"
    cellDatabout = cell2table(for_stat_bout,'VariableNames',hadar.ans);
    writetable(cellDatabout, fileNamebout)
    
    fileNameinterbout = "frequency_scores.csv"
    cellDatainter = cell2table(for_stat_interbout,'VariableNames',hadar.ans);
    writetable(cellDatainter, fileNameinterbout)
    
end

end