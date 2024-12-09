function singleFlyBehaviorAnalysis(colorPalette, timeInterval, ratio)
    % Performs behavioral analysis for a single fly and generates an ethogram.
    %
    % Inputs:
    %   colorPalette  - (string) Color palette for plotting (default: 'Happy')
    %   timeInterval  - (string) Time interval for analysis ('Frame', 'Second', 'Minute')
    %   ratio         - (numeric) Ratio for threshold calculation (default: 0.75)
    %
    % This function reads behavior data, applies thresholding, and saves the results 
    % to a directory. It also generates plots based on the selected options.

    % Set defaults for inputs if not provided
    if nargin < 1, colorPalette = 'Happy'; end
    if nargin < 2, timeInterval = 'Frame'; end
    if nargin < 3, ratio = 0.75; end

    % Add the 'functions' folder to the MATLAB path
    addFunctionsPath();
    
    % Extract filenames, behaviors, and fly details
    [filesNames, numBehaviors, behaviorLabels, condition, numFlies] = extractFilesAndLabels();

    % Create the output directory for saving ethograms if it doesn't exist
    outputDir = fullfile(pwd, 'SingleFlyEthogram');  % Define output directory
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);  % Create directory if it doesn't exist
    end
    
    % Use GUI to choose the fly number to analyze
    flyNum = chooseFlyNumGUI(numFlies);

    % Process all flies if flyNum is 0, otherwise process the selected fly
    if flyNum == 0
        for flyIdx = 1:numFlies
            % Create a new directory for this fly and time interval
            runDir = createRunDirectory(outputDir, flyIdx, timeInterval);
            % Process and analyze data for this fly
            processSingleFly(flyIdx, filesNames, numBehaviors, behaviorLabels, condition, ...
                timeInterval, ratio, runDir, colorPalette);
        end
    else
        % Process only the selected fly
        runDir = createRunDirectory(outputDir, flyNum, timeInterval);
        processSingleFly(flyNum, filesNames, numBehaviors, behaviorLabels, condition, ...
            timeInterval, ratio, runDir, colorPalette);
    end
end

% Function to create a unique directory for each fly, including flyNum and timeInterval
function runDir = createRunDirectory(outputDir, flyNum, timeInterval)
    % Create a directory specific to the current analysis run (fly number and time interval)
    runDir = fullfile(outputDir, sprintf('flyNum%d_%s', flyNum, timeInterval));
    
    % If the directory already exists, delete it and its contents
    if exist(runDir, 'dir')
        rmdir(runDir, 's');  % Remove directory and all contents
    end
    
    % Create the directory for saving the output
    mkdir(runDir);
end

% Function to add the 'functions' folder to the MATLAB path
function addFunctionsPath()
    % Add the 'functions' folder to the MATLAB path.
    % This is needed to access helper functions in the 'functions' folder.
    
    % Get the directory of the current script
    scriptDir = fileparts(mfilename('fullpath'));
    
    % Define the path to the 'functions' folder
    functionsDir = fullfile(scriptDir, '..', 'functions');
    
    % Add the functions folder to the path if it exists
    if exist(functionsDir, 'dir')
        addpath(functionsDir);
    else
        error('The functions directory does not exist.');
    end
end

