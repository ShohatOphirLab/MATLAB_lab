function thresholds = chooseThresholdsGUI(behaviorLabels, defaultThresholds)
    % This function creates a graphical user interface (GUI) that allows the user
    % to set thresholds for each behavior. If more than a certain number of behaviors 
    % are present, the panel becomes scrollable. The function validates user input, 
    % ensuring all values are between 0 and 1. If the user provides invalid inputs, 
    % a default value of 0.5 is used for those thresholds.
    %
    % Inputs:
    % - behaviorLabels: A cell array of strings containing the names of the behaviors.
    % - defaultThresholds: A vector of default thresholds for each behavior.
    %
    % Output:
    % - thresholds: A vector containing the user-specified thresholds (or defaults for invalid input).

    % Number of behaviors
    numBehaviors = length(behaviorLabels);

    % Define fixed dimensions for the figure and components
    figWidth = 400;
    figHeightNoScroll = 60 + numBehaviors * 30 + 50;  % Height without scrolling
    maxVisibleBehaviors = 13;  % Maximum number of visible behaviors before scrolling is enabled
    
    % Determine if scrolling is needed based on the number of behaviors
    if numBehaviors > maxVisibleBehaviors
        % Calculate height for a scrollable panel
        figHeight = 60 + maxVisibleBehaviors * 30 + 50; % Fixed height with scrolling
        useScroll = true;
    else
        % No need for scrolling, set height to accommodate all behaviors
        figHeight = figHeightNoScroll;
        useScroll = false;
    end

    % Create the main figure window for the GUI
    fig = uifigure('Name', 'Select Thresholds', 'Position', [100, 100, figWidth, figHeight]);
    
    % Add a title label at the top of the figure
    titleLabel = uilabel(fig, 'Text', 'Select Thresholds', 'FontSize', 16, 'FontWeight', 'bold', ...
                         'Position', [140, figHeight - 35, figWidth - 20, 30]);

    % Create a panel to hold the behavior labels and threshold input fields
    if useScroll
        % Create a scrollable panel if there are many behaviors
        scrollPanel = uipanel(fig, 'Position', [10, 60, figWidth - 20, figHeight - 70], 'Scrollable', 'on', ...
                              'BorderType', 'none');
        % Create a content panel inside the scrollable panel to hold the fields
        contentPanel = uipanel(scrollPanel, 'Position', [0, 0, figWidth - 20, numBehaviors * 30 + 20], ...
                               'BorderType', 'none');
    else
        % No scrolling needed, create a regular content panel
        contentPanel = uipanel(fig, 'Position', [10, 60, figWidth - 20, numBehaviors * 30 + 20], ...
                               'BorderType', 'none');
    end

    % Dynamically create labels and input fields for each behavior
    editFields = gobjects(numBehaviors, 1);  % Preallocate for edit fields
    labels = gobjects(numBehaviors, 1);  % Preallocate for labels
    for i = 1:numBehaviors
        % Create a label for each behavior
        labels(i) = uilabel(contentPanel, 'Text', behaviorLabels{i}, 'HorizontalAlignment', 'right', ...
                            'Position', [10, numBehaviors * 30 - i * 30 + 10, 150, 22]);

        % Create a numeric input field for each threshold with limits between 0 and 1
        editFields(i) = uieditfield(contentPanel, 'numeric', 'Limits', [0, 1], 'Value', defaultThresholds(i), ...
                                    'Position', [170, numBehaviors * 30 - i * 30 + 10, 100, 22]);
    end

    % Calculate positions for the OK and Cancel buttons at the bottom of the window
    buttonWidth = 100;
    buttonHeight = 30;
    figWidth = fig.Position(3);  % Get the width of the figure
    startX = (figWidth - (2 * buttonWidth + 10)) / 2;  % Center the buttons horizontally

    % Create OK and Cancel buttons
    okBtn = uibutton(fig, 'push', 'Text', 'OK', 'Position', [startX, 10, buttonWidth, buttonHeight], ...
                     'ButtonPushedFcn', @(btn, event) onOkButtonPressed(fig, editFields));
    cancelBtn = uibutton(fig, 'push', 'Text', 'Cancel', 'Position', [startX + buttonWidth + 10, 10, buttonWidth, buttonHeight], ...
                         'ButtonPushedFcn', @(btn, event) onCancelButtonPressed(fig));

    % Wait for the user to close the dialog before proceeding
    uiwait(fig);
    
    % Nested function to handle OK button press
    function onOkButtonPressed(fig, editFields)
        % Collect the thresholds entered by the user
        thresholds = arrayfun(@(ef) ef.Value, editFields);
        % Validate that the thresholds are within the range [0, 1]
        validInputs = ~isnan(thresholds) & thresholds >= 0.0 & thresholds <= 1.0;
        thresholds(~validInputs) = 0.5;  % Set invalid inputs to default value (0.5)
        if any(~validInputs)
            % Display a warning if any invalid inputs were encountered
            uialert(fig, 'Invalid input(s). Default number 0.5 was chosen for invalid threshold(s).', 'Warning');
        end

        uiresume(fig);  % Resume the GUI and return the thresholds
        delete(fig);  % Close the figure window
    end

    % Nested function to handle Cancel button press
    function onCancelButtonPressed(fig)
        delete(fig);  % Close the figure and exit
        return;
    end
end
