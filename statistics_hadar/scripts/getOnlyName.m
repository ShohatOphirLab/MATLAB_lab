function names = getOnlyName(allNamesScores)
   % allNamesScores = allBehaviors;
    numFiles = numel(allNamesScores);
    names = cell(numFiles, 1);

    for i = 1:numFiles
        [~, name, ~] = fileparts(allNamesScores{i});
        name = strrep(name, 'scores_', '');
        names{i} = name;
    end
end