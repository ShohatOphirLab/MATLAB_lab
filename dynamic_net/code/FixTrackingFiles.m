function varargout = FixTrackingFiles(varargin)
% FIXTRACKINGFILES MATLAB code for FixTrackingFiles.fig
%      FIXTRACKINGFILES, by itself, creates a new FIXTRACKINGFILES or raises the existing
%      singleton*.
%
%      H = FIXTRACKINGFILES returns the handle to a new FIXTRACKINGFILES or the handle to
%      the existing singleton*.
%
%      FIXTRACKINGFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIXTRACKINGFILES.M with the given input arguments.
%
%      FIXTRACKINGFILES('Property','Value',...) creates a new FIXTRACKINGFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FixTrackingFiles_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FixTrackingFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FixTrackingFiles

% Last Modified by GUIDE v2.5 21-Feb-2018 16:53:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FixTrackingFiles_OpeningFcn, ...
    'gui_OutputFcn',  @FixTrackingFiles_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before FixTrackingFiles is made visible.
function FixTrackingFiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FixTrackingFiles (see VARARGIN)

% Choose default command line output for FixTrackingFiles
handles.output = hObject;

handles.currentFolder = 0;

handles.closeFigure = false;
handles.fixOnly = false;

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
    h = warndlg('No files'' names found. default names used.');
    waitfor(h);
    handles.fixedFileName = 'movie_fixed.mat';
    handles.fixedParametersFileName = 'movie_fix_parameters.mat';
    handles.trackingFileName = 'movie.mat';
    handles.movieFileName = 'movie.avi';
    handles.jaabaFileName = 'registered_trx.mat';
    handles.perframeDirName = 'perframe';
    handles.annFileName = 'movie.avi.ann';
end


handles.fixedFileName = fixedFileName;
handles.fixedParametersFileName = fixedParametersFileName;
handles.trackingFileName = trackingFileName;
handles.movieFileName = movieFileName;
handles.jaabaFileName = jaabaFileName;
handles.perframeDirName = perframeDirName;
handles.annFileName = annFileName;

