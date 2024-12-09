function conditionBehaviorAnalysis(colorPalette, timeInterval, ratio)
    % Performs behavioral analysis for a specific experimental condition and generates ethograms.
    %
    % Inputs:
    %   - colorPalette: (string) Color palette for plotting (default: 'Happy')
    %   - timeInterval: (string) Time interval for analysis ('Frame', 'Second', 'Minute')
    %   - ratio: (numeric) Ratio for threshold calculation (default: 0.75)
    %
    % This function processes condition-level behavior data, applies thresholds,
    % and generates ethograms for each experimental condition.

    % Set defaults for inputs if not provided
    if nargin < 1, colorPalette = 'Happy'; end
    if nargin < 2, timeInterval = 'Frame'; end
    if nargin < 3, ratio = 0.75; end

    % Add the 'functions' folder to the MATLAB path
    addFunctionsPath();
   
    % Extract filenames, behaviors, and fly details using a custom function
    % The function returns file names, number of behaviors and the behavior labels
    [filesNames, numBehaviors, behaviorLabels, ~, ~] = extractFilesAndLabels();
      
    % Process all the experiment data into a unified table structure
    allDataInTbl = processExperimentData(filesNames);
    
    % Group data by condition
    groupedData = findgroups(allDataInTbl.condition);  % Group the data by the "condition" column
        
    % Extract unique conditions from the data, keeping their original order
    uniqueConditions = unique(allDataInTbl.condition, 'stable');
    
    % Initialize matrices to store thresholds, number of movies per condition and normalized behavior data per condition
    conditionsThresholdMatrix = zeros(numBehaviors, length(uniqueConditions));
    numMoviesForEachCondition = zeros(length(uniqueConditions), 1);
    normalizedConditionsMats = cell(length(uniqueConditions), 1);

    % Variable to track the minimum number of frames across all conditions
    minFrames = inf;

    % Create output directories for storing results for each condition
    conditionDirs = createConditionDirectories(allDataInTbl, 'ConditionEthogram');
    
    % Get the total number of unique movies in the selected dataset
    totalMovies = length(unique(allDataInTbl.movie_number, 'stable'));
    
    % Loop over each unique condition and process its behavior data
    for i = 1:length(uniqueConditions)
        % Filter the data for the current condition
        conditionData = allDataInTbl(groupedData == i, :);
        
        % Group the data by the "movie_number" column
        groupedMovieData = findgroups(conditionData.movie_number);
        
        % Extract unique movies from the condition's data
        uniqueMovies = unique(conditionData.movie_number, 'stable');

        % Count the number of movies associated with the current condition
        numMoviesForEachCondition(i) = length(unique(conditionData.movie_number));

        normalizedMoviesMats = cell(length(uniqueMovies), 1);  % Initialize matrix to store normalized movie data
        moviesThresholdMatrix = zeros(numBehaviors, length(uniqueMovies));  % Matrix to store thresholds for each movie

        % Create a folder named 'conditionMovies' within the condition directory
        conditionMoviesDir = fullfile(conditionDirs{i}, 'moviesScoresMatrices');
        if ~exist(conditionMoviesDir, 'dir')
            mkdir(conditionMoviesDir); % Create the directory if it doesn't exist
        end
      
        % Loop over each movie in the current condition
        for j = 1:length(uniqueMovies)
            % Filter the data for the current movie
            movieData = conditionData(groupedMovieData == j, :);

            % Get movie name for saving files
            movieName = getMovieName(movieData.name_of_the_file{1});

            % Extract behavior matrices for the current movie
            [combinedScoresMatrices, numFlies, movieMinFrames] = extractFlyBehaviorMatrices(movieData, numBehaviors, totalMovies);

            % Update minFrames to reflect the minimum frames across all
            % the conditions
            minFrames = min([minFrames, movieMinFrames]);

            % Define file names for saving results
            summedScoresMatrixFileName = fullfile(conditionMoviesDir , sprintf('summedScoresMatrix_%s.csv', movieName));
            summedScoresPerIntervalFileName = fullfile(conditionMoviesDir, sprintf('summedScoresPer%s_%s.csv', timeInterval, movieName));
            normalizedMatFileName = fullfile(conditionMoviesDir, sprintf('normalizedMatPer%s_%s.csv', timeInterval, movieName));

            % Process movie data, apply thresholds, and normalize behavior matrices
            [defaultThresholds, normalizedBehaviorMat] = processMovieData(combinedScoresMatrices, numBehaviors, movieMinFrames, numFlies, timeInterval, ratio, summedScoresMatrixFileName, summedScoresPerIntervalFileName, normalizedMatFileName);

            % Store thresholds and normalized matrices for the current movie
            moviesThresholdMatrix(:, j) = defaultThresholds;
            normalizedMoviesMats{j} = normalizedBehaviorMat;
        end

        % Calculate the average thresholds across all movies for this condition
        conditionsThresholdMatrix(:, i) = mean(moviesThresholdMatrix, 2);
        % Store the normalized matrices for the condition
        normalizedConditionsMats{i} = normalizedMoviesMats;        
        
        % Prepare column names for the threshold data
        movieNames = cellfun(@(x) getMovieName(x), conditionData.name_of_the_file, 'UniformOutput', false);
        uniqueMovieNames = unique(movieNames, 'stable');
        columnNames = [{'Behavior'}, uniqueMovieNames', {'avgThreshold'}];

        % Combine behavior labels, thresholds, and average thresholds into a data table
        data = [behaviorLabels, num2cell(moviesThresholdMatrix), num2cell(conditionsThresholdMatrix(:, i))];
        
        % Convert the data into a table format and save it as a CSV file
        dataTable = cell2table(data, 'VariableNames', columnNames);
        for j = 1:length(conditionDirs)
            saveTableToCSV(conditionDirs{j}, sprintf('%s_thresholds', uniqueConditions{i}), dataTable);
        end
    end

    % Calculate the default thresholds as the minimum across all conditions
    defaultThresholds = min(conditionsThresholdMatrix, [], 2);

    % Call the GUI to allow the user to choose final thresholds
    thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);
    
    % Prepare column names for the default and final thresholds tables
    defaultColumnNames = [{'Behavior'}, uniqueConditions', {'defaultThreshold'}];
    finalColumnNames = [{'Behavior'}, uniqueConditions', {'finalThreshold'}];

    % Combine behavior labels, default thresholds, and final thresholds into data tables
    defaultData = [behaviorLabels, num2cell(conditionsThresholdMatrix), num2cell(defaultThresholds)];
    finalData = [behaviorLabels, num2cell(conditionsThresholdMatrix), num2cell(thresholds)];

    % Convert the data into tables and save them as CSV files
    defaultThresholdsTable = cell2table(defaultData, 'VariableNames', defaultColumnNames);
    finalThresholdsTable = cell2table(finalData, 'VariableNames', finalColumnNames);
    
    for i = 1:length(conditionDirs)
        saveTableToCSV(conditionDirs{i}, sprintf('defaultThresholds_%s', timeInterval), defaultThresholdsTable);
        saveTableToCSV(conditionDirs{i}, sprintf('finalThresholds_%s', timeInterval), finalThresholdsTable);
    end 

    % Apply the final thresholds to all conditions
    thresholdedMatrices = applyThresholdsToAll(normalizedConditionsMats, behaviorLabels, thresholds);

    % Generate final matrices based on the applied thresholds
    finalMatrices = conditionThresholds(thresholdedMatrices, minFrames, behaviorLabels, numBehaviors, timeInterval);

    % Loop over each condition and plot the common behavior matrix
    for i = 1:length(uniqueConditions)
        tempConditionName = uniqueConditions{i};  % Get the condition name
        conditionName = strrep(tempConditionName, '_', ' ');  % Format the condition name for display
        behaviorsMat = finalMatrices{i};  % Get the final behavior matrix for the condition
        
        % Plot the behavior matrix based on the selected time interval
        switch timeInterval
            case 'Frame'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Frame', ['Condition behavior per frame - ' conditionName]);
            case 'Second'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Second', ['Condition behavior per second - ' conditionName]);
            case 'Minute'
                plotBehaviorMatrix(colorPalette, behaviorsMat, behaviorLabels, 'Minute', ['Condition behavior per minute - ' conditionName]);
        end

        % Set figure size and resolution for saving the plot
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, 0, 6, 5]);
        
        % Save the plot as a PNG file in the condition directory
        for j = 1:length(conditionDirs)
            saveas(gcf, fullfile(conditionDirs{j}, ['ConditionBehavior_' conditionName '.png']), 'png');
        end 
        
    end
end

% Function to add the 'functions' folder to the MATLAB path
function addFunctionsPath()
    % Add the 'functions' folder to the MATLAB path.
    % This is needed to access helper functions in the 'functions' folder.
    
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
