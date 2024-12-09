function [filesNames, numBehaviors, behaviorLabels, condition, numFlies] = extractFilesAndLabels()
    % This function extracts file names, behavior labels, condition, and the number of flies
    % from the selected experiment scores files. It processes the file names to create behavior
    % labels and capitalizes them for uniformity.
    %
    % Outputs:
    % - filesNames: A cell array containing the names of the behavior score files.
    % - numBehaviors: The number of behaviors (derived from the number of files).
    % - behaviorLabels: A cell array of capitalized behavior labels extracted from the file names.
    % - condition: The condition name extracted from the file path.
    % - numFlies: The number of flies determined from one of the score files.

    % Prompt the user to select an example scores file using a file picker dialog
    expGroups = uipickfiles('Prompt', 'Select experiment scores file');
    
    % Extract the directory (path) from the selected file for saving further processing
    [suggestedPath, ~, ~] = fileparts(expGroups{1});
    savePath = suggestedPath;

    % Extract the condition name from the file path (second to last folder in the path)
    components = strsplit(savePath, '\');
    condition = components{end - 1};  % Assuming the condition name is located here

    % Change the current directory to the path where the score files are stored
    cd(savePath);

    % Find all score files with the pattern 'scores_*.mat'
    scoresfileName = "scores_*.mat";
    d_scores = dir(scoresfileName);
    scoresfileName = {d_scores.name};  % Extract the file names
    filesNames = scoresfileName;  % Store the file names in the output variable

    % Determine the number of behaviors based on the number of score files
    numBehaviors = numel(filesNames);

    % Initialize a cell array to store behavior labels
    behaviorLabels = cell(numBehaviors, 1);

    % Loop through each score file and extract the behavior name by removing prefixes and extensions
    for behaviorIdx = 1:numBehaviors
        behaviorLabels{behaviorIdx} = strrep(filesNames{behaviorIdx}, 'scores_', '');  % Remove 'scores_' prefix
        behaviorLabels{behaviorIdx} = strrep(behaviorLabels{behaviorIdx}, '.mat', '');  % Remove '.mat' extension
        behaviorLabels{behaviorIdx} = strrep(behaviorLabels{behaviorIdx}, '_', ' ');  % Replace underscores with spaces
    end

    % Capitalize each behavior label for consistency
    behaviorLabels = capitalizeBehaviorLabels(behaviorLabels);

    % Load one of the score files to determine the number of flies
    % We assume that each score file contains a matrix called 'allScores.postprocessed'
    scoresMatrix = load(filesNames{1}).allScores.postprocessed;

    % The number of flies is the number of columns in the score matrix
    numFlies = size(scoresMatrix, 2);

    % Display a success message
    disp("Successfully extracted files names and behavior labels.");
end

function capitalizedLabels = capitalizeBehaviorLabels(behaviorLabels)
    % This function capitalizes each word in the behavior labels.
    %
    % Inputs:
    % - behaviorLabels: A cell array of behavior labels.
    %
    % Output:
    % - capitalizedLabels: A cell array of behavior labels with each word capitalized.
    
    capitalizedLabels = cell(size(behaviorLabels));  % Initialize the output cell array
    for i = 1:length(behaviorLabels)
        % Split the label into individual words
        words = strsplit(behaviorLabels{i}, ' '); 
        
        % Capitalize the first letter of each word
        capitalizedWords = cellfun(@(word) [upper(word(1)), lower(word(2:end))], words, 'UniformOutput', false);
        
        % Join the capitalized words back together and store in the output array
        capitalizedLabels{i} = strjoin(capitalizedWords, ' ');
    end
end