currentFile = mfilename( 'fullpath' );
[currentpath,~,~] = fileparts( currentFile );
handles.arenasdir = fullfile(currentpath, 'arenas\');

handles.allFolders = uipickfiles('Prompt', 'Select Folders To Fix');
if isequal(handles.allFolders, 0) || isempty(handles.allFolders)
    handles.closeFigure = true;
else
    handles = checkFiles(handles);
end


if ~handles.closeFigure
    [handles, ~] = initialize(handles);
end
if handles.fixOnly
    [handles, done] = initialize(handles);
    if done
        handles = fixAllFolders(handles);
    end
end



% Update handles structure
guidata(hObject, handles);
% UIWAIT makes FixTrackingFiles wait for user response (see UIRESUME)
% uiwait(handles.fixTrackingFig);


function [handles, done] = initialize(handles)
handles.arenasNumber = -1;
handles.skip = false;
handles.fliesNumber = -1;
handles.fileName = -1;
handles.lineDrawnLength = -1;
handles.lineLength = -1;
handles.axisLength = -1;
handles.layoutName = -1;
handles.fliesData = -1;
handles.arenasData = -1;
handles.spotsData = [];
handles.mmPerPixel = -1;
handles.curView = 0;
handles.fixedFilesNames = {};
handles.numberOfFlies = [];
handles.numberOfFrames = [];
handles.arenasNames = strings(1, 1);
handles.params = getParams();
handles.currentFolder = handles.currentFolder + 1;
if handles.currentFolder > length(handles.foldersToGetParams)
    done = true;
    return;
end
handles = showFirstFrame(handles);
fileNames = dir([handles.arenasdir '*.mat']);
fileNames = cellfun(@(x) x(1:end-4),{fileNames.name},'Un',0);
set(handles.layoutList, 'String', fileNames);
setLocations(handles);
done = false;

function [params] = getParams()
fileName = fullfile('params', 'current.mat');
if exist(fileName, 'file') == 2
    load(fileName);
    return;
end
params = struct();
params.sameFlySpeed = 10;
params.flyMinWalkingSpeed = 1.5;
params.notWalkingPenalty = 1.2;
params.oneErrorThreshold = 1;
params.secBetweenCalculations = 1;
params.maxFlySpeed = 160;
params.flyMaxLength = 4;
params.framesPenalty = 10;
params.noOverlappingFrames = -1;
params.maxJumpFrames = 10;
params.currentTimeLimit = 20;
params.currentDistanceLimit = 10;
params.precisionRate = 0.8;
params.disappearSecThreshold = 50;
params.framesPercentToDelete = 0.1;
params.fliesPercentToDelete = 0.25;
params.maxTimeLimit = 300;
params.maxDistanceLimit = 80;
params.endTimeLimit = 2;
params.endDistanceLimit = 5;
params.maxObviousDistance = 5;
params.maxObviousTime = 3.5;
params.minObviousDistance = 1.5;
params.minObviousTime = 1;
params.maxErrorLength = 10;
params.runScoreBaseAlgorithm = 1;
params.runMinorChangesAlgorithm = 1;
params.firstFrame = 0;
params.lastFrame = inf;
params.useOriginalFileForJaaba = 0;
params.deleteUnifiedFolder = 1;



function handles = checkFiles(handles)
fixedIndx = zeros(1, length(handles.allFolders));
paramIndx = zeros(1, length(handles.allFolders));
missingIndx = zeros(1, length(handles.allFolders));
for i = 1:length(handles.allFolders)
    files = dir(handles.allFolders{i});
    if ~any(strcmp({files.name}, handles.trackingFileName)) || ~any(strcmp({files.name}, handles.movieFileName)) || ~any(strcmp({files.name}, handles.annFileName))
        missingIndx(i) = i;
        continue;
    end
    if any(strcmp({files.name}, handles.fixedFileName))
        fixedIndx(i) = i;
    end
    if any(strcmp({files.name}, handles.fixedParametersFileName))
        paramIndx(i) = i;
    end
end
fixedIndx(fixedIndx == 0) = [];
paramIndx(paramIndx == 0) = [];
missingIndx(missingIndx == 0) = [];
if ~isempty(missingIndx)
    h = msgbox([num2str(length(missingIndx)) ' folder(s) don’t have movie or tracking files. Ignored.']);
    uiwait(h);
end
indxs = 1:length(handles.allFolders);
indxs(ismember(indxs, missingIndx)) = [];
if ~isempty(fixedIndx)
    button = questdlg([num2str(length(fixedIndx)) ' folder(s) are already fixed. Would you like to re-fix them?']);
    if ~isequal(button, 'Yes')
        indxs(ismember(indxs, fixedIndx)) = [];
        paramIndx(ismember(paramIndx, fixedIndx)) = [];
    end
end
handles.foldersToFix = handles.allFolders(indxs);
if ~isempty(paramIndx)
    button = questdlg([num2str(length(paramIndx)) ' folder(s) are already having initial fixing parameters. Would you like to retake them?']);
    if ~isequal(button, 'Yes')
        indxs(ismember(indxs, paramIndx)) = [];
    end
end
handles.foldersToGetParams = handles.allFolders(indxs);
if isempty(handles.foldersToFix) || isempty(handles.foldersToGetParams)
    handles.closeFigure = true;
end
if isempty(handles.foldersToGetParams)
    handles.fixOnly = true;
end


function handles = showFirstFrame(handles)
axes(handles.arenasAxes);
currentPath = handles.foldersToGetParams{handles.currentFolder};
movieName = fullfile(currentPath, handles.movieFileName);
if isequal(getFileType(currentPath, handles), '.ufmf')
    [readframe, ~, ~, ~] = get_readframe_fcn(movieName);
    [image, ~, ~, ~, ~] = readframe(1);
    imagesc(image,'Parent',handles.arenasAxes,[0,255]);
    colormap(handles.arenasAxes, 'gray');
    axis(handles.arenasAxes,'image','off');
    %axis(handles.arenasAxes,[0,size(image,2)+1,0,size(image,1)+1]);
    %hold(handles.arenasAxes,'on');
    %plot(handles.arenasAxes,nan(1,2),nan(1,2),'r-');
    imagesc(image,'Parent',handles.frameAxes,[0,255]);
    colormap(handles.frameAxes, 'gray');
    axis(handles.frameAxes,'image','off');
    %axis(handles.frameAxes,[0,size(image,2)+1,0,size(image,1)+1]);
    %hold(handles.frameAxes,'on');
    %plot(handles.frameAxes,nan(1,2),nan(1,2),'r-');
    axes(handles.frameAxes);
else
    obj = VideoReader(movieName);
    video = readFrame(obj);
    imshow(video, 'Border', 'tight');
    axes(handles.frameAxes);
    imshow(video, 'Border', 'tight');
end
[~,folderName,~] = fileparts(currentPath);
set(handles.folder1Txt, 'String', folderName);
set(handles.folder2Txt, 'String', folderName);
set(handles.folder3Txt, 'String', folderName);
set(handles.folder35Txt, 'String', folderName);
set(handles.folder4Txt, 'String', folderName);


function fileType = getFileType(currentPath, handles)
movieName = fullfile(currentPath, handles.movieFileName);
[~, ~, fileType] = fileparts(movieName);
fileType = lower(fileType);


function [frameLength, frameWidth] = getFrameLengthAndWidth(currentPath, handles)
movieName = fullfile(currentPath, handles.movieFileName);
if isequal(getFileType(currentPath, handles), '.ufmf')
    [~, ~, ~, headerinfo] = get_readframe_fcn(movieName);
    frameLength = headerinfo.max_height;
    frameWidth = headerinfo.max_width;
else
    obj = VideoReader(movieName);
    video = readFrame(obj);
    [frameLength, frameWidth, ~] = size(video);
end


function setLocations(handles)
set(handles.down1Panel, 'Visible', 'on');
set(handles.layoutPanel, 'Visible', 'on');
set(handles.displayPanel, 'Visible', 'on');
set(handles.down2Panel, 'Visible', 'off');
set(handles.down2Panel, 'Position', handles.down1Panel.Position);
set(handles.down3Panel, 'Visible', 'off');
set(handles.down3Panel, 'Position', handles.down1Panel.Position);
set(handles.down4Panel, 'Visible', 'off');
set(handles.down4Panel, 'Position', handles.down1Panel.Position);
set(handles.ArenaPanel, 'Visible', 'off');
set(handles.ArenaPanel, 'Position', handles.layoutPanel.Position);
set(handles.markPanel, 'Visible', 'off');
set(handles.markPanel, 'Position', handles.layoutPanel.Position);
set(handles.framePanel, 'Visible', 'off');
set(handles.framePanel, 'Position', handles.layoutPanel.Position);
set(handles.nameArenasPanel, 'Visible', 'off');
set(handles.nameArenasPanel, 'Position', handles.layoutPanel.Position);
set(handles.arenasDisplayPanel, 'Visible', 'off');
set(handles.arenasDisplayPanel, 'Position', handles.displayPanel.Position);
set(handles.down35Panel, 'Visible', 'off');
set(handles.down35Panel, 'Position', handles.down1Panel.Position);



% --- Outputs from this function are returned to the command line.
function varargout = FixTrackingFiles_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if handles.closeFigure
    fig = handles.fixTrackingFig;
    close(fig);
end


% --- Executes on button press in chooseBtn.
function chooseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
files = get(handles.layoutList, 'String');
if isempty(files)
    return;
end
if ~isequal(handles.arenasData, -1)
    delete(handles.arenasData);
end
selected = [handles.arenasdir, files{get(handles.layoutList, 'value')}];
selected = strcat(selected, '.mat');
handles = getLayoutData(handles, selected);
handles.skip = true;
guidata(hObject,handles);


function handles = getLayoutData(handles, selected)
load(selected);
handles.arenasNumber = arenasNumber;
if length(handles.arenasNames) ~= arenasNumber
    handles.arenasNames = strings(arenasNumber, 1);
end
handles.mmPerPixel = mmPerPixel;
i = handles.arenasNumber;
while (i > 0)
    i = i - 1;
    pos = arenasPos{handles.arenasNumber - i};  %#ok<*USENS>
    switch arenaShape
        case 'circularBtn'
            shape = imellipse(gca, pos);
            shape.setFixedAspectRatioMode('1');
        case 'rectangularBtn',  shape = imrect(gca, pos);
        otherwise, shape = impoly(gca, pos);
    end
    setColor(shape, [0.298, 0.702, 0.698]);
    arenas(handles.arenasNumber - i) = shape; %#ok<*AGROW>
end
set(handles.arenasShapePanel,'selectedobject',getfield(handles, arenaShape)); %#ok<*GFLD>
handles.arenasData = arenas;


% --- Executes on button press in discardBtn.
function discardBtn_Callback(hObject, eventdata, handles)
% hObject    handle to discardBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isequal(handles.arenasData, -1)
    delete(handles.arenasData);
end
handles.arenasData = -1;
handles.arenasNumber = -1;
handles.mmPerPixel = -1;
handles.skip = false;
guidata(hObject,handles);


% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
files = get(handles.layoutList, 'String');
if isempty(files)
    return;
end
button = questdlg('Are you sure you want to delete this layout?');
if ~isequal(button, 'Yes')
    return;
end
currentValue = get(handles.layoutList, 'Value');
selected = strcat(handles.arenasdir, files{currentValue}, '.mat');
delete(selected);
fileNames = dir([handles.arenasdir '*.mat']);
fileNames = cellfun(@(x) x(1:end-4),{fileNames.name},'Un',0);
set(handles.layoutList, 'Value', min(currentValue, length(fileNames)));
set(handles.layoutList, 'String', fileNames);
guidata(hObject,handles);


% --- Executes on button press in prev2Btn.
function prev2Btn_Callback(hObject, eventdata, handles)
% hObject    handle to prev2Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.layoutPanel, 'Visible', 'on');
set(handles.ArenaPanel, 'Visible', 'off');
set(handles.down1Panel, 'Visible', 'on');
set(handles.down2Panel, 'Visible', 'off');


