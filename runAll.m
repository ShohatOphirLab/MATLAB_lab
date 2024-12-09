function varargout = runAll(varargin)
% RUNALL MATLAB code for runAll.fig
%      RUNALL, by itself, creates a new RUNALL or raises the existing
%      singleton*.

%
%      H = RUNALL returns the handle to a new RUNALL or the handle to
%      the existing singleton*.
%
%      RUNALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNALL.M with the given input arguments.
%
%      RUNALL('Property','Value',...) creates a new RUNALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runAll_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runAll_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runAll

% Last Modified by GUIDE v2.5 08-Apr-2024 12:03:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runAll_OpeningFcn, ...
                   'gui_OutputFcn',  @runAll_OutputFcn, ...
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


% --- Executes just before runAll is made visible.
function runAll_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runAll (see VARARGIN)

% Choose default command line output for runAll
handles.output = hObject;

axes(handles.imageAxes);
imshow('images\flybook open image.jpg', 'Border', 'tight');
axis image;
axes(handles.logoAxes);
imshow('images\logo.jpg', 'Border', 'tight');
axis image;
h = findobj(handles.logoAxes,'type','image');
set(h,'visible','off')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runAll wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runAll_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in fbdcBtn.
function fbdcBtn_Callback(hObject, eventdata, handles)
% hObject    handle to fbdcBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FlyBowlDataCapture;

% --- Executes on button press in tadbBtn.
function tadbBtn_Callback(hObject, eventdata, handles)
% hObject    handle to tadbBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FixTrackingFiles;


% --- Executes on button press in jaabaBtn.
function jaabaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to jaabaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jaabaFile = fullfile(fileparts(which('JLabel')),'.JLabelrc.mat');
namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
if exist(namesFile, 'file') == 2 && exist(jaabaFile, 'file') == 2
    load(namesFile);
    moviefilename = movieFileName;
    trxfilename = jaabaFileName;
    save(jaabaFile, 'moviefilename', 'trxfilename', '-append')
else
    h = warndlg('No files'' names found. default names used.');
    waitfor(h);
end
StartJAABA;


% --- Executes on button press in jaabaPlotBtn.
function jaabaPlotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to jaabaPlotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
JAABAPlot;


% --- Executes on button press in toolsBtn.
function toolsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to toolsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunAllTools;


% --- Executes on button press in ctraxBtn.
function ctraxBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ctraxBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runCtrax;




% --- Executes on button press in namesBtn.
function namesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to namesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startBtn.
function startBtn_Callback(hObject, eventdata, handles)
% hObject    handle to startBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.startBtn, 'Visible', 'off')
h = findobj(handles.imageAxes,'type','image');
set(h,'visible','off')
set(handles.text2, 'Visible', 'on')
set(handles.fbdcBtn, 'Visible', 'on')
set(handles.ctraxBtn, 'Visible', 'on')
set(handles.NetworkBtn, 'Visible', 'on')
set(handles.tadbBtn, 'Visible', 'on')
set(handles.jaabaBtn, 'Visible', 'on')
set(handles.jaabaPlotBtn, 'Visible', 'on')
set(handles.toolsBtn, 'Visible', 'on')
set(handles.text3, 'Visible', 'on')
set(handles.ScatterBtn ,'Visible', 'on')
set(handles.Dynamic ,'Visible', 'on')
set(handles.Heatmap ,'Visible', 'on')

h = findobj(handles.logoAxes,'type','image');
set(h,'visible','on')


% --- Executes on button press in NetworkBtn.
function NetworkBtn_Callback(hObject, eventdata, handles)
% hObject    handle to NetworkBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runAllExperimentInteractions;




% --- Executes on button press in ScatterBtn.
function ScatterBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ScatterBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Gui_for_Scatter;


% --- Executes on button press in Dynamic.
function Dynamic_Callback(hObject, eventdata, handles)
% hObject    handle to Dynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd dynamic_net\
main_dynamic_data;
cd ..\

% --- Executes on button press in Heatmap.
function Heatmap_Callback(hObject, eventdata, handles)
% hObject    handle to Heatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_for_hcluster;
cd ..\