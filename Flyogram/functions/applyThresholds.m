function binaryBehaviorMat = applyThresholds(normalizedMatrix, behaviorLabels, thresholds)
    % Apply behavior-specific thresholds to a normalized behavior matrix and return a binary matrix.
    %
    % Inputs:
    %   - normalizedMatrix: (matrix) Matrix of normalized behavior scores.
    %   - behaviorLabels: (cell array) Labels for each row (behavior).
    %   - thresholds: (vector) Threshold values for each behavior.
    %
    % Output:
    %   - binaryBehaviorMat: (matrix) Binary matrix after applying thresholds.
    
    % Initialize the output matrix as a copy of the normalized matrix
    binaryBehaviorMat = normalizedMatrix;

    % Apply the threshold to each behavior (row) in the matrix
    for behaviorIdx = 1:numel(behaviorLabels)
        % Apply the threshold: 0 for below threshold, 1 for equal or above threshold
        binaryBehaviorMat(behaviorIdx, :) = ...
            normalizedMatrix(behaviorIdx, :) >= thresholds(behaviorIdx);
    end
end