% --- Executes on button press in next1Btn.
function next1Btn_Callback(hObject, eventdata, handles)
% hObject    handle to next1Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.skip
    if handles.arenasNumber == 1
        set(handles.framePanel, 'Visible', 'on');
        set(handles.layoutPanel, 'Visible', 'off');
        set(handles.down4Panel, 'Visible', 'on');
        set(handles.down1Panel, 'Visible', 'off');
        uicontrol(handles.fliesNumberText);
    else
        handles.nameArenaIndx = 1;
        handles = initializeArenasNamePanels(handles);
        set(handles.layoutPanel, 'Visible', 'off');
        set(handles.down1Panel, 'Visible', 'off');
    end
else
    set(handles.ArenaPanel, 'Visible', 'on');
    set(handles.layoutPanel, 'Visible', 'off');
    set(handles.down2Panel, 'Visible', 'on');
    set(handles.down1Panel, 'Visible', 'off');
    uicontrol(handles.lineLengthText);
end
guidata(hObject,handles);


function handles = initializeArenasNamePanels(handles)
textLabel = sprintf('Arenas left: %d', handles.arenasNumber - handles.nameArenaIndx + 1);
set(handles.arenasLeftNameTxt, 'String', textLabel);
separeteText = get(handles.separeteTxt, 'String');
separeteText{2} = ['separated into ', num2str(handles.arenasNumber)];
set(handles.separeteTxt, 'String', separeteText);
set(handles.nameArenasPanel, 'Visible', 'on');
set(handles.arenasDisplayPanel, 'Visible', 'on');
set(handles.down35Panel, 'Visible', 'on');
set(handles.displayPanel, 'Visible', 'off');
axes(handles.arenasAxes);
handles = updateArenasNamePanels(handles);



function handles = updateArenasNamePanels(handles)
uicontrol(handles.nameArenaTxt);
textLabel = sprintf('Arenas left: %d', handles.arenasNumber - handles.nameArenaIndx + 1);
set(handles.arenasLeftNameTxt, 'String', textLabel);
set(handles.nameArenaTxt, 'String', handles.arenasNames{handles.nameArenaIndx});
pos = getPosition(handles.arenasData(handles.nameArenaIndx));
switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
    case 'circularBtn', handles.curArena = imellipse(gca, pos);
    case 'rectangularBtn', handles.curArena = imrect(gca, pos);
    otherwise, handles.curArena = impoly(gca, pos);
end
posConstrain = @(p) pos;
setPositionConstraintFcn(handles.curArena, posConstrain);
setColor(handles.curArena, [0.298, 0.702, 0.698]);


% --- Executes on button press in next35Btn.
function next35Btn_Callback(hObject, eventdata, handles)
% hObject    handle to next35Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text = get(handles.nameArenaTxt, 'string');
if contains(text, ' ')
    h = warndlg('Name shouldn''t have spaces');
    waitfor(h);
    uicontrol(handles.nameArenaTxt);
elseif isequal(text, '') || isempty(text)
    h = warndlg('Please enter arena''s name');
    waitfor(h);
    uicontrol(handles.nameArenaTxt);
elseif ismember(text, handles.arenasNames(1:handles.nameArenaIndx - 1))
    h = warndlg('Arenas should have different names');
    waitfor(h);
    uicontrol(handles.nameArenaTxt);
else
    handles.arenasNames{handles.nameArenaIndx} = text;
    delete(handles.curArena);
    if handles.nameArenaIndx > handles.arenasNumber - 1
        handles = exitNameArenasPanel(handles);
    else
        handles.nameArenaIndx = handles.nameArenaIndx + 1;
        handles = updateArenasNamePanels(handles);
    end
end
guidata(hObject,handles);


