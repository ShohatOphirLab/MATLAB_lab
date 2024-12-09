function representativeFlyMatrix = computeRepresentativeFly(conditionMatrix, singleFliesMatrices)
    % This function computes the representative fly matrix from a set of single fly matrices.
    % The representative fly is selected by calculating the "loss" (a weighted difference)
    % between each single fly matrix and the condition matrix. The fly matrix with the 
    % minimum loss is chosen as the representative.
    %
    % Inputs:
    % - conditionMatrix: The matrix representing the condition (e.g., average behavior across flies)
    % - singleFliesMatrices: A cell array where each element is a matrix of behaviors for a single fly
    %
    % Output:
    % - representativeFlyMatrix: The matrix of the fly that best represents the condition
    %
    % Internal Variables:
    % - numFlies: The number of single flies (i.e., the number of matrices in singleFliesMatrices)
    % - lossArray: An array that stores the calculated loss for each fly

    % Get the number of flies (single fly matrices)
    numFlies = size(singleFliesMatrices, 2);

    % Initialize an array to store the loss value for each fly
    lossArray = zeros(1, numFlies);
    
    % Calculate the behavior probabilities used as weights for the loss function
    behaviorProbabilities = calculateLossFunctionWeights(conditionMatrix);

    % Compute the loss for each single fly matrix
    for flyIdx = 1:numFlies
        % Extract the behavior matrix for the current fly
        singleFlyMatrix = singleFliesMatrices{flyIdx};
       
        % If the single fly matrix has fewer columns (intervals) than the condition matrix,
        % pad the fly matrix with zeros to match the condition matrix's size
        if size(singleFlyMatrix, 2) < size(conditionMatrix, 2)
            paddingSize = size(conditionMatrix, 2) - size(singleFlyMatrix, 2);
            singleFlyMatrix = [singleFlyMatrix, zeros(size(singleFlyMatrix, 1), paddingSize)];
        end

        % Compute the absolute difference between the condition matrix and the single fly matrix
        absDiff = abs(conditionMatrix - singleFlyMatrix);

        % Apply behavior probabilities (weights) to the absolute difference
        weightedAbsDiff = bsxfun(@times, absDiff, behaviorProbabilities);

        % Sum the weighted differences to compute the loss for the current fly
        lossArray(flyIdx) = sum(weightedAbsDiff, 'all');
    end
    
    % Find the fly with the minimum loss value (most representative of the condition)
    [~, minIndex] = min(lossArray);
    
    % Return the representative fly matrix (the matrix with the minimum loss)
    representativeFlyMatrix = singleFliesMatrices{minIndex};
end
