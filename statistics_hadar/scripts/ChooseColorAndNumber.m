function [Gcolors, Gnumbers] = ChooseColorAndNumber(conditionName)

    color = "";
    groupNameDir = [];
    colorValue = [];
    numbers = [];

    groupNameDir = conditionName';

    for i = 1:length(conditionName)
        s1 = 'Select a color for ';
        [~, currentGroupName, ~] = fileparts(groupNameDir(i));
        displayOrder = char(strcat(s1, {' '}, currentGroupName));
        c = uisetcolor([1 1 0], displayOrder);
        color_in_char = sprintf(' %f', c);
        colorValue = [colorValue; c];

        % Prompt the user for a number using an input dialog
        prompt = sprintf('Enter a number for %s:', currentGroupName);
        dlgtitle = 'Number Input';
        dims = [1 35];
        definput = {'0'};
        number = inputdlg(prompt, dlgtitle, dims, definput);

        if isempty(number)
            % User canceled number input, use 0 as default
            number = '0';
        end

        numbers = [numbers; str2double(number)];
    end

    Gcolors = colorValue;
    Gnumbers = numbers';
end