function handles = exitNameArenasPanel(handles)
set(handles.framePanel, 'Visible', 'on');
set(handles.down4Panel, 'Visible', 'on');
set(handles.displayPanel, 'Visible', 'on');
set(handles.nameArenasPanel, 'Visible', 'off');
set(handles.arenasDisplayPanel, 'Visible', 'off');
set(handles.down35Panel, 'Visible', 'off');
axes(handles.frameAxes);


% --- Executes on button press in prev35Btn.
function prev35Btn_Callback(hObject, eventdata, handles)
% hObject    handle to prev35Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.arenasNames{handles.nameArenaIndx} = get(handles.nameArenaTxt, 'string');
delete(handles.curArena);
if handles.nameArenaIndx < 2
    if handles.skip
        set(handles.layoutPanel, 'Visible', 'on');
        set(handles.down1Panel, 'Visible', 'on');
    else
        set(handles.markPanel, 'Visible', 'on');
        set(handles.down3Panel, 'Visible', 'on');
    end
    set(handles.displayPanel, 'Visible', 'on');
    set(handles.nameArenasPanel, 'Visible', 'off');
    set(handles.arenasDisplayPanel, 'Visible', 'off');
    set(handles.down35Panel, 'Visible', 'off');
    axes(handles.frameAxes);
else
    handles.nameArenaIndx = handles.nameArenaIndx - 1;
    handles = updateArenasNamePanels(handles);
end
guidata(hObject,handles);


% --- Executes on button press in autoNameBtn.
function autoNameBtn_Callback(hObject, eventdata, handles)
% hObject    handle to autoNameBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i = 1:handles.arenasNumber
    handles.arenasNames(i) = num2str(i);
end
delete(handles.curArena);
handles = exitNameArenasPanel(handles);
guidata(hObject,handles);


% --- Executes on button press in rotateBtn.
function rotateBtn_Callback(hObject, eventdata, handles)
% hObject    handle to rotateBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.curView = handles.curView - 90;
view(handles.curView, 90);
guidata(hObject,handles);


% --- Executes on button press in prev3Btn.
function prev3Btn_Callback(hObject, eventdata, handles)
% hObject    handle to prev3Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ArenaPanel, 'Visible', 'on');
set(handles.markPanel, 'Visible', 'off');
set(handles.down2Panel, 'Visible', 'on');
set(handles.down3Panel, 'Visible', 'off');


% --- Executes on button press in lineBtn.
function lineBtn_Callback(hObject, eventdata, handles)
% hObject    handle to lineBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.prev2Btn, 'Enable', 'off');
set(handles.next2Btn, 'Enable', 'off');
set(handles.lineLengthText, 'Enable', 'off');
set(handles.arenasNumberText, 'Enable', 'off');
set(handles.lineBtn, 'Enable', 'off');
line = imline;
setColor(line, [0.298, 0.702, 0.698]);
lineDrawn = wait(line);
set(handles.prev2Btn, 'Enable', 'on');
set(handles.next2Btn, 'Enable', 'on');
set(handles.lineLengthText, 'Enable', 'on');
set(handles.arenasNumberText, 'Enable', 'on');
set(handles.lineBtn, 'Enable', 'on');
uicontrol(handles.lineLengthText);
handles.lineDrawnLength = sqrt(((lineDrawn(1, 1) - lineDrawn(2, 1))^2) + ((lineDrawn(1, 2) - lineDrawn(2, 2))^2));
delete(line);
guidata(hObject,handles);


% --- Executes on enter text in lineLengthText.
function lineLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to lineLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of lineLengthText as text
%        str2double(get(hObject,'String')) returns contents of lineLengthText as a double
text = get(handles.lineLengthText, 'string');
[lineLength, n] = sscanf(text, '%f');
if (n ~= 1) || contains(text, ',') || contains(text, ';') || (lineLength <= 0)
    h = warndlg('Length should be a positive number');
    waitfor(h);
    uicontrol(handles.lineLengthText);
    handles.lineLength = -1;
else
    handles.lineLength = lineLength;
end
guidata(hObject,handles);


% --- Executes on enter text in arenasNumberText.
function arenasNumberText_Callback(hObject, eventdata, handles)
% hObject    handle to arenasNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of arenasNumberText as text
%        str2double(get(hObject,'String')) returns contents of arenasNumberText as a double
text = get(handles.arenasNumberText, 'string');
[arenasNumber, n] = sscanf(text, '%d');
if (n ~= 1) || contains(text, '.') || contains(text, ',') || contains(text, ';') || (arenasNumber < 1)
    h = warndlg('Number of arenas should be a whole positive number');
    waitfor(h);
    uicontrol(handles.arenasNumberText);
    handles.arenasNumber = -1;
else
    handles.arenasNumber = arenasNumber;
    if length(handles.arenasNames) ~= arenasNumber
        handles.arenasNames = strings(arenasNumber, 1);
    end
end
guidata(hObject,handles);


% --- Executes on button press in next2Btn.
function next2Btn_Callback(hObject, eventdata, handles)
% hObject    handle to next2Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateCurrentLineAndArenaTexts(handles);
if handles.lineDrawnLength <= 0
    warndlg('Please draw a line');
elseif isequal(handles.lineLength, -1)
    h = warndlg('Please enter line''s length');
    waitfor(h);
    uicontrol(handles.lineLengthText);
elseif isequal(handles.arenasNumber, -1)
    h = warndlg('Please enter number of arenas');
    waitfor(h);
    uicontrol(handles.arenasNumberText);
else
    handles.mmPerPixel = (handles.lineLength * 10) / handles.lineDrawnLength;
    textLabel = sprintf('Arenas left: %d', handles.arenasNumber);
    set(handles.arenasLeftTxt, 'String', textLabel);
    set(handles.markPanel, 'Visible', 'on');
    set(handles.ArenaPanel, 'Visible', 'off');
    set(handles.down3Panel, 'Visible', 'on');
    set(handles.down2Panel, 'Visible', 'off');
end
guidata(hObject,handles);


