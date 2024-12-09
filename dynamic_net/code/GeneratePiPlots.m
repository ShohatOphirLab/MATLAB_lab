function varargout = GeneratePiPlots(varargin)
% GENERATEPIPLOTS MATLAB code for GeneratePiPlots.fig
%      GENERATEPIPLOTS, by itself, creates a new GENERATEPIPLOTS or raises the existing
%      singleton*.
%
%      H = GENERATEPIPLOTS returns the handle to a new GENERATEPIPLOTS or the handle to
%      the existing singleton*.
%
%      GENERATEPIPLOTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENERATEPIPLOTS.M with the given input arguments.
%
%      GENERATEPIPLOTS('Property','Value',...) creates a new GENERATEPIPLOTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GeneratePiPlots_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GeneratePiPlots_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GeneratePiPlots

% Last Modified by GUIDE v2.5 26-Mar-2019 13:23:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GeneratePiPlots_OpeningFcn, ...
                   'gui_OutputFcn',  @GeneratePiPlots_OutputFcn, ...
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


% --- Executes just before GeneratePiPlots is made visible.
function GeneratePiPlots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GeneratePiPlots (see VARARGIN)

% Choose default command line output for GeneratePiPlots
handles.output = hObject;

handles.allFolders = {};
handles.genotypesNames = {};
handles.curFolders = {};
handles.colors = {};

namesFile = fullfile(fileparts(which('runAll')),'filesNames.mat');
if exist(namesFile, 'file') == 2
    load(namesFile);
    handles.fixedFileName = fixedFileName;
else
    h = warndlg('No files'' names found. default names used.');
    waitfor(h);
    handles.fixedFileName = 'movie_fixed.mat';
end

choice = questdlg('Which side is the ligth in the experiment?', 'Choose Side', 'Left', 'Right', 'Left');
switch choice
    case 'Left'
        lightIsOnLeft = true;
    case 'Right'
        lightIsOnLeft = false;
    otherwise
        warndlg('Default side for light (left) is used.');
        lightIsOnLeft = true;
end
handles.lightIsOnLeft = lightIsOnLeft;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GeneratePiPlots wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GeneratePiPlots_OutputFcn(hObject, eventdata, handles) 
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
handles.curFolders = uipickfiles('Prompt', 'Select Genotype Folders');
if isequal(handles.curFolders, 0) || isempty(handles.curFolders)
    return;
end

guidata(hObject, handles);


% --- Executes on button press in addBtn.
function addBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.curFolders, 0) || isempty(handles.curFolders)
    warndlg('Please select genotype folders');
elseif isequal(get(handles.genotypeTxt, 'string'), '') || isempty(get(handles.genotypeTxt, 'string'))
    warndlg('Please enter genotype name');
else
    handles.allFolders = [handles.allFolders, {handles.curFolders}];
    handles.genotypesNames = [handles.genotypesNames, get(handles.genotypeTxt, 'string')];
    color = getRgbValues(handles);
    handles.colors = [handles.colors, color];
    set(handles.genotypeTxt, 'string', '');
    set(handles.rTxt, 'string', '');
    set(handles.gTxt, 'string', '');
    set(handles.bTxt, 'string', '');
    handles.curFolders = {};
end
guidata(hObject, handles);

