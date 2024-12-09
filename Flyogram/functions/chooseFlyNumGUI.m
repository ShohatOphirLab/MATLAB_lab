function flyNumber = chooseFlyNumGUI(numFlies)
    % This function creates a graphical user interface (GUI) that prompts the user
    % to select a fly number. The user can choose a number between 0 and numFlies,
    % where 0 represents all flies. The function checks if the input is valid 
    % and returns the selected fly number. If the input is invalid, it defaults to 1.
    %
    % Inputs:
    % - numFlies: The total number of flies to choose from.
    %
    % Output:
    % - flyNumber: The selected fly number, with 0 indicating all flies.
    
    % Create a dialog window to prompt the user for input
    dlgTitle = 'Select Fly Number';  % Title of the input dialog
    prompt = ['Select the fly number (between 0 and ' num2str(numFlies) ...
              ', where 0 means all flies):'];  % Instruction text for user
    numLines = 1;  % Number of lines for the input box
    defaultInput = {'1'};  % Default input value
    
    % Display the input dialog and store the user's input in a cell array
    flyNumber = inputdlg(prompt, dlgTitle, numLines, defaultInput);

    % Convert the input from a string (stored in a cell) to a numeric value
    flyNumber = str2double(flyNumber{1});
    
    % Check if the input is valid (a number between 0 and numFlies)
    if ~isempty(flyNumber) && isnumeric(flyNumber) && flyNumber >= 0 && flyNumber <= numFlies
        % If valid, flyNumber is used as provided
        % No further action needed
    else
        % If the input is invalid, set flyNumber to 1 (default value)
        flyNumber = 1;
        % Display a warning message indicating that the default value was chosen
        msgbox('Invalid input. Default number 1 was chosen.', 'Warning', 'warn');
    end
    
    % Print a message to the command window indicating successful selection
    disp("Successfully set fly number.");
end
