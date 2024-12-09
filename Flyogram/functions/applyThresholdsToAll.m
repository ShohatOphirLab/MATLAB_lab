function thresholdedMatrices = applyThresholdsToAll(normalizedMatsCell, behaviorLabels, thresholds)
    % Applies thresholding to all behavior matrices across different conditions and movies.
    %
    % Inputs:
    %   - normalizedMatsCell: Cell array containing normalized behavior matrices
    %                         for each condition and movie.
    %   - behaviorLabels: Cell array containing the names of the behaviors (for reference).
    %   - thresholds: Vector containing the threshold values for each behavior.
    %
    % Outputs:
    %   - thresholdedMatrices: Cell array containing the binary matrices after
    %                          thresholding, for each condition and movie.
    
    % Get the number of conditions from the input cell array
    numConditions = length(normalizedMatsCell);
    
    % Initialize the output cell array for storing thresholded matrices
    thresholdedMatrices = cell(numConditions, 1);
    
    % Loop through each condition
    for condIdx = 1:numConditions
        % Get the number of movies for the current condition
        numMovies = length(normalizedMatsCell{condIdx});
        
        % Initialize cell array for the current condition's thresholded matrices
        thresholdedMatrices{condIdx} = cell(numMovies, 1);
        
        % Loop through each movie in the current condition
        for movieIdx = 1:numMovies
            % Get the normalized matrix for the current movie
            normalizedMatrix = normalizedMatsCell{condIdx}{movieIdx};
            
            % Apply the threshold to the normalized matrix for each behavior
            thresholdedMatrix = applyThresholds(normalizedMatrix, behaviorLabels, thresholds);
            
            % Store the thresholded binary matrix in the output cell array
            thresholdedMatrices{condIdx}{movieIdx} = thresholdedMatrix;
        end
    end
end
