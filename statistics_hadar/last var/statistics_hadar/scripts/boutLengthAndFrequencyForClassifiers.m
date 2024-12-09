%function boutLengthAndFrequencyForClassifiers(behaviors)
behaviors = behaviors;
%% צריך לבדוק האם זה לכל התנהגות או לכל זבוב וכו
    str1 = 'frequency';
    str2 = 'bout length';
    
    ave_bl = [];
    total_bl = [];
    total_all = [];
    per_movie_freq = [];
    total_freq_all = [];
    ave_bl_fly = [];
    first = true;
    
    for k = 1:length(behaviors)
        behavior = behaviors{k};
        
        ave_bl = mean(behavior, 'omitnan');
        ave_freq = length(behavior) / (numel(behavior) / 30);
        
        total_bl = [total_bl; ave_bl];
        total_freq = [total_freq; ave_freq];
        
        total_df = table(k, ave_bl, 'VariableNames', {'behavior' 'value'});
        total_freq_df = table(k, ave_freq, 'VariableNames', {'behavior' 'value'});
        
        if k == 1
            total_all = total_df;
            total_freq_all = total_freq_df;
        else
            total_all = [total_all; total_df];
            total_freq_all = [total_freq_all; total_freq_df];
        end
    end
    
    writetable(total_all, 'bout_length_scores.csv', 'WriteRowNames', false);
    writetable(total_freq_all, 'frequency_scores.csv', 'WriteRowNames', false);
%end
