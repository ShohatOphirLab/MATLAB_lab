% TODO: Check if the function is in use, if not - delete it
% If it is in use - correct the calculation of the intervals according to the lower value, and that the function will receive the minimum number of frames.
function thresholdedSumMatrices = sumAndApplyThreshold(thresholdedMatrices, thresholdFraction, maxNumFrames, numBehaviors, timeInterval)
    % This function sums behavior matrices across multiple movies for each condition
    % and applies a threshold to the summed matrices. The threshold is determined by
    % a fraction of the number of movies. The result is a binary matrix indicating 
    % whether the summed scores for each behavior exceed the threshold.
    %
    % Inputs:
    % - thresholdedMatrices: A cell array where each element is a cell array of matrices for each condition.
    %   Each matrix represents thresholded behavior scores for a single movie.
    % - thresholdFraction: The fraction of movies that must exhibit a behavior for it to be considered significant.
    % - maxNumFrames: The maximum number of frames across all movies.
    % - numBehaviors: The number of behaviors being tracked.
    % - timeInterval: The time interval over which frames are grouped (e.g., 'Second', 'Minute').
    %
    % Output:
    % - thresholdedSumMatrices: A cell array of binary matrices (one for each condition) where each matrix 
    %   indicates if the summed behavior scores for each interval exceed the threshold.

    % Get the number of frames per interval based on the time interval
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);

    % Calculate the number of intervals based on the max number of frames and frames per interval
    numIntervals = ceil(maxNumFrames / numFramesPerInterval);

    % Initialize the output cell array to store the thresholded summed matrices for each condition
    numConditions = length(thresholdedMatrices);
    thresholdedSumMatrices = cell(numConditions, 1);
    
    % Loop through each condition to process its corresponding matrices
    for condIdx = 1:numConditions
        % Get the number of movies for the current condition
        numMovies = length(thresholdedMatrices{condIdx});
        
        % Initialize a matrix to store the summed behavior scores across movies for this condition
        summedMatrix = zeros(numBehaviors, numIntervals);

        % Loop through each movie in the current condition to sum the behavior matrices
        for movieIdx = 1:numMovies
            currentMatrix = thresholdedMatrices{condIdx}{movieIdx};

            % Add to the summed matrix, adjusting for different frame counts across movies
            [~, currentNumIntervals] = size(currentMatrix);
            
            % If the current matrix has fewer intervals than the expected max, pad it with zeros
            if currentNumIntervals < numIntervals
                currentMatrix = [currentMatrix, zeros(numBehaviors, numIntervals - currentNumIntervals)];
            end

            % Add the current matrix to the summed matrix
            summedMatrix = summedMatrix + currentMatrix;
        end
        
        % Determine the threshold based on the fraction of movies
        threshold = thresholdFraction * numMovies;
        
        % Create a binary matrix indicating whether the summed scores exceed the threshold
        thresholdedMatrix = summedMatrix >= threshold;
        
        % Store the resulting binary matrix in the output cell array
        thresholdedSumMatrices{condIdx} = double(thresholdedMatrix);
    end
end
