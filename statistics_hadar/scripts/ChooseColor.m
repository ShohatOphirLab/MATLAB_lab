function [Gcolors] = ChooseColor(conditionName)

        color ="";
        groupNameDir =[];
        colorValue=[];
        
        groupNameDir=conditionName';
        
        for i =1:length(conditionName)
        s1='Select a color for ';
        [~,currentGroupName,~]=fileparts(groupNameDir(i));
        displayOrder =char(strcat(s1,{' '},currentGroupName));
        c = uisetcolor([1 1 0],displayOrder);
        color_in_char =[];
        color_in_char= sprintf(' %f', c)
        colorValue = [colorValue;c];
        end
        Gcolors = colorValue;
end