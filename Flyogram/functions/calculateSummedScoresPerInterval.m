function summedScoresPerInterval = calculateSummedScoresPerInterval(combinedScoresMatrix, numBehaviors, numFrames, numFramesPerInterval)
    % This function calculates the summed behavior scores over specific intervals 
    % for a given matrix of combined behavior scores.
    %
    % Inputs:
    % - combinedScoresMatrix: A matrix (numBehaviors x numFrames) where each row
    %   corresponds to a behavior and each column is a frame with associated scores.
    % - numBehaviors: The number of behaviors (i.e., the number of rows in combinedScoresMatrix).
    % - numFrames: The total number of frames in the data.
    % - numFramesPerInterval: The number of frames that define one interval for analysis.
    %
    % Output:
    % - summedScoresPerInterval: A matrix (numBehaviors x numIntervals) where each 
    %   column contains the summed scores of the behaviors for a particular interval.

    % Determine the number of intervals by dividing the total number of frames
    % by the number of frames per interval and rounding down to the nearest integer.
    numIntervals = floor(numFrames / numFramesPerInterval);
    
    % Initialize a matrix to store the summed behavior scores for each interval.
    % The matrix has dimensions (numBehaviors x numIntervals), where each row
    % corresponds to a behavior and each column to an interval.
    summedScoresPerInterval = zeros(numBehaviors, numIntervals);
    
    % Loop over each interval
    for intervalIdx = 1:numIntervals
        % Determine the start and end frame indices for the current interval.
        % startFrame marks the first frame of the interval, and endFrame marks the last frame.
        startFrame = (intervalIdx - 1) * numFramesPerInterval + 1;
        endFrame = min(intervalIdx * numFramesPerInterval, numFrames);  % Ensure it doesn't exceed numFrames
    
        % Extract the scores for the current interval for all behaviors.
        % This gives a sub-matrix corresponding to the current interval.
        scoresInterval = combinedScoresMatrix(:, startFrame:endFrame);
    
        % Sum the scores across all frames within the interval for each behavior
        % (i.e., sum along the columns) and store the result in the corresponding
        % column of summedScoresPerInterval.
        summedScoresPerInterval(:, intervalIdx) = sum(scoresInterval, 2);
    end
end