% Function to process and plot behavior for a single fly
function processSingleFly(flyNum, filesNames, numBehaviors, behaviorLabels, condition, ...
    timeInterval, ratio, runDir, colorPalette)
    
    % Create the combined scores matrix for the specified fly
    [combinedScoresMatrix, numFrames] = createCombinedScoresMatrix(filesNames, numBehaviors, flyNum);

    % Get the number of frames per the selected time interval
    numFramesPerInterval = getNumFramesPerInterval(timeInterval);

    % Calculate summed behavior scores for each interval
    summedScoresPerInterval = calculateSummedScoresPerInterval(combinedScoresMatrix, numBehaviors, numFrames, numFramesPerInterval);

    % Apply thresholds if the time interval is 'Second' or 'Minute'
    if strcmp(timeInterval, 'Second') || strcmp(timeInterval, 'Minute')
        % Apply thresholding logic to the summed scores
        binaryBehaviorMat = applyThresholdLogic(summedScoresPerInterval, behaviorLabels, ratio, ...
            numFramesPerInterval, runDir, flyNum, timeInterval);
    else
        % No thresholding for 'Frame' interval, use the summed scores directly
        binaryBehaviorMat = summedScoresPerInterval;
    end

    % Save the binary behavior matrix as a CSV file
    binaryBehaviorMatFileName = fullfile(runDir, sprintf('fly%d_binaryMatrix_%s.csv', flyNum, timeInterval));
    writematrix(binaryBehaviorMat, binaryBehaviorMatFileName);

    % Replace underscores in condition name for display purposes
    conditionName = strrep(condition, '_', ' ');

    % Set the title and time label for plotting based on the selected time interval
    switch timeInterval
        case 'Frame'
            timeLabel = 'Frame';
            plotTitle = sprintf('Single fly behavior per frame - %s FlyNum %d', conditionName, flyNum);
        case 'Second'
            timeLabel = 'Time (sec)';
            plotTitle = sprintf('Single fly behavior per second - %s FlyNum %d', conditionName, flyNum);
        case 'Minute'
            timeLabel = 'Time (min)';
            plotTitle = sprintf('Single fly behavior per minute - %s FlyNum %d', conditionName, flyNum);
    end

    % Plot the binary behavior matrix using the provided color palette
    plotBehaviorMatrix(colorPalette, binaryBehaviorMat, behaviorLabels, timeLabel, plotTitle);

    % Set the figure size and resolution for saving the plot
    set(gcf, 'Units', 'inches');
    set(gcf, 'Position', [0, 0, 6, 5]);
    
    % Save the figure as a PNG file in the run directory
    saveas(gcf, fullfile(runDir, sprintf('FlyNum_%d_%s.png', flyNum, timeInterval)), 'png');
end

% Function to apply thresholding and save results
function [binaryBehaviorMat] = applyThresholdLogic(summedScoresPerInterval, behaviorLabels, ratio, numFramesPerInterval, runDir, flyNum, timeInterval)
    % Apply thresholds to the behavior matrix and save the results.
    
    % Calculate the default thresholds using the provided ratio
    defaultThresholds = adjustedThreshold(summedScoresPerInterval, ratio, numFramesPerInterval);
    
    % Save the default thresholds as a CSV table
    defaultThresholdsTable = table(behaviorLabels, defaultThresholds, 'VariableNames', {'Behavior', 'Default threshold'});
    saveTableToCSV(runDir, sprintf('fly%d_defaultThresholds_%s', flyNum, timeInterval), defaultThresholdsTable);
    
    % Normalize the behavior matrix (per interval)
    normalizedBehaviorMat = summedScoresPerInterval / numFramesPerInterval;
    
    % Save the normalized behavior matrix as a CSV file
    normalizedBehaviorMatFileName = fullfile(runDir, sprintf('fly%d_normalizedMatrix_%s.csv', flyNum, timeInterval));
    writematrix(normalizedBehaviorMat, normalizedBehaviorMatFileName);

    % Call the threshold GUI function to choose final thresholds
    thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds);
    
    % Save the final thresholds selected via GUI as a CSV file
    finalThresholdsTable = table(behaviorLabels, thresholds, 'VariableNames', {'Behavior', 'Final threshold'});
    saveTableToCSV(runDir, sprintf('fly%d_finalThresholds_%s', flyNum, timeInterval), finalThresholdsTable);
    
    % Apply the chosen thresholds to get a binary behavior matrix
    binaryBehaviorMat = applyThresholds(normalizedBehaviorMat, behaviorLabels, thresholds);
end
