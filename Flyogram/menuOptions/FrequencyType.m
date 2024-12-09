classdef FrequencyType
    % FrequencyType - Enumeration class for representing the frequency types
    % in the ScriptChooserApp.
    %
    % This enumeration lists the different time intervals for analysis,
    % which users can select from the FrequencyDropDown menu.
    
    enumeration
        Frame  % Frequency per frame
        Second % Frequency per second
        Minute % Frequency per minute
    end
end
