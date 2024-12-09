function [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(allBehaviors, numBehaviors, flyNum)
    % This function creates a matrix combining the postprocessed scores of all behaviors
    % for a specified fly. Each row of the matrix corresponds to one behavior, and each 
    % column represents a frame.
    %
    % Inputs:
    % - allBehaviors: A cell array of file paths, where each file contains data for a specific behavior.
    % - numBehaviors: The number of behaviors to include (i.e., the number of files in allBehaviors).
    % - flyNum: The index of the fly whose postprocessed scores should be used.
    %
    % Outputs:
    % - combinedScoresMatrix: A matrix where each row contains the postprocessed scores for a specific behavior.
    % - numFrames: The total number of frames for the behaviors (assumed to be the same across behaviors).

    % Initialize a cell array to store the scores for each behavior
    allScores = cell(1, numBehaviors);

    % Loop over each behavior to load its data and extract the postprocessed scores for the specified fly
    for behaviorIdx = 1:numBehaviors
        % Load the data for the current behavior
        behaviorData = load(allBehaviors{behaviorIdx});
        
        % Extract the postprocessed scores for the specified fly
        allScores{behaviorIdx} = behaviorData.allScores.postprocessed{flyNum};
    end

    % Determine the number of frames from the first behavior (assuming all behaviors have the same number of frames)
    numFrames = length(allScores{1});

    % Initialize the combined scores matrix with zeros
    % Rows correspond to behaviors, and columns correspond to frames
    combinedScoresMatrix = zeros(numBehaviors, numFrames);

    % Populate the matrix: convert each score vector into a row in the combined matrix
    for behaviorIdx = 1:numBehaviors
        combinedScoresMatrix(behaviorIdx, :) = allScores{behaviorIdx};
    end

    % Display a message indicating successful matrix creation
    disp("Successfully created matrix for all the behaviors.");
end
