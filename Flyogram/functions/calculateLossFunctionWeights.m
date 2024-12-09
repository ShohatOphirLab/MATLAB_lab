function behaviorProbabilities = calculateLossFunctionWeights(conditionMatrix)
    % This function calculates the probability of each behavior based on its
    % frequency of occurrence in the provided condition matrix.
    %
    % Inputs:
    %   - conditionMatrix: A matrix where each row corresponds to a behavior,
    %                      and each column corresponds to an occurrence across time.
    %                      Values are binary (0 or 1), indicating the presence of a behavior.
    %
    % Outputs:
    %   - behaviorProbabilities: A vector where each element is the probability
    %                            of the corresponding behavior (row in the matrix).

    % Sum each row of the conditionMatrix to get the total count of occurrences
    % of each behavior across time.
    behaviorCounts = sum(conditionMatrix, 2);

    % Sum the entire matrix to get the total number of occurrences (i.e., the sum
    % of all 1s in the matrix).
    totalOccurrences = sum(conditionMatrix(:));

    if totalOccurrences == 0
        behaviorProbabilities = zeros(size(behaviorCounts));  % All probabilities set to zero
        return;
    end

    % Calculate the probability of each behavior by dividing the count of each
    % behavior by the total number of occurrences across all behaviors.
    behaviorProbabilities = behaviorCounts / totalOccurrences;
    
    % Display the probabilities for each behavior for reference
    disp('Behavior probabilities calculated successfully.');
end
