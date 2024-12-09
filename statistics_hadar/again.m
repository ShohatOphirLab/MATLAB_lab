function AnotherRound = again()
        choose_answer = questdlg('Do you want to run another thing?:', ...
	    'optionts', ...
	    'Yes','No','Yes');
    % Handle response
    switch choose_answer
        case 'Yes'
             
            AnotherRound = 1;
        case 'No'
    
            AnotherRound = 0;
end