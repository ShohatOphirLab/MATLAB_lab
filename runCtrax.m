ctraxPath = '"C:\Program Files (x86)\Ctrax-0.5\Ctrax"';

handles = struct();
namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
if exist(namesFile, 'file') == 2
    load(namesFile);
    handles.fixedFileName = fixedFileName;
    handles.fixedParametersFileName = fixedParametersFileName;
    handles.trackingFileName = trackingFileName;
    handles.movieFileName = movieFileName;
    handles.jaabaFileName = jaabaFileName;
    handles.perframeDirName = perframeDirName;
    handles.annFileName = annFileName;
else
    h = warndlg('Please choose files'' names.');
    waitfor(h);
    handles.fixedFileName = 'movie_fixed.mat';
    handles.fixedParametersFileName = 'movie_fix_parameters.mat';
    handles.trackingFileName = 'movie.mat';
    handles.movieFileName = 'movie.avi';
    handles.jaabaFileName = 'registered_trx.mat';
    handles.perframeDirName = 'perframe';
    handles.annFileName = 'movie.avi.ann';
end


settingsPath = fullfile(fileparts(which('runAll')), 'settings\Regular.ann');
[file,path] = uigetfile(settingsPath, 'Select settings file');
if isequal(file,0)
   return;
else
   settingFileName = fullfile(path, file);
end

handles.allFolders = uipickfiles('Prompt', 'Select Folders To Fix');
if isequal(handles.allFolders, 0) || isempty(handles.allFolders)
    return
end
missingIndx = zeros(1, length(handles.allFolders));
for i = 1:length(handles.allFolders)
    folderPath = handles.allFolders{i};
    if contains(folderPath, ' ')
        warndlg('Path shouldn''t have spaces');
    end
    files = dir(handles.allFolders{i});
    if ~any(strcmp({files.name}, handles.movieFileName))
        missingIndx(i) = i;
    end
end
missingIndx(missingIndx == 0) = [];
if ~isempty(missingIndx)
    h = msgbox([num2str(length(missingIndx)) ' folder(s) don’t have ' handles.movieFileName ' file. Ignored.']);
    uiwait(h);
end
indxs = 1:length(handles.allFolders);
indxs(ismember(indxs, missingIndx)) = [];
handles.allFolders = handles.allFolders(indxs);
handles.waitBar = waitbar(0, 'Running Ctrax on files...');
for i = 1:length(handles.allFolders) 
    folderPath = handles.allFolders{i};
    if exist(fullfile(folderPath, handles.perframeDirName), 'dir') == 7
      rmdir(fullfile(folderPath, handles.perframeDirName), 's');
    end
    delete(fullfile(folderPath, handles.annFileName));
    delete(fullfile(folderPath, handles.trackingFileName));
    delete(fullfile(folderPath, handles.fixedParametersFileName));
    delete(fullfile(folderPath, handles.fixedFileName));
    delete(fullfile(folderPath, handles.jaabaFileName));
    commend = [ctraxPath, ' --Interactive=False', ' --Input=', fullfile(folderPath, handles.movieFileName), ' --MatFile=', fullfile(folderPath, handles.trackingFileName), ' --SettingsFile=', settingFileName, ' --AutoEstimateShape=True'];
    system(commend);
    waitbar(i / length(handles.allFolders))
end
bar = handles.waitBar;
close(bar);
