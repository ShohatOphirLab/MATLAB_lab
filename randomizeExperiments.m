
data = struct();
data.fixedFileName = 'movie_fixed.mat';
data.fixedParametersFileName = 'movie_fix_parameters.mat';
data.trackingFileName = 'movie.mat';
data.movieFileName = 'movie.avi';
data.jaabaFileName = 'registered_trx.mat';
data.perframeDirName = 'perframe';
data.annFileName = 'movie.avi.ann';
data.numberOfFlies = 10;

%expFolders = uipickfiles('Prompt', 'Select folders to randomize');
%[suggestedPath, ~, ~] = fileparts(expFolders{1});
%savePath = uigetdir(suggestedPath, 'Select folder to save randomize experiments');

if length(expFolders) < numberOfFlies
    warndlg('Not enough folders to randomize');
    return;
end

trackingData = cell(1, length(expFolders));
randTrackingData = cell(1, length(expFolders));
minNumberOfFrames = inf;

for i = 1:length(expFolders)
    fileName = fullfile(expFolders{i}, data.fixedFileName);
    trackingData{i} = load(fileName);
    param = struct();
    [givenData, param, ~, ~] = createWorkingDatabase(fileName, param);
    if minNumberOfFrames > param.numberOfFrames
        minNumberOfFrames = param.numberOfFrames;        
    end
    trackingData{i}.givenData = givenData;
    varNames={'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'frame', 'count'};
    givenData = dataset([],[],[],[],[],[],[],[],'VarNames',varNames);
    randTrackingData{i}.givenData = givenData;
end

div = 0;

for j = 0:numberOfFlies - 1
    for i = 1:length(expFolders)
        curIndex = mod(i+div-1, length(expFolders)) + 1;
        curData = trackingData{curIndex}.givenData;
        randTrackingData{i}.givenData = [randTrackingData{i}.givenData; curData(curData.identity == j,:)];
    end
    div = div + 1;
end

folderPath = fullfile(savePath, 'Randomize data');
mkdir(folderPath);
subFolderNumber = 1;
counterTrx = 0;
counterPerframe = 0;

for i = 1:length(expFolders)
    randTrackingData{i}.givenData = sortrows(randTrackingData{i}.givenData, [7 6]);
    randTrackingData{i}.givenData(randTrackingData{i}.givenData.frame > minNumberOfFrames, :) = [];
    ntargets = repmat(numberOfFlies, minNumberOfFrames, 1);
    x_pos = randTrackingData{i}.givenData.x_pos;
    y_pos = randTrackingData{i}.givenData.y_pos;
    angle = randTrackingData{i}.givenData.angle;
    maj_ax = randTrackingData{i}.givenData.maj_ax;
    min_ax = randTrackingData{i}.givenData.min_ax;
    identity = randTrackingData{i}.givenData.identity;
    timestamps = trackingData{i}.timestamps(1:minNumberOfFrames);   
    newFolder = fullfile(folderPath, int2str(subFolderNumber));
    mkdir(newFolder);
    copyfile(fullfile(expFolders{i}, data.fixedFileName), newFolder);
    newFileName = fullfile(newFolder, data.fixedFileName);
    save(newFileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'ntargets', '-append');   
    subFolderNumber = subFolderNumber + 1;
    
    annName = fullfile(expFolders{i}, data.annFileName);
    paramsName = fullfile(expFolders{i}, data.fixedParametersFileName);
    movieName = fullfile(expFolders{i}, data.movieFileName);
    isSuccess = generateOneTrxFile(data, newFileName, annName, newFileName, paramsName, movieName, newFolder);
    counterTrx = counterTrx + isSuccess;

    perframedir = fullfile(newFolder, data.perframeDirName);
    dooverwrite = true;
    success = createPerframeFiles(data, newFolder, dooverwrite, perframedir);
    counterPerframe = counterPerframe + success;
end

if counterTrx ~= 0
    warndlg([num2str(counterTrx) ' trx file(s) could not be generated.']);
end

if counterPerframe ~= 0
    warndlg([num2str(counterPerframe) ' perframe directory(ies) could not be generated.']);
end

