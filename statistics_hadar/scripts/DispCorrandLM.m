function [r_spearman,pvalueSpearman,Title,pmodel] = DispCorrandLM(numberOfgroups,Data_vec_mean,color,name_behavior,h,padj,FatherFolder)
   
    % numberOfgroups, contain vector with the values of x axis
    % Data_vec, contain the vector of means of one behavior

    [r_spearman,pvalueSpearman] = corr(numberOfgroups',Data_vec_mean','Type','Spearman');
    lm = fitlm(numberOfgroups,Data_vec_mean);
    coefficients = lm.Coefficients.Estimate;
    intercept = coefficients(1);
    slope = coefficients(2);

       
    % Display the equation of the regression line
    Title = ['Regression Equation for linear model: y = ' num2str(intercept) ' + ' num2str(slope) 'x'];
    if lm.Coefficients{1,4} & lm.Coefficients {2,4} <= 0.05
        pmodel = 1;
    else
        pmodel = 0;
    end

    figure;
    
    % Define the range of x-values for prediction
    x_range = linspace(min(numberOfgroups), max(numberOfgroups), 100);
    
    % Calculate the predicted y-values for the x-range
    [y_pred, y_pred_CI] = predict(lm, x_range','Alpha', 0.05, 'Prediction', 'curve');

    y_ci_SE = y_pred_CI(:, 2)-y_pred;

    shadedErrorBar(x_range,y_pred,y_ci_SE,[],1)
    
    hold on
    
    % Plot the data and regression line
    scatter(numberOfgroups, Data_vec_mean, [], color,'filled');
        
    hold on;
    x = min(numberOfgroups):max(numberOfgroups);
    y = intercept + slope * x;
    
    title([Title, "pvalue = "+padj + ", R = "+r_spearman])
    
    ylbl = strrep(name_behavior, '_', ' ');
    ylabel(ylbl,'FontSize', 24);
    
    xL=xlim;
    yL=ylim;
 
    hold off;

             if pmodel
                 path_to_save = "CorrelationPlot_"+name_behavior+".png";
                 saveas(gcf,FatherFolder+path_to_save)
             end
end
