function   [for_stat_bout, for_stat_interbout] = hadar_boutandinter(allBehaviors,jj,handles,name_of_the_file,numberMovie) 
    behave = jj;
    fps = 30;
    numberGroup = numberMovie;
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
    % for_stat_bout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior
    % for_stat_bout{numberGroup+1,1} = name_of_the_file; % cd 
  %  for_stat_bout{numberGroup+1,behave+1} = (get_mean_bout/j)/fps; % total per behavior
    for_stat_bout = (get_mean_bout/j)/fps;
    % for_stat_interbout{1,behave+1} = cell2mat(allBehaviors(behave)); % total per behavior
    % for_stat_interbout{numberGroup+1,1} = name_of_the_file; % cd 
    %for_stat_interbout{numberGroup+1,behave+1} = (get_mean_interbout/j)/fps; % total per behavior
    for_stat_interbout = (get_mean_interbout/j)/fps;
end