function handles = updateCurrentLineAndArenaTexts(handles)
text = get(handles.lineLengthText, 'string');
[lineLength, n] = sscanf(text, '%f');
if (n == 1) && ~contains(text, ',') && ~contains(text, ';') && (lineLength > 0)
    handles.lineLength = lineLength;
end
text = get(handles.arenasNumberText, 'string');
[arenasNumber, n] = sscanf(text, '%d');
if (n == 1) && ~contains(text, '.') && ~contains(text, ',') && ~contains(text, ';') && (arenasNumber >= 1)
    handles.arenasNumber = arenasNumber;
    if length(handles.arenasNames) ~= arenasNumber
        handles.arenasNames = strings(arenasNumber, 1);
    end
end


% --- Executes on button press in arenasBtn.
function arenasBtn_Callback(hObject, eventdata, handles)
% hObject    handle to arenasBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isequal(handles.arenasData, -1)
    button = questdlg('Arena(s) are already marked. Would you like to re-mark them?');
    if isequal(button, 'Yes')
        delete(handles.arenasData);
        handles.arenasData = -1;
    else
        return;
    end
end
set(handles.prev3Btn, 'Enable', 'off');
set(handles.next3Btn, 'Enable', 'off');
set(handles.enterNameText, 'Enable', 'off');
set(handles.arenasBtn, 'Enable', 'off');
i = handles.arenasNumber;
textLabel = sprintf('Arenas left: %d', i);
set(handles.arenasLeftTxt, 'String', textLabel);
while (i > 0)
    switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
        case 'circularBtn'
            shape = imellipse;
            posConstrain = @(pos) [pos(1) pos(2) max(pos(3:4)) max(pos(3:4))];
            setPositionConstraintFcn(shape, posConstrain);
            shape.setFixedAspectRatioMode('1');
        case 'rectangularBtn',  shape = imrect;
        otherwise, shape = impoly;
    end
    setColor(shape, [0.298, 0.702, 0.698]);
    wait(shape);
    i = i - 1;
    textLabel = sprintf('Arenas left: %d', i);
    set(handles.arenasLeftTxt, 'String', textLabel);
    arenas(handles.arenasNumber - i) = shape;
end
set(handles.prev3Btn, 'Enable', 'on');
set(handles.next3Btn, 'Enable', 'on');
set(handles.enterNameText, 'Enable', 'on');
set(handles.arenasBtn, 'Enable', 'on');
handles.arenasData = arenas;
guidata(hObject,handles);


function enterNameText_Callback(hObject, eventdata, handles)
% hObject    handle to enterNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enterNameText as text
%        str2double(get(hObject,'String')) returns contents of enterNameText as a double


% --- Executes on button press in next3Btn.
function next3Btn_Callback(hObject, eventdata, handles)
% hObject    handle to next3Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.arenasData, -1)
    warndlg('Please mark all arenas');
else
    handles = updateNameTexts(handles);
    if ~isequal(handles.layoutName, -1)
        handleLayoutAddition(handles);
    end
    if handles.arenasNumber == 1
        set(handles.framePanel, 'Visible', 'on');
        set(handles.markPanel, 'Visible', 'off');
        set(handles.down4Panel, 'Visible', 'on');
        set(handles.down3Panel, 'Visible', 'off');
    else
        handles.nameArenaIndx = 1;
        handles = initializeArenasNamePanels(handles);
        set(handles.markPanel, 'Visible', 'off');
        set(handles.down3Panel, 'Visible', 'off');
    end
end
guidata(hObject,handles);


function handles = updateNameTexts(handles)
text = get(handles.enterNameText, 'string');
if ~isempty(text)
    handles.layoutName = text;
else
    handles.layoutName = -1;
end


% --- Executes on button press in prev4Btn.
function prev4Btn_Callback(hObject, eventdata, handles)
% hObject    handle to prev4Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.arenasNumber > 1
    handles.nameArenaIndx = handles.arenasNumber;
    handles = initializeArenasNamePanels(handles);
    set(handles.framePanel, 'Visible', 'off');
    set(handles.down4Panel, 'Visible', 'off');
elseif handles.skip
    set(handles.layoutPanel, 'Visible', 'on');
    set(handles.framePanel, 'Visible', 'off');
    set(handles.down1Panel, 'Visible', 'on');
    set(handles.down4Panel, 'Visible', 'off');
else
    set(handles.markPanel, 'Visible', 'on');
    set(handles.framePanel, 'Visible', 'off');
    set(handles.down3Panel, 'Visible', 'on');
    set(handles.down4Panel, 'Visible', 'off');
end
guidata(hObject,handles);


function handleLayoutAddition(handles)
files = get(handles.layoutList, 'String');
name = get(handles.enterNameText, 'string');
fullFile = strcat(handles.arenasdir, name, '.mat');
if ismember(name, files)
    button = questdlg('Layout already exists. Do you want to replace it?');
    if ~isequal(button, 'Yes')
        return;
    end
    delete(fullFile);
end
saveFile(fullFile, handles);
fileNames = dir([handles.arenasdir '*.mat']);
fileNames = cellfun(@(x) x(1:end-4),{fileNames.name},'Un',0);
set(handles.layoutList, 'String', fileNames);


function saveFile(fullFile, handles)
arenasNumber = handles.arenasNumber;
mmPerPixel = handles.mmPerPixel; %#ok<*NASGU>
arenasData = handles.arenasData;
for i = 1:arenasNumber
    arenasPos{i} = getPosition(arenasData(i));
end
arenaShape = get(get(handles.arenasShapePanel,'SelectedObject'),'Tag');
save(fullFile, 'arenasNumber', 'mmPerPixel', 'arenasPos', 'arenaShape');


% --- Executes on enter text in fliesNumberText.
function fliesNumberText_Callback(hObject, eventdata, handles)
% hObject    handle to fliesNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fliesNumberText as text
%        str2double(get(hObject,'String')) returns contents of fliesNumberText as a double
text = get(handles.fliesNumberText, 'string');
[fliesNumber, n] = sscanf(text, '%d');
if (n ~= 1) || contains(text, '.') || contains(text, ',') || contains(text, ';') || (fliesNumber < 1)
    h = warndlg('Number of flies should be a whole positive number');
    waitfor(h);
    uicontrol(handles.fliesNumberText);
    handles.fliesNumber = -1;
