function finalMatrices = conditionThresholds(thresholdedMatrices, minFrames, behaviorLabels, numBehaviors, timeInterval)
    % This function computes the final thresholded matrices for each condition
    % by summing and normalizing the thresholded matrices for all movies within each condition.
    % It then applies a threshold for each behavior based on the upper quartile of the summed values.
    %
    % Inputs:
    % - thresholdedMatrices: A cell array where each element is a cell array of matrices for different movies
    %   within a condition. Each matrix represents the thresholded behaviors for that movie.
    % - minFrames: The minimum number of frames across all movies, used to calculate the number of intervals.
    % - behaviorLabels: A cell array of labels for the behaviors.
    % - numBehaviors: The number of behaviors (i.e., the number of rows in each matrix).
    % - timeInterval: The time interval over which frames are aggregated into intervals.
    %
    % Output:
    % - finalMatrices: A cell array where each element is the final thresholded matrix for a condition.

    % Get the number of frames per interval based on the provided time interval
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);

    % Determine the number of intervals by dividing the minimum number of frames by frames per interval
    numIntervals = floor(minFrames / numFramesPerInterval);

    % Initialize the output cell array to store the final matrices for each condition
    numConditions = length(thresholdedMatrices);  % Number of conditions
    finalMatrices = cell(numConditions, 1);
    
    % Loop through each condition to compute the final thresholded matrix
    for condIdx = 1:numConditions
        % Get the number of movies for the current condition
        numMovies = length(thresholdedMatrices{condIdx});
        
        % Initialize a matrix to store the sum of thresholded matrices across movies for this condition
        summedMatrix = zeros(numBehaviors, numIntervals);

        % Loop through each movie in the current condition
        for movieIdx = 1:numMovies
            % Get the thresholded matrix for the current movie
            currentMatrix = thresholdedMatrices{condIdx}{movieIdx};

            % Get the number of columns (intervals) in the current matrix
            [~, currentNumIntervals] = size(currentMatrix);

            % Adjust the size of the current matrix to match the desired number of intervals
            if currentNumIntervals >= numIntervals
                % If the current matrix has more intervals, crop it
                currentMatrix = currentMatrix(:, 1:numIntervals);  
            else
                % If the current matrix has fewer intervals, pad it with zeros
                currentMatrix = [currentMatrix, zeros(numBehaviors, numIntervals - currentNumIntervals)];  
            end

            % Add the current matrix to the running sum
            summedMatrix = summedMatrix + currentMatrix;
        end

        % Calculate the upper quartile (75th percentile) of summed values for each behavior
        upper_quarter_values = quantile(summedMatrix, 0.75, 2);

        % Calculate the default thresholds by dividing the upper quartile values by the number of movies
        defaultThresholds = upper_quarter_values / numMovies;

        % Set a minimum threshold value of 0.3
        defaultThresholds(defaultThresholds < 0.3) = 0.3;

        % Normalize the summed matrix by the number of movies to get average scores
        normalizedMatrix = summedMatrix / numMovies;

        % Apply the default thresholds to the normalized matrix and store the result
        finalMatrices{condIdx} = applyThresholds(normalizedMatrix, behaviorLabels, defaultThresholds);
    end
end
