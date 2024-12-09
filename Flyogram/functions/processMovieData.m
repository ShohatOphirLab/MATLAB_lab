function [defaultThresholds, normalizedBehaviorMat] = processMovieData(...
    combinedScoresMatrices, numBehaviors,...
    maxFrames, numFlies, timeInterval,...
    ratio, summedScoresfileName, summedScoresPerIntervalFileName, normalizedMatFileName)
    % This function processes behavior data for multiple flies and saves several matrices
    % including summed scores and normalized behavior matrices. It also calculates default
    % thresholds for behaviors based on summed scores.
    %
    % Inputs:
    % - combinedScoresMatrices: A cell array where each element is a matrix containing behavior scores
    %   for a single fly, with dimensions (numBehaviors x numFrames).
    % - numBehaviors: The number of behaviors in the experiment.
    % - maxFrames: The maximum number of frames across all flies.
    % - numFlies: The number of flies being processed.
    % - timeInterval: The time interval over which frames are grouped (e.g., 'Second', 'Minute').
    % - ratio: The ratio used to adjust the threshold values.
    % - summedScoresfileName: The name of the file to save the summed scores matrix.
    % - summedScoresPerIntervalFileName: The name of the file to save the summed scores per interval.
    % - normalizedMatFileName: The name of the file to save the normalized behavior matrix.
    %
    % Outputs:
    % - defaultThresholds: The calculated default thresholds for the behaviors.
    % - normalizedBehaviorMat: The normalized behavior matrix based on the summed scores per interval.

    % Initialize the summed scores matrix across all flies (sum along frames)
    summedScoresMatrix = zeros(numBehaviors, maxFrames);

    % Sum the combined scores matrices from all flies
    for flyNum = 1:numFlies
        summedScoresMatrix = summedScoresMatrix + combinedScoresMatrices{flyNum};
    end

    % Save the summed scores matrix to a CSV file
    writematrix(summedScoresMatrix, summedScoresfileName);

    % Get the number of frames per interval based on the specified time interval
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);
    
    % Calculate the number of frames per interval times the number of flies
    RF = numFramesPerInterval * numFlies;
    
    % Initialize and calculate the summed behavior scores per interval
    summedScoresPerInterval = calculateSummedScoresPerInterval(...
        summedScoresMatrix, numBehaviors, maxFrames, numFramesPerInterval);

    % Save the summed scores per interval to a CSV file
    writematrix(summedScoresPerInterval, summedScoresPerIntervalFileName);

    % Calculate the default thresholds for each behavior based on the ratio and RF
    defaultThresholds = adjustedThreshold(summedScoresPerInterval, ratio, RF);

    % Normalize the summed scores per interval by dividing by RF (numFramesPerInterval * numFlies)
    normalizedBehaviorMat = summedScoresPerInterval / RF;

    % Save the normalized behavior matrix to a CSV file
    writematrix(normalizedBehaviorMat, normalizedMatFileName);
end
