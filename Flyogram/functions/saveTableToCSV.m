function saveTableToCSV(folderPath, fileName, dataTable)
    % This function saves a MATLAB table to a CSV file at the specified folder path.
    % If the folder does not exist, it is created.
    %
    % Inputs:
    % - folderPath: The directory path where the CSV file will be saved.
    % - fileName: The name of the CSV file (without extension).
    % - dataTable: The table to be saved to the CSV file.
    
    % Check if the folder exists; if not, create the folder
    if ~isfolder(folderPath)
        mkdir(folderPath);  % Create the folder if it doesn't exist
    end
    
    % Define the full output file path, including the CSV extension
    outputFileName = fullfile(folderPath, [fileName, '.csv']);
    
    % Save the table to the specified CSV file
    writetable(dataTable, outputFileName);
    
    % Display a message indicating that the table has been successfully saved
    disp(['Table saved to ', outputFileName]);
end
