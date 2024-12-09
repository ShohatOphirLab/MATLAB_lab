function conditionMatrix = computeGeneralConditionMat(thresholdedMats, minFrames, behaviorLabels, numBehaviors, timeInterval)
    % This function computes a general condition matrix for a set of behavior threshold matrices.
    % The function first sums up thresholded matrices across multiple movies and normalizes the result.
    % It then applies thresholds to produce a final condition matrix.
    %
    % Inputs:
    % - thresholdedMats: A cell array where each element is a matrix of thresholded scores for a movie
    % - minFrames: The minimum number of frames across all movies
    % - behaviorLabels: A cell array of behavior labels
    % - numBehaviors: The number of behaviors (rows in each thresholded matrix)
    % - timeInterval: The time interval over which frames are aggregated into intervals
    %
    % Output:
    % - conditionMatrix: A matrix where thresholds have been applied to the normalized sum of behavior scores.

    % Get the number of frames per interval based on the provided time interval
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);   

    % Determine the number of intervals by dividing the minimum number of frames by frames per interval
    numIntervals = floor(minFrames / numFramesPerInterval); 

    % Get the number of movies (datasets) in the current condition
    numMovies = length(thresholdedMats);
    
    % Initialize a matrix to store the sum of thresholded matrices across movies
    summedMatrix = zeros(numBehaviors, numIntervals);

    % Loop over each movie to sum the thresholded matrices
    for movieIdx = 1:numMovies
        % Get the thresholded matrix for the current movie
        currentMatrix = thresholdedMats{movieIdx};

        % Get the number of intervals (columns) in the current matrix
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

    % Calculate the upper quartile (75th percentile) of summed scores for each behavior
    upper_quarter_values = quantile(summedMatrix, 0.75, 2);
    
    % Calculate the default thresholds by dividing the upper quartile values by the number of movies
    defaultThresholds = upper_quarter_values / numMovies;

    % Set a minimum threshold value of 0.3
    defaultThresholds(defaultThresholds < 0.3) = 0.3;

    % Normalize the summed matrix by the number of movies to get average scores
    normalizedMatrix = summedMatrix / numMovies;
    
    % Apply the default thresholds to the normalized matrix
    conditionMatrix = applyThresholds(normalizedMatrix, behaviorLabels, defaultThresholds);
end
