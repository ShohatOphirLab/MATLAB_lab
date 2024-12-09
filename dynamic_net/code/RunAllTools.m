function varargout = RunAllTools(varargin)
% RUNALLTOOLS MATLAB code for RunAllTools.fig
%      RUNALLTOOLS, by itself, creates a new RUNALLTOOLS or raises the existing
%      singleton*.
%
%      H = RUNALLTOOLS returns the handle to a new RUNALLTOOLS or the handle to
%      the existing singleton*.
%
%      RUNALLTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNALLTOOLS.M with the given input arguments.
%
%      RUNALLTOOLS('Property','Value',...) creates a new RUNALLTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RunAllTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RunAllTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RunAllTools

% Last Modified by GUIDE v2.5 07-Mar-2018 16:45:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RunAllTools_OpeningFcn, ...
    'gui_OutputFcn',  @RunAllTools_OutputFcn, ...
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


% --- Executes just before RunAllTools is made visible.
function RunAllTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RunAllTools (see VARARGIN)

% Choose default command line output for RunAllTools
handles.output = hObject;

handles.toolsNames = {'Plot Trajectories and Histograms', 'Show Tracking', 'Get Flies In Selected Region', 'Choose Files'' Names', 'Generate PI Plots'};%, 'Display All Changes Graphs', 'Plot Customized Outputs', 'Change Fix Parameters'};
set(handles.toolsList, 'String', handles.toolsNames);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RunAllTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RunAllTools_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in toolsList.
function toolsList_Callback(hObject, eventdata, handles)
% hObject    handle to toolsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns toolsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from toolsList


% --- Executes during object creation, after setting all properties.
function toolsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toolsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool = get(handles.toolsList, 'Value');
switch tool
    case 1, simple_diagnostics;
    case 2, showtrx;
    case 3, GetFilesInSelectedRegion;
    case 4, ChooseFliesNames;
    case 5, GeneratePiPlots;
    %case 6, ;
end
