% TODO: right now the cell contains all the flies of the condition - we to separate the different films, 
% so that we can return to the user the name of the film and the number of the selected fly. 
% In addition to this, save the values ​​of the loss function, and the final matrix chosen as representative.
function representativeFlyAnalysis(colorPalette, timeInterval, ratio)
    % This function performs behavior analysis for each experimental condition
    % and identifies the most representative fly based on behavior data.
    %
    % Inputs:
    %   - colorPalette: (string) Color palette for plotting (default: 'Happy')
    %   - timeInterval: (string) Time interval for analysis ('Frame', 'Second', 'Minute')
    %   - ratio: (numeric) Ratio for threshold calculation (default: 0.75)

    % Set default values if not provided
    if nargin < 1, colorPalette = 'Happy'; end
    if nargin < 2, timeInterval = 'Frame'; end
    if nargin < 3, ratio = 0.75; end

    % Add the 'functions' folder to the MATLAB path
    addFunctionsPath();
   
    % Extract file names, behavior labels, and other details from data files
    [filesNames, numBehaviors, behaviorLabels, ~, ~] = extractFilesAndLabels();
      
    % Process experimental data and convert it into a table format
    allDataInTbl = processExperimentData(filesNames);
    
    % Group the data by the "condition" column
    groupedData = findgroups(allDataInTbl.condition);
        
    % Get unique experimental conditions in the dataset
    uniqueConditions = unique(allDataInTbl.condition, 'stable');

    % Create directories to store ethogram data for each condition
    conditionDirs = createConditionDirectories(allDataInTbl, 'representativeFlyEthogram');
    
    % Get the total number of unique movies in the dataset
    totalMovies = length(unique(allDataInTbl.movie_number, 'stable'));
    
    % Loop over each unique experimental condition
    for i = 1:length(uniqueConditions)
        % Filter data for the current condition
        conditionData = allDataInTbl(groupedData == i, :);
        
        % Group the data by "movie_number" to handle multiple movies in the same condition
        groupedMovieData = findgroups(conditionData.movie_number);
        
        % Get unique movie identifiers for the current condition
        uniqueMovies = unique(conditionData.movie_number, 'stable');

        % Initialize matrices to store thresholds and behavior data
        moviesThresholdMatrix = zeros(numBehaviors, length(uniqueMovies));
        normalizedMoviesMats = cell(length(uniqueMovies), 1);

        % Variable to track the minimum number of frames across all conditions
        minFrames = inf;

        % Initialize a container to store fly behavior matrices
        singleFliesMatrices = [];

        % Create a folder within the condition directory to store movie score matrices
        conditionMoviesDir = fullfile(conditionDirs{i}, 'moviesScoresMatrices');
        if ~exist(conditionMoviesDir, 'dir')
            mkdir(conditionMoviesDir);  % Create directory if it doesn't exist
        end
        
        % Get the number of frames per the selected time interval
        numFramesPerInterval = getNumFramesPerInterval(timeInterval);

        % Loop over each unique movie in the current condition
        for j = 1:length(uniqueMovies)
            % Filter data for the current movie
            movieData = conditionData(groupedMovieData == j, :);

            % Get the name of the current movie for saving files
            movieName = getMovieName(movieData.name_of_the_file{1});

            % Extract behavior matrices for all flies in the movie and get the minimum number of frames
            [combinedScoresMatrices, numFlies, movieMinFrames] = ...
                extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies);

            % Append the behavior matrices of the current movie to the collection
            singleFliesMatrices = [singleFliesMatrices, combinedScoresMatrices];

            % Update the minimum number of frames
            minFrames = min([minFrames, movieMinFrames]);

            % File names for saving the movie's processed data
            summedScoresMatrixFileName = fullfile(conditionMoviesDir , sprintf('summedScoresMatrix_%s.csv', movieName));
            summedScoresPerIntervalFileName = fullfile(conditionMoviesDir, sprintf('summedScoresPer%s_%s.csv', timeInterval, movieName));
            normalizedMatFileName = fullfile(conditionMoviesDir, sprintf('normalizedMatPer%s_%s.csv', timeInterval, movieName));

            % Process the movie data, apply thresholds, and normalize the behavior matrices
            [defaultThresholds, normalizedBehaviorMat] = ...
                processMovieData(combinedScoresMatrices, numBehaviors, movieMinFrames, numFlies, ...
                timeInterval, ratio, summedScoresMatrixFileName, ...
                summedScoresPerIntervalFileName, normalizedMatFileName);

            % Store the thresholds and normalized matrices for the current movie
            moviesThresholdMatrix(:, j) = defaultThresholds;
            normalizedMoviesMats{j} = normalizedBehaviorMat;
        end

        % Calculate average thresholds across all movies for the current condition
        conditionThresholds = mean(moviesThresholdMatrix, 2);

        % Prepare column names for saving thresholds
        movieNames = cellfun(@(x) getMovieName(x), conditionData.name_of_the_file, 'UniformOutput', false);
        uniqueMovieNames = unique(movieNames, 'stable');
        columnNames = [{'Behavior'}, uniqueMovieNames', {'avgThreshold'}];

        % Combine behavior labels and thresholds into a data table
        data = [behaviorLabels, num2cell(moviesThresholdMatrix), num2cell(conditionThresholds)];
        
        % Save the data table as a CSV file
        dataTable = cell2table(data, 'VariableNames', columnNames);
        saveTableToCSV(conditionDirs{i}, sprintf('%s_thresholds_%s', uniqueConditions{i}, timeInterval), dataTable);

        % Apply thresholds to the normalized matrices for each movie
        thresholdedMoviesMats = cell(length(uniqueMovies), 1);
        for j = 1:length(uniqueMovies)
            thresholdedMoviesMats{j} = applyThresholds(normalizedMoviesMats{j}, behaviorLabels, conditionThresholds);
        end

        % Combine the thresholded matrices to compute the overall condition matrix
        conditionMatrix = computeGeneralConditionMat(thresholdedMoviesMats, minFrames, behaviorLabels, numBehaviors, timeInterval);
    
        % Crop the behavior matrices of all flies to match the minimum number of frames
        singleFliesMatrices = cropMatricesToMinFrames(singleFliesMatrices, minFrames);

        % Normalize and apply thresholds for 'Second' or 'Minute' intervals
        if strcmp(timeInterval, 'Second') || strcmp(timeInterval, 'Minute')
            for matrixIdx = 1:length(singleFliesMatrices)
                singleFlyMatrix = singleFliesMatrices{matrixIdx};

                % Calculate summed scores per interval
                summedScoresPerInterval = calculateSummedScoresPerInterval(singleFlyMatrix, numBehaviors, size(singleFlyMatrix, 2), numFramesPerInterval);
                
                % Normalize behavior matrix by the number of frames per interval
                normalizedBehaviorMat = summedScoresPerInterval / numFramesPerInterval;
                
                % Apply thresholds to the normalized behavior matrix
                singleFliesMatrices{matrixIdx} = applyThresholds(normalizedBehaviorMat, behaviorLabels, conditionThresholds);
            end
        end

        % Compute the representative fly matrix based on the processed data
        representativeFlyMatrix = computeRepresentativeFly(conditionMatrix, singleFliesMatrices);

        % Format the condition name for display
        tempConditionName = uniqueConditions{i};
        conditionName = strrep(tempConditionName, '_', ' ');

        % Plot the representative fly behavior matrix based on the selected time interval
        switch timeInterval
            case 'Frame'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Frame', ['RepresentiveFly per frame - ' conditionName]);
            case 'Second'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Second', ['RepresentiveFly per second - ' conditionName]);
            case 'Minute'
                plotBehaviorMatrix(colorPalette, representativeFlyMatrix, behaviorLabels, 'Minute', ['RepresentiveFly per minute - ' conditionName]);
        end

        % Set figure size and resolution for saving the plot
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, 0, 6, 5]);

        % Save the plot as a PNG file
        saveas(gcf, fullfile(conditionDirs{i}, sprintf('RepresentiveFly_%s_%s.png', conditionName, timeInterval)), 'png');   
    end
end

% Function to add the 'functions' folder to the MATLAB path
function addFunctionsPath()
    % Add the 'functions' folder to the MATLAB path for accessing helper functions.
    
    % Get the directory of the current script
    scriptDir = fileparts(mfilename('fullpath'));
    
    % Define the path to the 'functions' folder (one directory level up)
    functionsDir = fullfile(scriptDir, '..', 'functions');
    
    % Add the functions folder to the path if it exists
    if exist(functionsDir, 'dir')
        addpath(functionsDir);  % Add the directory to the path
    else
        error('The functions directory does not exist.');
    end
end

% Function to crop behavior matrices to the minimum number of frames
function croppedMatrices = cropMatricesToMinFrames(matrices, minFrames)
    % Print the final minimum number of frames
    fprintf('The minimum number of frames across all flies is: %d\n', minFrames);

    % Crop each matrix to match the minimum number of frames
    for i = 1:length(matrices)
        matrices{i} = matrices{i}(:, 1:minFrames);
    end
    croppedMatrices = matrices;
end