else
    handles.fliesNumber = fliesNumber;
    textLabel = sprintf('Flies left: %d', fliesNumber);
    set(handles.fliesLeftText, 'String', textLabel);
end
guidata(hObject,handles);


% --- Executes on button press in markFliesBtn.
function markFliesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to markFliesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateFliesTexts(handles);
if isequal(handles.fliesNumber, -1)
    h = warndlg('Please enter number of flies');
    waitfor(h);
    uicontrol(handles.fliesNumberText);
    return;
end
if ~isequal(handles.fliesData, -1)
    button = questdlg('Flies are already marked. Would you like to re-mark them?');
    if isequal(button, 'Yes')
        delete(handles.fliesData);
        handles.fliesData = -1;
    else
        return;
    end
end
i = handles.fliesNumber;
disableFramePanel(handles);
textLabel = sprintf('Flies left: %d', i);
set(handles.fliesLeftText, 'String', textLabel);
while (i > 0)
    point = impoint;
    setColor(point, [0.298, 0.702, 0.698]);
    i = i - 1;
    flies(handles.fliesNumber - i) = point;
    textLabel = sprintf('Flies left: %d', i);
    set(handles.fliesLeftText, 'String', textLabel);
end
handles.fliesData = flies;
enableFramePanel(handles);
guidata(hObject,handles);


function handles = updateFliesTexts(handles)
text = get(handles.fliesNumberText, 'string');
[fliesNumber, n] = sscanf(text, '%d');
if (n == 1) && ~contains(text, '.') && ~contains(text, ',') && ~contains(text, ';') && (fliesNumber >= 1)
    handles.fliesNumber = fliesNumber;
    textLabel = sprintf('Flies left: %d', fliesNumber);
    set(handles.fliesLeftText, 'String', textLabel);
end


function disableFramePanel(handles)
set(handles.prev4Btn, 'Enable', 'off');
set(handles.done4Btn, 'Enable', 'off');
set(handles.fliesNumberText, 'Enable', 'off');
set(handles.fixFliesBtn, 'Enable', 'off');
set(handles.markFliesBtn, 'Enable', 'off');
set(handles.markSpotBtn, 'Enable', 'off');
set(handles.deleteSpotBtn, 'Enable', 'off');


function enableFramePanel(handles)
set(handles.prev4Btn, 'Enable', 'on');
set(handles.done4Btn, 'Enable', 'on');
set(handles.fliesNumberText, 'Enable', 'on');
set(handles.markFliesBtn, 'Enable', 'on');
set(handles.fixFliesBtn, 'Enable', 'on');
set(handles.markSpotBtn, 'Enable', 'on');
set(handles.deleteSpotBtn, 'Enable', 'on');


% --- Executes on button press in fixFliesBtn.
function fixFliesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to fixFliesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateFliesTexts(handles);
if isequal(handles.fliesNumber, -1)
    h = warndlg('Please enter number of flies');
    waitfor(h);
    uicontrol(handles.fliesNumberText);
    return;
end
if ~isequal(handles.fliesData, -1)
    button = questdlg('Flies are already marked. Would you like to re-mark them?');
    if isequal(button, 'Yes')
        delete(handles.fliesData);
        handles.fliesData = -1;
    else
        return;
    end
end
currentPath = handles.foldersToGetParams{handles.currentFolder};
trackingName = fullfile(currentPath, handles.trackingFileName);
load(trackingName);
if exist('flipped', 'var') ~= 1 && ~isequal(getFileType(currentPath, handles), '.ufmf')
    [frameLength, ~] = getFrameLengthAndWidth(currentPath, handles);
    y_pos = frameLength - y_pos; %#ok<*NODEF>
end
i = handles.fliesNumber;
j = min(ntargets(1), handles.fliesNumber);
disableFramePanel(handles)
textLabel = sprintf('Flies left: %d', i);
set(handles.fliesLeftText, 'String', textLabel);
while (i > 0)
    if j > 0
        point = impoint(gca, [x_pos(j), y_pos(j)]);
        j = j - 1;
    else
        point = impoint;
    end
    setColor(point, [0.298, 0.702, 0.698]);
    i = i - 1;
    flies(handles.fliesNumber - i) = point;
    textLabel = sprintf('Flies left: %d', i);
    set(handles.fliesLeftText, 'String', textLabel);
end
handles.fliesData = flies;
enableFramePanel(handles)
guidata(hObject,handles);


% --- Executes on button press in markSpotBtn.
function markSpotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to markSpotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disableFramePanel(handles);
point = impoint;
setColor(point, [0.67, 0.33, 0.35]);
wait(point);
handles.spotsData = [handles.spotsData, point];
enableFramePanel(handles);
guidata(hObject,handles);


% --- Executes on button press in deleteSpotBtn.
function deleteSpotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSpotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.spotsData)
    delete(handles.spotsData(end));
    handles.spotsData(end) = [];
end
guidata(hObject,handles);


% --- Executes on button press in done4Btn.
function done4Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done4Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.fliesData, -1)
    warndlg('Please mark all flies');
    return;
end
[correct, handles] = saveFliesAndArenasLocations(handles);
if ~correct
    return;
end
saveFixParams(handles);
[handles, done] = initialize(handles);
guidata(hObject,handles);
if done
    handles = fixAllFolders(handles);
    guidata(hObject,handles);
    fig = handles.fixTrackingFig;
    close(fig);
end


function [correct, handles] = saveFliesAndArenasLocations(handles)
flyX = repmat(-1, handles.fliesNumber, 1);
flyY = repmat(-1, handles.fliesNumber, 1);
for i = 1:handles.fliesNumber
    flyPos = getPosition(handles.fliesData(i));
    flyX(i) = flyPos(1);
    flyY(i) = flyPos(2);
