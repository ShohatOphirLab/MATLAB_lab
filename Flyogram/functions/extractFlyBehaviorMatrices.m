function [combinedScoresMatrices, numFlies, minFrames] = extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies)
    % This function extracts and creates combined behavior score matrices for each fly,
    % based on the behavior data provided in movieData. It processes multiple behavior vectors
    % for each fly, computes the number of frames, and crops the matrices to the minimum
    % number of frames across all flies to ensure consistency.
    %
    % Inputs:
    % - movieData: A table or dataset where each row corresponds to a fly and each column after the 5th
    %   contains behavior vectors for different behaviors.
    % - numBehaviors: The number of behaviors (number of behavior vectors to extract per fly).
    % - totalMovies: The total number of movies (used to switch between two different data structures).
    %
    % Outputs:
    % - combinedScoresMatrices: A cell array where each element is a matrix of combined behavior scores for a fly.
    % - numFlies: The number of flies, determined by the number of rows in movieData.
    % - minFrames: The minimum number of frames across all flies, used to crop all matrices to the same length.

    % Determine the number of flies based on the height (number of rows) of movieData
    numFlies = height(movieData);
    
    % Initialize a cell array to store combined scores matrices for each fly
    combinedScoresMatrices = cell(1, numFlies);
    
    % Initialize minFrames with infinity to track the minimum number of frames across all flies
    minFrames = inf;

    % If the total number of movies is greater than 2, extract behavior data starting from column 6
    if totalMovies > 2
        % Loop through each fly to create and store the combined scores matrices
        for flyNum = 1:numFlies
            % Extract the behavior data for the current fly (from column 6 onward)
            behaviorData = movieData{flyNum, 6:end};
    
            % Determine the number of frames from the first behavior vector
            numFrames = numel(behaviorData{1});
    
            % Update the minimum number of frames
            if numFrames < minFrames
                minFrames = numFrames;
            end
    
            % Initialize the matrix for the current fly
            combinedScoresMatrix = zeros(numBehaviors, numFrames);
            
            % Populate the matrix with behavior vectors for the current fly
            for behaviorIdx = 1:numBehaviors
                combinedScoresMatrix(behaviorIdx, :) = behaviorData{behaviorIdx};
            end
            
            % Store the matrix in the cell array
            combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        end
    else
        % If totalMovies is 2 or fewer, use a different extraction method (column 5+ for behaviors)
        for flyNum = 1:numFlies
            % Preallocate a cell array to store individual behavior vectors
            behaviorData = cell(1, numBehaviors);

            % Iterate through each behavior to extract its vector
            for behaviorIdx = 1:numBehaviors
                % Extract the behavior vector for the current fly and behavior index
                behaviorData{behaviorIdx} = movieData{flyNum, 5 + behaviorIdx};
            end
    
            % Determine the number of frames from the first behavior vector
            numFrames = numel(behaviorData{1});
    
            % Update the minimum number of frames
            if numFrames < minFrames
                minFrames = numFrames;
            end
    
            % Initialize the matrix for the current fly
            combinedScoresMatrix = zeros(numBehaviors, numFrames);
            
            % Populate the matrix with behavior vectors for the current fly
            for behaviorIdx = 1:numBehaviors
                combinedScoresMatrix(behaviorIdx, :) = behaviorData{behaviorIdx};
            end
            
            % Store the matrix in the cell array
            combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        end
    end
    
    % After processing all flies, crop the matrices to the minimum number of frames
    combinedScoresMatrices = cropMatricesToMinFrames(combinedScoresMatrices, minFrames);

    % Display the final minimum number of frames and success message
    fprintf('Successfully created combined scores matrices for all flies.\n');
    fprintf('The minimum number of frames across all flies is: %d\n', minFrames);
end

function croppedMatrices = cropMatricesToMinFrames(matrices, minFrames)
    % This helper function crops each matrix in the input cell array to match the minimum number of frames.
    % Inputs:
    % - matrices: A cell array of matrices, where each matrix is cropped to minFrames.
    % - minFrames: The minimum number of frames to which each matrix should be cropped.
    % Output:
    % - croppedMatrices: The input matrices cropped to the specified number of frames.

    for i = 1:length(matrices)
        % Crop each matrix to have only the first 'minFrames' columns
        matrices{i} = matrices{i}(:, 1:minFrames);
    end
    croppedMatrices = matrices;
end
