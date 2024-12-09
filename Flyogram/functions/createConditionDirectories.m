function paths = createConditionDirectories(alldataintbl, folderName)
    % This function creates directories for each unique condition found in the input table.
    % For each condition, it finds the corresponding file paths, extracts the parent directory,
    % and creates a new directory with the specified folder name within the parent directory.
    % If the directory already exists, it is removed and recreated.
    %
    % Inputs:
    % - alldataintbl: A table containing data with a 'condition' column and 'name_of_the_file' column.
    % - folderName: The name of the folder to be created for each condition.
    %
    % Output:
    % - paths: A cell array of the newly created folder paths for each condition.
    
    % Get the unique conditions from the 'condition' column of the table
    conditions = unique(alldataintbl.condition);
    
    % Initialize a cell array to store the paths of the created directories
    paths = cell(length(conditions), 1);
    
    % Loop through each unique condition
    for i = 1:length(conditions)
        % Get the current condition
        condition = conditions{i};
        
        % Find the rows in the table that match the current condition
        conditionRows = alldataintbl(strcmp(alldataintbl.condition, condition), :);
        
        % Extract the file path from the first matching row for the condition
        filePath = conditionRows.name_of_the_file{1};
        
        % Extract the parent directory path from the file path
        [parentDir, ~, ~] = fileparts(filePath);
        
        % Create the full path for the new directory with the specified folder name
        specifiedDir = fullfile(parentDir, folderName);
        
        % Check if the directory already exists; if it does, remove it
        if isfolder(specifiedDir)
            rmdir(specifiedDir, 's');  % Remove the directory and its contents
        end
        
        % Create the new directory
        mkdir(specifiedDir);
        
        % Store the created path in the cell array
        paths{i} = specifiedDir;
    end
    
    % Display a message indicating that the directories were successfully created
    disp(['Directories created with folder name: ', folderName]);
end