end
spotX = repmat(-1, length(handles.spotsData), 1);
spotY = repmat(-1, length(handles.spotsData), 1);
for i = 1:length(handles.spotsData)
    spotPos = getPosition(handles.spotsData(i));
    spotX(i) = spotPos(1);
    spotY(i) = spotPos(2);
end
switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
    case 'circularBtn', handles.type = 'imellipse';
    case 'rectangularBtn', handles.type = 'imrect';
    otherwise, handles.type = 'impoly';
end
for i = 1:handles.arenasNumber
    arenaPos = getPosition(handles.arenasData(i));
    inf = inImroi(flyX, flyY, arenaPos, handles.type);
    if ~any(inf)
        warndlg('All arenas must contain at least one fly.');
        correct = false;
        return;
    end
    ins = inImroi(spotX, spotY, arenaPos, handles.type);
    fliesData{i} = dataset(flyX(inf), flyY(inf), 'VarNames', {'x_pos', 'y_pos'});
    spotsData{i} = dataset(spotX(ins), spotY(ins), 'VarNames', {'x_pos', 'y_pos'});
    arenasData{i} = arenaPos;
    flyX = flyX(~inf);
    flyY = flyY(~inf);
    spotX = spotX(~ins);
    spotY = spotY(~ins);
end
if ~isempty(flyX) || ~isempty(flyY)
    warndlg('Please move all flies'' marks inside an arena''s bounds.');
    correct = false;
else
    correct = true;
    handles.fliesData = fliesData;
    handles.arenasData = arenasData;
    handles.spotsData = spotsData;
end


function saveFixParams(handles)
userFliesData = handles.fliesData;
mmPerPixel = handles.mmPerPixel;
arenasPos = handles.arenasData;
param = handles.params;
arenasNumber = handles.arenasNumber;
arenasType = handles.type;
userSpotsData = handles.spotsData;
arenasNames = handles.arenasNames;
if length(handles.foldersToFix) == 1 && arenasNumber == 1
    showOptions = 'on';
else
    showOptions = 'off';
end
if arenasNumber == 1
    userSpotsData = userSpotsData{1};
    userFliesData = userFliesData{1};
    arenasPos = arenasPos{1};
end
currentPath = handles.foldersToGetParams{handles.currentFolder};
paramsName = fullfile(currentPath, handles.fixedParametersFileName);
fileName = fullfile(currentPath, handles.trackingFileName);
fixedFileName = fullfile(currentPath, handles.fixedFileName);
save(paramsName, 'userFliesData', 'fileName', 'mmPerPixel', 'arenasPos', 'param', 'arenasNumber', 'arenasType', 'userSpotsData', 'showOptions', 'arenasNames', 'fixedFileName');


function handles = fixAllFolders(handles)
handles.waitBar = waitbar(0, 'Flipping Ctrax files...');
flipFiles(handles);
[arenasToFix, arenasToSeparate] = countArenas(handles);
handles.numberOfTasks = 1 + arenasToSeparate + (arenasToFix * 3);
handles.currentTask = 1;
waitbar(handles.currentTask / handles.numberOfTasks, handles.waitBar, 'Separating tracking files...');
handles = separatingTrackingFiles(handles);
waitbar(handles.currentTask / handles.numberOfTasks, handles.waitBar, 'Fixing tracking data...');
handles = fixTrackingFiles(handles);
waitbar(handles.currentTask / handles.numberOfTasks, handles.waitBar, 'Generating trx files...');
handles = generateTrxFiles(handles);
waitbar(handles.currentTask / handles.numberOfTasks, handles.waitBar, 'Creating perframe directories...');
handles = createPerframeDir(handles);
bar = handles.waitBar;
close(bar);


