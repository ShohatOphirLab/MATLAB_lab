function movieBehaviorAnalysis(colorPalette, timeInterval, ratio)
    % Performs behavioral analysis on movie data and generates ethograms for each fly.
    %
    % Inputs:
    %   colorPalette  - (string) Color palette for plotting (default: 'Happy')
    %   timeInterval  - (string) Time interval for analysis ('Frame', 'Second', 'Minute')
    %   ratio         - (numeric) Ratio for threshold calculation (default: 0.75)
    %
    % The function processes movie-level behavior data, applies thresholding, and saves results.
    
    % Set defaults for inputs if not provided
    if nargin < 1, colorPalette = 'Happy'; end
    if nargin < 2, timeInterval = 'Frame'; end
    if nargin < 3, ratio = 0.75; end

    % Add the 'functions' folder to the MATLAB path
    addFunctionsPath();
    
    % Extract filenames, behaviors, and fly details using a custom function
    % The function returns file names, number of behaviors, behavior labels, condition, and the number of flies
    [filesNames, numBehaviors, behaviorLabels, condition, numFlies] = extractFilesAndLabels();
    
    % Create output directory for ethograms
    outputDir = fullfile(pwd, 'MovieEthogram');
    runDir = createAnalysisDirectory(outputDir, timeInterval);

    % Initialize a cell array to store combined scores matrices for each fly
    combinedScoresMatrices = cell(1, numFlies);
    minFrames = Inf;  % Initialize minimum frames tracker

    % Loop through each fly to create and store combined scores matrices
    for flyNum = 1:numFlies
        % Generate the combined scores matrix for the current fly
        [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(filesNames, numBehaviors, flyNum);
        
        % Store the combined scores matrix in the cell array
        combinedScoresMatrices{flyNum} = combinedScoresMatrix;
        
        % Track the minimum number of frames
        if numFrames < minFrames
            minFrames = numFrames;
        end
    end

    combinedScoresMatrices = cropMatricesToMinFrames(combinedScoresMatrices, minFrames);
    
    % Define file names for storing the summed and normalized matrices
    summedScoresMatrixFileName = fullfile(runDir, 'summedScoresMatrix.csv');
    summedScoresPerIntervalFileName = fullfile(runDir, sprintf('summedScoresPer%s.csv', timeInterval));
    normalizedMatFileName = fullfile(runDir, sprintf('normalizedMat%s.csv', timeInterval));

    % Process the movie data, including applying thresholds and normalization, and return the default thresholds
    [defaultThresholds, normalizedBehaviorMat] = processMovieData(...
        combinedScoresMatrices, numBehaviors, minFrames, numFlies, timeInterval, ratio, ...
        summedScoresMatrixFileName, summedScoresPerIntervalFileName, normalizedMatFileName);

    % Convert the default thresholds to a table and save them to a CSV file
    defaultThresholdsTable = table(behaviorLabels, defaultThresholds, 'VariableNames', {'Behavior', 'Default threshold'});
    saveTableToCSV(runDir, sprintf('defaultThresholds_%s', timeInterval), defaultThresholdsTable);

    % Use a GUI to allow the user to select final thresholds for each behavior
    thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);

    % Convert the final thresholds to a table and save them to a CSV file
    finalThresholdsTable = table(behaviorLabels, thresholds, 'VariableNames', {'Behavior', 'Final threshold'});
    saveTableToCSV(runDir, sprintf('finalThresholds_%s', timeInterval), finalThresholdsTable);

    % Apply the final thresholds to create a binary behavior matrix (0/1 values)
    binaryBehaviorMat = applyThresholds(normalizedBehaviorMat, behaviorLabels, thresholds);

    % Save the binary behavior matrix to a CSV file
    binaryBehaviorMatFileName = fullfile(runDir, sprintf('binaryBehaviorMat_%s.csv', timeInterval));
    writematrix(binaryBehaviorMat, binaryBehaviorMatFileName);
    
    % Replace underscores in the condition name for display purposes
    conditionName = strrep(condition, '_', ' ');

    % Plot the binary behavior matrix and set the appropriate labels based on the time interval
    switch timeInterval
        case 'Frame'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Frame',...
                ['Total movie behavior per frame- ' conditionName]);
        case 'Second'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Time (sec)',...
                ['Total movie behavior per second- ' conditionName]);
        case 'Minute'
            plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, 'Time (min)',...
                ['Total movie behavior per minute- ' conditionName]);
    end

    % Set the figure size and resolution for plotting
    set(gcf, 'Units', 'inches');
    set(gcf, 'Position', [0, 0, 6, 5]);
    
    % Save the plot as a PNG file in the run directory
    saveas(gcf, fullfile(runDir, sprintf('MovieBehavior_%s_%s.png', condition, timeInterval)), 'png');
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

function runDir = createAnalysisDirectory(baseDir, timeInterval)
    % Create or recreate the directory for the current run
    runDir = fullfile(baseDir, sprintf('moviePer%s', timeInterval));
    if isfolder(runDir)
        rmdir(runDir, 's');  % Remove directory if it exists
    end
    mkdir(runDir);
end

function croppedMatrices = cropMatricesToMinFrames(matrices, minFrames)
    % Print the final minimum number of frames
    fprintf('The minimum number of frames across all flies is: %d\n', minFrames);

    % Crop each matrix to match the minimum number of frames
    for i = 1:length(matrices)
        matrices{i} = matrices{i}(:, 1:minFrames);
    end
    croppedMatrices = matrices;
end
