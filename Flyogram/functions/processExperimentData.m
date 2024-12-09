function allDatainTbl = processExperimentData(allBehaviors)
    % This function processes experiment data by generating tables based on selected
    % experiment group folders and extracting behavior data from those folders.
    % It constructs a table with fly behavior data, including additional metadata like
    % condition, sex, and movie number, and then sorts the table based on condition names.
    %
    % Inputs:
    % - allBehaviors: A cell array containing the file names of behavior data.
    %
    % Output:
    % - allDatainTbl: A table containing the processed data from all experiments, 
    %   including behavior scores and associated metadata (condition, sex, etc.).

    % Prompt the user to select experiment group folders
    expGroups = uipickfiles('Prompt', 'Select experiment groups folders');
    [suggestedPath, ~, ~] = fileparts(expGroups{1});
    savePath = suggestedPath;  % Suggested path for saving results
    numOfGroups = length(expGroups);  % Number of experiment groups

    % Initialize variables for experiment group data
    groupNameDir = expGroups';  % Store the selected folder paths
    NumberofMovie = {1:numOfGroups}';  % Create a list of movie numbers
    condition = {};  % Initialize a cell array for conditions

    % Loop over each group to extract condition and sex information
    for j = 1:numOfGroups
        % Extract the file path for the current group
        fileNamePath = groupNameDir(j);
        
        % Extract the condition name from the folder path
        findStr = strfind(fileNamePath, "\");
        findStr = cell2mat(findStr);
        vecLen = length(findStr);
        char_fileNamePath = char(fileNamePath);
        condition{j} = char_fileNamePath(findStr(vecLen - 1) + 1:findStr(vecLen) - 1);
        
        % Determine the sex (Male/Female) based on folder name
        if strfind(char_fileNamePath, "Male")
            sex{j} = "Males";
        elseif strfind(char_fileNamePath, "Female")
            sex{j} = "Females";
        else
            sex{j} = [];
        end

        NumberofMovie{j} = j;  % Assign the movie number
    end

    % Prepare the data for the experiment tables
    condition = condition';
    sex = sex';
    NumberofMovie = NumberofMovie';

    % Create a table with experiment group information
    experimentTables = table(groupNameDir, NumberofMovie, condition, sex);

    % Initialize a cell array to store behavior data
    counter = 0;
    cellBehavior = cell(0, 5 + length(allBehaviors));

    % Loop through each movie group to process behavior data
    for numberMovie = 1:numOfGroups
        name_of_the_file = char(experimentTables{numberMovie, 1});
        name_of_the_condition = experimentTables{numberMovie, 3};
        number_of_movie = experimentTables{numberMovie, 2};

        % Change the directory to the current experiment group folder
        cd(name_of_the_file)

        % Loop through each behavior file to load behavior data
        for jj = 1:length(allBehaviors)
            load(cell2mat(allBehaviors(jj)));  % Load the behavior data
            ii = length(allScores.postprocessed);  % Number of flies in the data

            % Loop through each fly to extract behavior scores
            for numFly = 1:ii
                behaviorPerFileScore = allScores.postprocessed{1, numFly};
                % Store the metadata and behavior scores in cellBehavior
                cellBehavior{numFly + counter, 1} = numFly;  % Fly number
                cellBehavior{numFly + counter, 2} = name_of_the_file;  % File path
                cellBehavior{numFly + counter, 3} = numberMovie;  % Movie number
                cellBehavior{numFly + counter, 4} = char(experimentTables.sex{numberMovie});  % Sex
                cellBehavior{numFly + counter, 5} = name_of_the_condition;  % Condition
                cellBehavior{numFly + counter, jj + 5} = behaviorPerFileScore;  % Behavior score
            end
        end

        % Update the counter to keep track of the total number of flies processed
        counter = counter + ii;
    end

    % Create a table from the cell array containing behavior data
    Title_old = ["fly", "name_of_the_file", "movie_number", "sex", "condition"];
    TitleNames = [Title_old, allBehaviors];  % Combine metadata titles with behavior titles
    TitleNames = regexprep(TitleNames, '.mat', '');  % Remove ".mat" from behavior names
    allDatainTbl = cell2table(cellBehavior, 'VariableNames', TitleNames);  % Create table

    % Check if condition names contain digits for sorting
    conditionNumeric = regexp(allDatainTbl.condition, '\d+', 'match');
    conditionHasDigits = ~cellfun('isempty', conditionNumeric);

    if any(conditionHasDigits)
        % If conditions contain numeric parts, sort them numerically
        conditionNumeric = cellfun(@(x) str2double(x{1}), conditionNumeric(conditionHasDigits));
        sortedConditionIdx = find(conditionHasDigits);
        [~, sortIdx] = sort(conditionNumeric);  % Sort conditions based on numeric part
        sortedIdx = sortedConditionIdx(sortIdx);
        % Combine sorted numeric conditions with non-numeric ones
        allDatainTbl = allDatainTbl([sortedIdx; find(~conditionHasDigits)], :);
    end

    % Display a success message
    disp("Successfully processed the experiment data.");
end
