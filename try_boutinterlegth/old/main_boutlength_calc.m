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


final_meanBout = [];
for condi = 1:length(conditionNames)
    handles = initialize();
    for_stat_bout = {};
    for_stat_interbout = {};
    cd(conditionName{condi})
    expGroups = uipickfiles('Prompt', 'Select experiment files');
    for numberGroup = 1:length(expGroups)
        cd (cell2mat(expGroups(numberGroup)))
        load("registered_trx.mat");
        fps = trx.fps;
        for behave = 1:length(allBehaviors) % to over all behaviors
            
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
            for_stat_bout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior
            for_stat_bout{numberGroup+1,1} = cell2mat(expGroups(numberGroup)); % cd 
            for_stat_bout{numberGroup+1,behave+1} = (get_mean_bout/j)/fps; % total per behavior

            for_stat_interbout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior
            for_stat_interbout{numberGroup+1,1} = cell2mat(expGroups(numberGroup)); % cd 
            for_stat_interbout{numberGroup+1,behave+1} = (get_mean_interbout/j)/fps; % total per behavior
            
        end
      
    end
      for behave = 1:length(allBehaviors)
        for_stat_bout{numberGroup+2,behave+1} = mean(cell2mat(for_stat_bout(2:end,behave+1)),'omitnan');
        for_stat_interbout{numberGroup+2,behave+1} = mean(cell2mat(for_stat_interbout(2:end,behave+1)),'omitnan');
      end
    % break
    %final_meanBout(condi) = mean(for_stat_bout);
    cd(conditionName{condi})
    %save the csv file of all behavior per condition
    fileNamebout = "bout_length_scores.csv"
    cellDatabout = cell2table(for_stat_bout);
    writetable(cellDatabout, fileNamebout)

    fileNameinterbout = "frequency_scores.csv"
    cellDatainter = cell2table(for_stat_interbout);
    writetable(cellDatainter, fileNameinterbout)
end