function [color] = getRgbValues(handles)
text = get(handles.rTxt, 'string');
[rValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (rValue < 0) || (rValue > 255)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
text = get(handles.gTxt, 'string');
[gValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (gValue < 0) || (gValue > 255)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
text = get(handles.bTxt, 'string');
[bValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (bValue < 0) || (bValue > 1)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
color = [rValue, gValue, bValue];


% --- Executes on button press in doneBtn.
function doneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to doneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile('', 'Save output files');
if ~isequal(file, 0)
    k = strfind(file, '.');
    outputName = fullfile(path, file(1:k(end)-1));
else
    return;
end
try
    load(fullfile(handles.allFolders{1,1}{1}, handles.fixedFileName), 'timestamps');
    handles.framePerSec = 1 / (timestamps(2) - timestamps(1));
catch
    answer = inputdlg('Enter number of frames per second:','Frames per second', [1 40], {'30'});
    if isempty(answer)
        handles.framePerSec = 30;
    else
        handles.framePerSec = str2num(answer{1});
    end
end
figure('Name','Unified Average PI','NumberTitle','off');
hold on;
xMin = zeros(1, length(handles.allFolders));
handles.noFixedFile = 0;
for i = 1:length(handles.allFolders)
    [genotypeData, handles] = getGenotypeData(handles.allFolders{i}, handles);
    [nrows, ~] = cellfun(@size, genotypeData);
    genotypeData = cellfun(@(x) x(1:min(nrows), :), genotypeData, 'un', 0);    
    all = cell2mat(genotypeData).';
    average = mean(all, 1);
    xMin(i) = length(average) / (handles.framePerSec * 60);
    err = std(all)/sqrt(size(all, 1) - 1);
    minutes = (1:length(average)) / (handles.framePerSec * 60);
    if isequal(handles.colors{i}, -1)
        h = shadedErrorBar(minutes, average, err, '-', 1);
    else
        h = shadedErrorBar(minutes, average, err, {'Color', handles.colors{i}}, 1);
    end
    h.mainLine.DisplayName = handles.genotypesNames{i};
end
xlabel('Time (minutes)');
ylabel('Positional Preference');
line(get(gca,'XLim'), [0 0],'Color', 'k');axis tight;
xlim ([0 min(xMin)]);
ylim ([-1 1]);
[~, hObj] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'), 'Location' ,'southoutside');
legend('boxoff');
hL = findobj(hObj, 'type', 'line');
set(hL, 'linewidth' ,6);
set(gcf,'Position',[70 200 1100 400]);
set(gcf,'PaperOrientation','landscape');
set(gca, 'YTick', -1:1);
set(gca, 'XTick', 1:round(minutes(end)));
set(gca,'TickDir','out');
a = gca;
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[]);
axes(a);
linkaxes([a b]);
if get(handles.pdfBox, 'Value') == 1
    print(gcf, outputName, '-dpdf', '-bestfit', '-r300');
end
if get(handles.epsBox, 'Value') == 1
    print(gcf, outputName, '-painters', '-depsc');
end
if get(handles.pngBox, 'Value') == 1
    orient(gcf, 'portrait');
    print(gcf, outputName, '-dpng', '-r300');
end
if handles.noFixedFile > 0
    h = msgbox([num2str(handles.noFixedFile) ' folder(s) don’t have fixed tracking file. Ignored.']);
    uiwait(h);
end


function [genotypeData, handles] = getGenotypeData(folders, handles)
genotypeData = cell(1, length(folders));
for i = 1:length(folders)
    try
        load(fullfile(folders{i}, handles.fixedFileName), 'ntargets', 'middleX', 'x_pos');
    catch 
        handles.noFixedFile = handles.noFixedFile + 1;
        continue;
    end
    x_pos(x_pos <= middleX) = 1;
    x_pos(x_pos > middleX) = -1;
    if ~handles.lightIsOnLeft
        x_pos = x_pos * -1;
    end
    genotypeData{i} = reshape(x_pos, ntargets(1), length(x_pos) / ntargets(1)).';
end
genotypeData = genotypeData(~cellfun('isempty',genotypeData));


% --- Executes on button press in restartBtn.
function restartBtn_Callback(hObject, eventdata, handles)
% hObject    handle to restartBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf)
GeneratePiPlots


function genotypeTxt_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of genotypeTxt as text
%        str2double(get(hObject,'String')) returns contents of genotypeTxt as a double


% --- Executes during object creation, after setting all properties.
function genotypeTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotypeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rTxt_Callback(hObject, eventdata, handles)
% hObject    handle to rTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rTxt as text
%        str2double(get(hObject,'String')) returns contents of rTxt as a double


% --- Executes during object creation, after setting all properties.
function rTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gTxt_Callback(hObject, eventdata, handles)
% hObject    handle to gTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gTxt as text
%        str2double(get(hObject,'String')) returns contents of gTxt as a double


% --- Executes during object creation, after setting all properties.
function gTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bTxt_Callback(hObject, eventdata, handles)
% hObject    handle to bTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bTxt as text
%        str2double(get(hObject,'String')) returns contents of bTxt as a double


% --- Executes during object creation, after setting all properties.
function bTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pdfBox.
function pdfBox_Callback(hObject, eventdata, handles)
% hObject    handle to pdfBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pdfBox


% --- Executes on button press in epsBox.
function epsBox_Callback(hObject, eventdata, handles)
% hObject    handle to epsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of epsBox


% --- Executes on button press in pngBox.
function pngBox_Callback(hObject, eventdata, handles)
% hObject    handle to pngBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pngBox