function flipFiles(handles)
for i = 1:length(handles.foldersToFix)
    trackingFile = fullfile(handles.foldersToFix{i}, handles.trackingFileName);
    listOfVariables = who('-file', trackingFile);
    if ~ismember('flipped', listOfVariables)
        angle = {};
        load(trackingFile);
        if ~isequal(getFileType(handles.foldersToFix{i}, handles), '.ufmf')
            [frameLength, ~] = getFrameLengthAndWidth(handles.foldersToFix{i}, handles);
            y_pos = frameLength - y_pos;
            angle = angle .* (-1);
        end
        flipped = 1;
        save(trackingFile, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets', 'flipped');
    end
end


function [arenasToFix, arenasToSeparate] = countArenas(handles)
arenasToFix = 0;
arenasToSeparate = 0;
for i = 1:length(handles.foldersToFix)
    paramFile = fullfile(handles.foldersToFix{i}, handles.fixedParametersFileName);
    load(paramFile, 'arenasNumber');
    if arenasNumber > 1
        arenasToSeparate = arenasToSeparate + arenasNumber;
    end
    arenasToFix = arenasToFix + arenasNumber;
end


function handles = updateWaitBar(handles)
handles.currentTask = handles.currentTask + 1;
waitbar(handles.currentTask / handles.numberOfTasks);


function handles = separatingTrackingFiles(handles)
newFoldersToFix = {};
for i = 1:length(handles.foldersToFix)
    paramFile = fullfile(handles.foldersToFix{i}, handles.fixedParametersFileName);
    load(paramFile, 'arenasNumber');
    if arenasNumber > 1
        [handles, sepFolders] = separateFolder(handles, handles.foldersToFix{i});
        newFoldersToFix = [newFoldersToFix, sepFolders];
    else
        newFoldersToFix = [newFoldersToFix, handles.foldersToFix{i}];
    end
end
handles.foldersToFix = newFoldersToFix;


function [handles, sepFolders] = separateFolder(handles, curFolder)
paramFile = fullfile(curFolder, handles.fixedParametersFileName);
load(paramFile, 'arenasNames');
sepFolders = {};
for i = 1:length(arenasNames)
    sepFolders{i} = [curFolder, '_', arenasNames{i}];
    mkdir(sepFolders{i});
    copyfile(curFolder, sepFolders{i});
    saveSeparatedParams(handles, curFolder, sepFolders{i}, i);
    handles = updateWaitBar(handles);
end
if handles.params.deleteUnifiedFolder
    try
        rmdir(curFolder, 's');
    catch
    end
end


function saveSeparatedParams(handles, curFolder, newFolder, indx)
trackingFile = fullfile(curFolder, handles.trackingFileName);
newTrackingFile = fullfile(newFolder, handles.trackingFileName);
paramsFile = fullfile(curFolder, handles.fixedParametersFileName);
newParamsFile = fullfile(newFolder, handles.fixedParametersFileName);
load(paramsFile);
SeparateTrackingFiles(trackingFile, arenasPos{indx}, arenasType, newTrackingFile)
userFliesData = userFliesData{indx};
arenasPos = arenasPos{indx};
arenasNumber = 1;
userSpotsData = userSpotsData{indx};
arenasNames = {};
fixedFileName = fullfile(newFolder, handles.fixedFileName);
fileName = newTrackingFile;
save(newParamsFile, 'userFliesData', 'fileName', 'mmPerPixel', 'arenasPos', 'param', 'arenasNumber', 'arenasType', 'userSpotsData', 'showOptions', 'arenasNames', 'fixedFileName');


function handles = fixTrackingFiles(handles)
for i = 1:length(handles.foldersToFix)
    paramFile = fullfile(handles.foldersToFix{i}, handles.fixedParametersFileName);
    numberOfFrames = runAllFixAlgorithms(paramFile);
    if handles.params.firstFrame > 0 || handles.params.lastFrame ~= inf
        shortenFixedFile(handles, paramFile);
    end
    handles = updateWaitBar(handles);
end


function shortenFixedFile(handles, paramFile)
firstFrame = handles.params.firstFrame;
lastFrame = handles.params.lastFrame;
load(paramFile, 'fixedFileName');
load(fixedFileName, 'angle', 'identity', 'maj_ax', 'min_ax', 'x_pos', 'y_pos', 'ntargets', 'startframe', 'timestamps');
if lastFrame > length(ntargets)
    endIndex = length(ntargets);
else
    endIndex = lastFrame - startframe + 1;
end
if firstFrame < 1
    startIndex = 1;
else
    startIndex = firstFrame - startframe + 1; 
end
if endIndex > length(ntargets) || startIndex < 1
    return;
end
startframe = firstFrame;
ntargets = ntargets(startIndex:endIndex);
timestamps = timestamps(startIndex:endIndex);
from = (startIndex - 1) * ntargets(1) + 1;
x_pos = x_pos(from:min(endIndex * ntargets(1), length(x_pos)));
y_pos = y_pos(from:min(endIndex * ntargets(1), length(y_pos)));
angle = angle(from:min(endIndex * ntargets(1), length(angle)));
maj_ax = maj_ax(from:min(endIndex * ntargets(1), length(maj_ax)));
min_ax = min_ax(from:min(endIndex * ntargets(1), length(min_ax)));
identity = identity(from:min(endIndex * ntargets(1), length(identity)));
save(fixedFileName, 'angle', 'identity', 'maj_ax', 'min_ax', 'x_pos', 'y_pos', 'ntargets', 'startframe', 'timestamps', '-append')


function handles = generateTrxFiles(handles)
counter = 0;
for i = 1:length(handles.foldersToFix)
    currentPath = handles.foldersToFix{i};
    movieName = fullfile(currentPath, handles.movieFileName);
    fixedFileName = fullfile(currentPath, handles.fixedFileName);
    if handles.params.useOriginalFileForJaaba
        fileToUse = fullfile(currentPath, handles.trackingFileName);
    else
        fileToUse = fullfile(currentPath, handles.fixedFileName);
    end
    annName = fullfile(currentPath, handles.annFileName);
    paramsName = fullfile(currentPath, handles.fixedParametersFileName);
    isSuccess = generateOneTrxFile(handles, fileToUse, annName, fixedFileName, paramsName, movieName, currentPath);
    counter = counter + isSuccess;
    handles = updateWaitBar(handles);
end
if counter ~= 0
    warndlg([num2str(counter) ' trx file(s) could not be generated.']);
end


function handles = createPerframeDir(handles)
counter = 0;
for j = 1:length(handles.foldersToFix)
    currentPath = handles.foldersToFix{j};
    perframedir = fullfile(currentPath, handles.perframeDirName);
    dooverwrite = true;
    isSuccess = createPerframeFiles(handles, currentPath, dooverwrite, perframedir);
    counter = counter + isSuccess;
    handles = updateWaitBar(handles);
end
if counter ~= 0
    warndlg([num2str(counter) ' perframe directory(ies) could not be generated.']);
end






% --- Executes when user attempts to close fixTrackingFig.
function fixTrackingFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fixTrackingFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);











% --- Executes during object creation, after setting all properties.
function markPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function arenasNumberText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arenasNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function fliesNumberText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fliesNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in arenasShapePanel.
function arenasShape_Callback(hObject, eventdata, handles)
% hObject    handle to arenasShapePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns arenasShapePanel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from arenasShapePanel

% --- Executes during object creation, after setting all properties.
function arenasShapePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arenasShapePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function lineLengthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in next4Btn.
function next4Btn_Callback(hObject, eventdata, handles)
% hObject    handle to next4Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in done3Btn.
function done3Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done3Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in done2Btn.
function done2Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done2Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in prev1Btn.
function prev1Btn_Callback(hObject, eventdata, handles)
% hObject    handle to prev1Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in done1Btn.
function done1Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done1Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in layoutList.
function layoutList_Callback(hObject, eventdata, handles)
% hObject    handle to layoutList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns layoutList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from layoutList

% --- Executes during object creation, after setting all properties.
function layoutList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to layoutList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enterAxisText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enterAxisText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enterNameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enterNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in done35Btn.
function done35Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done35Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function nameArenaTxt_Callback(hObject, eventdata, handles)
% hObject    handle to nameArenaTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nameArenaTxt as text
%        str2double(get(hObject,'String')) returns contents of nameArenaTxt as a double

% --- Executes during object creation, after setting all properties.
function nameArenaTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nameArenaTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
