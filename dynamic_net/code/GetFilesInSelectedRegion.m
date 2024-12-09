function varargout = GetFilesInSelectedRegion(varargin)
% GETFILESINSELECTEDREGION MATLAB code for GetFilesInSelectedRegion.fig
%      GETFILESINSELECTEDREGION, by itself, creates a new GETFILESINSELECTEDREGION or raises the existing
%      singleton*.
%
%      H = GETFILESINSELECTEDREGION returns the handle to a new GETFILESINSELECTEDREGION or the handle to
%      the existing singleton*.
%
%      GETFILESINSELECTEDREGION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETFILESINSELECTEDREGION.M with the given input arguments.
%
%      GETFILESINSELECTEDREGION('Property','Value',...) creates a new GETFILESINSELECTEDREGION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetFilesInSelectedRegion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetFilesInSelectedRegion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetFilesInSelectedRegion

% Last Modified by GUIDE v2.5 13-Mar-2018 16:27:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetFilesInSelectedRegion_OpeningFcn, ...
                   'gui_OutputFcn',  @GetFilesInSelectedRegion_OutputFcn, ...
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


% --- Executes just before GetFilesInSelectedRegion is made visible.
function GetFilesInSelectedRegion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetFilesInSelectedRegion (see VARARGIN)

% Choose default command line output for GetFilesInSelectedRegion

handles.lastPath = -1;
handles.output = hObject;
handles.movieFileName = -1;
handles.trackingFileName = -1;
handles.folderName = -1;
handles.exShape = -1;
handles.inShape = -1;

namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
if exist(namesFile, 'file') == 2
    load(namesFile);
    handles.fixedName = fixedFileName;
    handles.trackingName = trackingFileName;
    handles.movieName = movieFileName;
else
    h = warndlg('No files'' names found. default names used.');
    waitfor(h);
    handles.fixedName = 'movie_fixed.mat';
    handles.trackingName = 'movie.mat';
    handles.movieName = 'movie.avi';
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetFilesInSelectedRegion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GetFilesInSelectedRegion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in folderBtn.
function folderBtn_Callback(hObject, eventdata, handles)
% hObject    handle to folderBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isequal(handles.lastPath, -1)
    [handles.lastPath,~,~] = fileparts(handles.lastPath);
    pathName = uigetdir(handles.lastPath, 'Select folder to analyze');
else
    pathName = uigetdir('Select folder to analyze');
end
if isequal(pathName, 0)
    return;
end
handles.lastPath = pathName;
handles.folderName = pathName;
handles.movieFileName = fullfile(pathName, handles.movieName);
if ~exist(handles.movieFileName,'file')
    warndlg(['Folder should have a ''', handles.movieName, ''' file.']);
    return;
end
set(handles.frameAxes, 'Visible', 'on');
axes(handles.frameAxes);
obj = VideoReader(handles.movieFileName);
video = readFrame(obj);
[frameLength, frameWidth, ~] = size(video);
handles.frameLength = frameLength;
handles.frameWidth = frameWidth;
imshow(video, 'Border', 'tight');
guidata(hObject,handles);


% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.folderName, -1)
    warndlg('No folder was selected.');
    return;
end
switch get(get(handles.selectFilePanel,'SelectedObject'),'Tag')
    case 'fixedBtn'
        handles.trackingFileName = fullfile(handles.folderName, handles.fixedName);
        checkFlip = false;
    otherwise
        handles.trackingFileName = fullfile(handles.folderName, handles.trackingName);
        checkFlip = true;
end
if ~exist(handles.trackingFileName,'file')
    warndlg('Folder should have a tracking file.');
    return;
end
inArenaPos = getPosition(handles.inShape);
exArenaPos = getPosition(handles.exShape);
angle = {};
load(handles.trackingFileName);
if exist('flipped', 'var') ~= 1 && checkFlip
    y_pos = handles.frameLength - y_pos; %#ok<*NODEF>
    angle = angle .* (-1);
    flipped = 1;
end
indexs = inImroi(x_pos, y_pos, inArenaPos, handles.inType) & ~inImroi(x_pos, y_pos, exArenaPos, handles.exType);
ntargets = updateFliesNumber(ntargets, indexs);
x_pos = x_pos(indexs);
y_pos = y_pos(indexs);
angle = angle(indexs);
maj_ax = maj_ax(indexs);
min_ax = min_ax(indexs);
identity = identity(indexs);
if handles.overrideBox.Value
   save(handles.trackingFileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'ntargets', '-append');
   if checkFlip
       save(handles.trackingFileName, 'flipped', '-append');
   end
else
    fileName = strcat(handles.trackingFileName(1:end - 4), '_selected.mat');
    save(fileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets', 'flipped');
end
%showtrx({handles.movieFileName}, {fileName});


function ntargets = updateFliesNumber(ntargets, indexs)
k = 1;
for i = 1:length(ntargets)
    if ntargets(i) == 0
        continue
    end
    cur = ntargets(i);
    for j = 1:ntargets(i)
        if indexs(k) == 0
            cur = cur - 1;
        end
        k = k + 1;
    end
    ntargets(i) = cur;
end




% --- Executes on button press in includeBtn.
function includeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to includeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.folderName, -1)
    warndlg('No folder was selected.');
    return;
end
if ~isequal(handles.inShape, -1)
    delete(handles.inShape);
    handles.inShape = -1;
end
switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
    case 'circularBtn'
        shape = imellipse;
        posConstrain = @(pos) [pos(1) pos(2) max(pos(3:4)) max(pos(3:4))];
        setPositionConstraintFcn(shape, posConstrain);
        shape.setFixedAspectRatioMode('1');
        handles.inType = 'imellipse';
    case 'rectangularBtn'
        shape = imrect;
        handles.inType = 'imrect';
    otherwise
        shape = impoly;
        handles.inType = 'impoly';
end
setColor(shape, [0.298, 0.702, 0.698]);
handles.inShape = shape;
guidata(hObject, handles);


% --- Executes on button press in excludeBtn.
function excludeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to excludeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.folderName, -1)
    warndlg('No folder was selected.');
    return;
end
if ~isequal(handles.exShape, -1)
    delete(handles.exShape);
    handles.exShape = -1;
end
switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
    case 'circularBtn'
        shape = imellipse;
        posConstrain = @(pos) [pos(1) pos(2) max(pos(3:4)) max(pos(3:4))];
        setPositionConstraintFcn(shape, posConstrain);
        shape.setFixedAspectRatioMode('1');
        handles.exType = 'imellipse';
    case 'rectangularBtn'
        shape = imrect;
        handles.exType = 'imrect';
    otherwise
        shape = impoly;
        handles.exType = 'impoly';
end
setColor(shape, [0.67, 0.33, 0.35]);
handles.exShape = shape;
guidata(hObject, handles);


% --- Executes on button press in overrideBox.
function overrideBox_Callback(hObject, eventdata, handles)
% hObject    handle to overrideBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of overrideBox
