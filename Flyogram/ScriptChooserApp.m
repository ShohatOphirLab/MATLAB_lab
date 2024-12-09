 classdef ScriptChooserApp < matlab.apps.AppBase
    % This class defines an App for selecting and running different scripts
    % based on user input from dropdown menus. The App allows users to 
    % select actions, frequency, color palettes, and threshold ratios, 
    % and then run the corresponding script based on their selections.

    % Properties that correspond to app components
    properties (Access = private)
       UIFigure        matlab.ui.Figure             % Main UI figure
        ActionDropDown  matlab.ui.control.DropDown   % Dropdown for selecting action
        FrequencyDropDown matlab.ui.control.DropDown % Dropdown for selecting frequency
        PaletteDropDown matlab.ui.control.DropDown   % Dropdown for selecting color palette
        RatioDropDown   matlab.ui.control.DropDown   % Dropdown for selecting threshold ratio
        RunButton       matlab.ui.control.Button     % Button to run the selected script
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % This function is called at the startup of the app. 
            
            % Add the menuOptions folder to the MATLAB path
            optFolder = fullfile(fileparts(mfilename('fullpath')), 'menuOptions');
            if exist(optFolder, 'dir')
                addpath(optFolder);
            else
                error('The menuOptions directory does not exist.');
            end

            % Add the analysisScripts folder to the MATLAB path
            analysisScriptsFolder = fullfile(fileparts(mfilename('fullpath')), 'analysisScripts');
            if exist(analysisScriptsFolder, 'dir')
                addpath(analysisScriptsFolder);
            else
                error('The analysisScripts directory does not exist.');
            end
            
            % Populate dropdowns with enum values, converting them to strings
            app.ActionDropDown.Items = cellstr(string(enumeration('ActionType')));   % Convert enum to cell array of strings
            app.FrequencyDropDown.Items = cellstr(string(enumeration('FrequencyType'))); % Convert enum to cell array of strings
            app.PaletteDropDown.Items = cellstr(string(enumeration('PaletteType')));  % Convert enum to cell array of strings
            app.RatioDropDown.Items = {'0.75', '0.65'};
        end

        % Helper function to enable/disable UI components
        function setUIComponentsEnabled(app, enableState)
            app.ActionDropDown.Enable = enableState;
            app.FrequencyDropDown.Enable = enableState;
            app.PaletteDropDown.Enable = enableState;
            app.RatioDropDown.Enable = enableState;
            app.RunButton.Enable = enableState;
        end

        % Button pushed function: RunButton
        function runButtonPushed(app, ~)
            % This is the main function that executes when the "Run" button
            % is pressed. It gathers the selected options from the dropdowns,
            % calls the appropriate analysis function, and then resets the UI.

            % Disable UI components
            setUIComponentsEnabled(app, 'off');

            % Convert selected dropdown values to enums
            selectedAction = ActionType.(app.ActionDropDown.Value);  % Convert string to enum
            selectedFrequency = FrequencyType.(app.FrequencyDropDown.Value);  % Convert string to enum
            selectedPalette = PaletteType.(app.PaletteDropDown.Value);  % Convert string to enum
            selectedRatio = str2double(app.RatioDropDown.Value);
                    
            % Execute the selected script using enums
            switch selectedAction
                case ActionType.SingleFly
                    singleFlyBehaviorAnalysis(selectedPalette, selectedFrequency, selectedRatio);
                case ActionType.Movie
                    movieBehaviorAnalysis(selectedPalette, selectedFrequency, selectedRatio);
                case ActionType.Condition
                    conditionBehaviorAnalysis(selectedPalette, selectedFrequency, selectedRatio);
                case ActionType.RepresentativeFly
                    representativeFlyAnalysis(selectedPalette, selectedFrequency, selectedRatio);
                otherwise
                    disp('Invalid script selection');
            end

            % Re-enable UI components
            setUIComponentsEnabled(app, 'on');
            
            % Ask if the user wants to enter more movies
            answer = questdlg('Do you want to create more plots?', ...
                              'Enter More Movies', ...
                              'Yes', 'No', 'No');
            if strcmp(answer, 'No')
                % Close the UI figure if the user doesn't want to enter more movies
                close(app.UIFigure);
            else
                % Reset dropdowns to their default values if the user wants to enter more movies
                app.ActionDropDown.Value = app.ActionDropDown.Items{1};
                app.FrequencyDropDown.Value = app.FrequencyDropDown.Items{1};
                app.PaletteDropDown.Value = app.PaletteDropDown.Items{1};
                app.RatioDropDown.Value = app.RatioDropDown.Items{1};
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 300 240];
            app.UIFigure.Name = 'Script Chooser';

            % Create ActionDropDown
            uilabel(app.UIFigure, 'Text', 'Action', 'Position', [20 190 100 22]);
            app.ActionDropDown = uidropdown(app.UIFigure);
            app.ActionDropDown.Position = [20 170 120 22];

            % Create FrequencyDropDown
            uilabel(app.UIFigure, 'Text', 'Frequency', 'Position', [160 190 100 22]);
            app.FrequencyDropDown = uidropdown(app.UIFigure);
            app.FrequencyDropDown.Position = [160 170 120 22];

            % Create PaletteDropDown
            uilabel(app.UIFigure, 'Text', 'Color palette', 'Position', [160 120 100 22]);
            app.PaletteDropDown = uidropdown(app.UIFigure);
            app.PaletteDropDown.Position = [160 100 120 22];
            
            % Create RatioDropDown
            uilabel(app.UIFigure, 'Text', 'Threshold ratio', 'Position', [20 120 100 22]);
            app.RatioDropDown = uidropdown(app.UIFigure);
            app.RatioDropDown.Position = [20 100 120 22];

            % Create Information Button next to RatioDropDown
            infoButton = uibutton(app.UIFigure, 'push');
            infoButton.Text = '?';
            infoButton.Position = [120 125 20 22];
            infoButton.ButtonPushedFcn = @(~, ~) showExplanation(app);
        
            % Callback function to show/hide the explanation
            function showExplanation(app)
                % Create Explanation Figure
                explanationFigure = uifigure('Position', [410 100 300 150], 'Name', 'Explanation');
                
                % Create Explanation Label
                explanationText = sprintf('The ratio according to which the threshold value\nof each behavior will be calculated.\nThe recommended default value is 0.75,\n\nHowever, for the purpose of creating an ethogram\nof conditions according to a large number of\nmovies, or conditions with high variability,\nwe would reccomend lowering the value to 0.65.');
                uilabel(explanationFigure, 'Text', explanationText, 'Position', [20 10 270 150]);
        
                % Wait for the explanation figure to be deleted
                waitfor(explanationFigure);
            end

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @runButtonPushed, true);
            app.RunButton.Position = [120 20 60 22];
            app.RunButton.Text = 'Run';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ScriptChooserApp
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code to execute before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
