function [r_spearman,pvalueSpearman,Title,pmodel] = correlationDispMCBHDH(numberOfgroups,Data_vec_mean,color,name_behavior,h,padj)
  
    % numberOfgroups = a;
    % Data_vec_mean= b_mean;
    % name_behavior = allNamesfeaturesandbehaviors(3);

    
    
    % numberOfgroups, contain vector with the values of x axis
    % Data_vec, contain the vector of means of one behavior
    [r_spearman,pvalueSpearman] = corr(numberOfgroups',Data_vec_mean','Type','Spearman')
    lm = fitlm(numberOfgroups,Data_vec_mean);
    coefficients = lm.Coefficients.Estimate;
    intercept = coefficients(1);
    slope = coefficients(2);

    % coefficients and intercept

    
    % Display the equation of the regression line
    Title = ['Regression Equation for linear model: y = ' num2str(intercept) ' + ' num2str(slope) 'x'];
    pmodel = lm.ModelFitVsNullModel.Pvalue;

    if h;
        if abs(r_spearman) >= 0.3
    figure
    % linear regression
    %lm = fitlm(numberOfgroups,Data_vec_mean);
    % Define the range of x-values for prediction
    x_range = linspace(min(numberOfgroups), max(numberOfgroups), 100);
    
    % Calculate the predicted y-values for the x-range
    [y_pred, y_pred_CI] = predict(lm, x_range','Alpha', 0.05, 'Prediction', 'curve');

    y_ci_SE = y_pred_CI(:, 2)-y_pred;

    shadedErrorBar(x_range,y_pred,y_ci_SE,[],1)
    
    hold on
    % % coefficients and intercept
    % coefficients = lm.Coefficients.Estimate;
    % intercept = coefficients(1);
    % slope = coefficients(2);
    % 
    % % Display the equation of the regression line
    % Title = ['Regression Equation for linear model: y = ' num2str(intercept) ' + ' num2str(slope) 'x'];
    
    % Plot the data and regression line
    scatter(numberOfgroups, Data_vec_mean, [], color,'filled');
    
    
        
    hold on;
    x = min(numberOfgroups):max(numberOfgroups);
    y = intercept + slope * x;
   % plot(x_range, y_pred, "r");
    
    %title([Title, "pvalue = "+padj + ", R^2 = "+r_spearman])
    xlim([1.9 5.1])
    xloca = [2 3 4 5];
    xticks(xloca);
    xlabels = {'Isolated','Bottle','Regular Vial','Small Vial'};
    xticklabels(xlabels);
    %pmodel = lm.ModelFitVsNullModel.Pvalue;
    Text = ["Model Pvalue= "+lm.ModelFitVsNullModel.Pvalue];
    Text = ["R = " + r_spearman];
    ylbl = strrep(name_behavior, '_', ' ');
    disp(ylbl)
    ylbln = [ylbl + " (%)"];
    ylabel(ylbln,'FontSize', 14);
    %x_range,y_pred
    xL=xlim;
    yL=ylim;
    text(0.99*xL(2),0.99*yL(2),Text,'HorizontalAlignment','right','VerticalAlignment','top')
    % hold on
    % plot(lm)



    hold off;
    % if pvalueSpearman<=0.05;
    %     if abs(r_spearman) >= 0.3
            if lm.ModelFitVsNullModel.Pvalue <= 0.05
                path_to_save = "CorrelationPlot_"+name_behavior+".png"
                saveas(gcf,'D:\Hadar\GH\New folder\'+path_to_save)
            end
        end
    end
%end
