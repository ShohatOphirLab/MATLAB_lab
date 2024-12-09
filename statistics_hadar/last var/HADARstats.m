function HADARstats()
% 
% DATE: 27-09-2023
%
% This function contain 4 options:
%
% 1) General Statistics - 2 outputs: (a) calculate the average for each behavior, bout
% length, inter bout length and 79 other features the mean per each movie.
% you can see it in each folder of the subgroups. (b) claculate the average
% per condition, you can find it in the father folder (or you can choose
% where to put the file. this file needed for farther analysis.
%
% 2)cohen Dtest- test the size effect. output: csv file with the data
%
% 3) correlation plot- calculate correlation between features (y axis) and
% condition (x axis) the condition must be at least in order scale!!!!
%
% 4) widthFormat for personality- independently project
%
% If you have any Q please keep it to yourself
%

AnotherRound =1;
while AnotherRound
    options = {'cohenD test', 'GeneralStatistics', 'correlationPlot', 'Personality'};
    choose_answer = menu('Choose an option:', options);
    % % % choose_answer = questdlg('Statistics Option:', ...
	% % %     'optionts', ...
	% % %     'cohenD test','GeneralStatistics','correlationPlot','Personality','GeneralStatistics');
    % Handle response
    switch choose_answer
        case 1 %'cohenD test'
            disp([choose_answer ' start running cohen D test']);
            f = msgbox("notice requirements:\n 1)General Stats ");
            change = 1;
        case 2 %'GeneralStatistics'
            disp([choose_answer ' start running GeneralStat']);
            f = msgbox("notice requirements:\n 1) ");
            change = 2;
        case 3 %'correlationPlot'
            disp([choose_answer ' start running correlation plot']);
            f = msgbox("notice requirements:\n 1) ");
            change = 3;
        case 4 %'Personality'
            disp([choose_answer ' start running correlation plot']);
            f = msgbox("notice requirements:/n 1) ");
            change = 4;

    end

  if change ==1;

      % cohen d test
      saveRes = uipickfiles('Prompt', 'Select folder of excel');    
      cd(saveRes{1,1})
      saveRes{1,1}
      cellMeanData_transpose = table2cell(readtable('myStatDataFile.csv','VariableNamingRule','preserve'));
      cohenDtest(cellMeanData_transpose,saveRes{1,1});
      f = msgbox("finished. You can see know the csv files in your directory as you selected");
      disp("finished. You can see know the csv files in your directory as you selected");
      AnotherRound = again();
  elseif change ==2;
      % General Statistics
      addpath(genpath('D:\MATLAB\runAll\try_boutinterlegth'));
      addpath(genpath('D:\MATLAB\statistics_hadar'));
      Hadar_Statistics_meanstd()
      f = msgbox("finished. You can see know the csv files in your directory as you selected");
      AnotherRound = again();
  elseif change ==3;
        % correlationPlot
        addpath(genpath('D:\MATLAB\statistics_hadar'));
        CorrPlotGeneral()
        disp("finished. You can see know the csv files in your directory as you selected")
        AnotherRound = again();
  elseif change ==4;
        % width format for personality
        addpath(genpath('D:\MATLAB\statistics_hadar'));
        addpath(genpath('D:\MATLAB\personaltyProject'));
     choose_answer = questdlg('What Sex?:', ...
	'optionts', ...
	    'Female','Male','Female');
     switch choose_answer
         case 'Female'
            WhatSex = 1;
         case 'Male'
            WhatSex = 2;
     end
        cd_for_saved_data = uipickfiles('Prompt', 'Select father folder for saving');
        cd_for_saved_data = cd_for_saved_data{1};
        WidthFormat4Personality(cd_for_saved_data,WhatSex)
        disp("finished.")
        AnotherRound = again();
  end
end