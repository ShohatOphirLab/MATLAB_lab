function defaultThresholds = adjustedThreshold(summedScores, ratio, RF)
    % Calculate the default behavior thresholds based on the summed scores.
    %
    % Inputs:
    %   - summedScores: (matrix) Matrix of summed behavior scores where each row represents a behavior.
    %   - ratio: (numeric) The quantile ratio to use for threshold calculation (e.g., 0.75 for upper quartile).
    %   - RF: (numeric) A scaling factor to divide the threshold values (e.g., frames per interval).
    %
    % Outputs:
    %   - defaultThresholds: (vector) Calculated default thresholds for each behavior.
    
    % Calculate the upper quantile (e.g., upper 25%) for each behavior (row) in the summedScores matrix.
    % This captures the score at the specified ratio (e.g., 0.75) for each behavior.
    upper_quarter_values = quantile(summedScores, ratio, 2);
    
    % Find indices of behaviors where the upper quantile is less than 1 (i.e., too small).
    tinyIndices = upper_quarter_values < 1;

    % Replace those small quantile values with 1 to avoid thresholds being too low.
    % This ensures a minimal threshold for each behavior.
    upper_quarter_values(tinyIndices) = 1;

    % Calculate the default thresholds by dividing the upper quantile values by the scaling factor RF.
    % This scales the thresholds based on the analysis resolution (e.g., frames per interval).
    defaultThresholds = upper_quarter_values / RF;
    
    % Display a success message in the command window
    disp("Successfully set the default thresholds for the matrix.");
end
