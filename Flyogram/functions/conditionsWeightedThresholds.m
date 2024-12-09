% TODO: Check if the function is in use, if not - delete it
function finalThresholds = conditionsWeightedThresholds(conditionsThresholds, numMoviesForEachCondition)
    % This function calculates the weighted thresholds for a set of conditions.
    % The weighting is based on the number of movies associated with each condition.
    %
    % Inputs:
    % - conditionsThresholds: A matrix where each column represents the thresholds
    %   for a particular condition, and each row represents a specific behavior.
    % - numMoviesForEachCondition: A vector containing the number of movies
    %   for each condition, used to weight the thresholds.
    %
    % Output:
    % - finalThresholds: A vector of weighted thresholds, where the contribution of 
    %   each condition is based on the number of movies associated with that condition.
       
    % Calculate the total number of movies across all conditions
    totalMovies = sum(numMoviesForEachCondition);

    % Calculate the weights for each condition based on the number of movies
    weightsArray = numMoviesForEachCondition / totalMovies;  % Normalize by total movies

    % Transpose the weightsArray to match the dimensions of the threshold matrix
    weights = weightsArray.';  % Transpose to create a column vector

    % Multiply each column (condition's thresholds) by its corresponding weight
    weightedValues = conditionsThresholds .* weights;

    % Calculate the weighted mean for each row (behavior) across all conditions
    finalThresholds = sum(weightedValues, 2);  % Sum across the rows to get final weighted thresholds

    % Display a message indicating that the thresholds have been successfully set
    disp("Successfully set the default thresholds for the conditions.");
end
