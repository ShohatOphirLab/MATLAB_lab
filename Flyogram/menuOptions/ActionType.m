classdef ActionType
    % ActionType - Enumeration class for representing the different actions
    % in the ScriptChooserApp.
    %
    % This enumeration lists the available actions that a user can select 
    % from the ActionDropDown menu in the ScriptChooserApp. The actions
    % represent the type of analysis to be performed.
    
    enumeration
        SingleFly         % Single Fly analysis option
        Movie             % Movie analysis option
        Condition         % Condition-based analysis option
        RepresentativeFly % Representative Fly analysis option
    end
end
