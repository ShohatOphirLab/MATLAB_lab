function varargout = ChooseFliesNames(varargin)
% CHOOSEFLIESNAMES MATLAB code for ChooseFliesNames.fig
%      CHOOSEFLIESNAMES, by itself, creates a new CHOOSEFLIESNAMES or raises the existing
%      singleton*.
%
%      H = CHOOSEFLIESNAMES returns the handle to a new CHOOSEFLIESNAMES or the handle to
%      the existing singleton*.
%
%      CHOOSEFLIESNAMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEFLIESNAMES.M with the given input arguments.
%
%      CHOOSEFLIESNAMES('Property','Value',...) creates a new CHOOSEFLIESNAMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseFliesNames_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseFliesNames_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseFliesNames

% Last Modified by GUIDE v2.5 26-Sep-2018 11:39:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseFliesNames_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseFliesNames_OutputFcn, ...
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


% --- Executes just before ChooseFliesNames is made visible.
function ChooseFliesNames_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseFliesNames (see VARARGIN)

% Choose default command line output for ChooseFliesNames
handles.output = hObject;
namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
if exist(namesFile, 'file') == 2
    load(namesFile);
    set(handles.FixedEdit, 'String', fixedFileName);
    set(handles.paramsEdit, 'String', fixedParametersFileName);
    set(handles.trackingEdit, 'String', trackingFileName);
    set(handles.movieEdit, 'String', movieFileName);
    set(handles.jaabaEdit, 'String', jaabaFileName);
    set(handles.perframeEdit, 'String', perframeDirName);
    set(handles.annEdit, 'String', annFileName);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChooseFliesNames wait for user response (see UIRESUME)
% uiwait(handles.chooseNamesFig);


% --- Outputs from this function are returned to the command line.
function varargout = ChooseFliesNames_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close chooseNamesFig.
function chooseNamesFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to chooseNamesFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function movieEdit_Callback(hObject, eventdata, handles)
% hObject    handle to movieEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of movieEdit as text
%        str2double(get(hObject,'String')) returns contents of movieEdit as a double


% --- Executes during object creation, after setting all properties.
function movieEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movieEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
movieFileName = get(handles.movieEdit, 'String');
if isempty(movieFileName)
    h = warndlg('Please enter movie file''s name.');
    return;
end
annFileName = get(handles.annEdit, 'String');
if isempty(annFileName)
    h = warndlg('Please enter .ann file''s name.');
    return;
end
trackingFileName = get(handles.trackingEdit, 'String');
if isempty(trackingFileName)
    h = warndlg('Please enter tracking file''s name.');
    return;
end
fixedFileName = get(handles.FixedEdit, 'String');
if isempty(fixedFileName)
    h = warndlg('Please enter fixed file''s name.');
    return;
end
fixedParametersFileName = get(handles.paramsEdit, 'String');
if isempty(fixedParametersFileName)
    h = warndlg('Please enter parameters file''s name.');
    return;
end
jaabaFileName = get(handles.jaabaEdit, 'String');
if isempty(jaabaFileName)
    h = warndlg('Please enter JAABA file''s name.');
    return;
end
perframeDirName = get(handles.perframeEdit, 'String');
if isempty(perframeDirName)
    h = warndlg('Please enter perframe directory''s name.');
    return;
end
namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
save(namesFile, 'movieFileName', 'annFileName', 'trackingFileName', 'fixedFileName', 'fixedParametersFileName', 'jaabaFileName', 'perframeDirName')
fig = handles.chooseNamesFig;
close(fig);



function annEdit_Callback(hObject, eventdata, handles)
% hObject    handle to annEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of annEdit as text
%        str2double(get(hObject,'String')) returns contents of annEdit as a double


% --- Executes during object creation, after setting all properties.
function annEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trackingEdit_Callback(hObject, eventdata, handles)
% hObject    handle to trackingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trackingEdit as text
%        str2double(get(hObject,'String')) returns contents of trackingEdit as a double


% --- Executes during object creation, after setting all properties.
function trackingEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trackingEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FixedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FixedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FixedEdit as text
%        str2double(get(hObject,'String')) returns contents of FixedEdit as a double


% --- Executes during object creation, after setting all properties.
function FixedEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FixedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function paramsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to paramsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of paramsEdit as text
%        str2double(get(hObject,'String')) returns contents of paramsEdit as a double


% --- Executes during object creation, after setting all properties.
function paramsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to paramsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jaabaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to jaabaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jaabaEdit as text
%        str2double(get(hObject,'String')) returns contents of jaabaEdit as a double


% --- Executes during object creation, after setting all properties.
function jaabaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jaabaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function perframeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to perframeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of perframeEdit as text
%        str2double(get(hObject,'String')) returns contents of perframeEdit as a double


% --- Executes during object creation, after setting all properties.
function perframeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to perframeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
