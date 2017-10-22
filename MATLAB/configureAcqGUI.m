function varargout = configureAcqGUI(varargin)
% CONFIGUREACQGUI MATLAB code for configureAcqGUI.fig
%      CONFIGUREACQGUI, by itself, creates a new CONFIGUREACQGUI or raises the existing
%      singleton*.
%
%      H = CONFIGUREACQGUI returns the handle to a new CONFIGUREACQGUI or the handle to
%      the existing singleton*.
%
%      CONFIGUREACQGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGUREACQGUI.M with the given input arguments.
%
%      CONFIGUREACQGUI('Property','Value',...) creates a new CONFIGUREACQGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configureAcqGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configureAcqGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureAcqGUI

% Last Modified by GUIDE v2.5 22-Oct-2017 11:46:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureAcqGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configureAcqGUI_OutputFcn, ...
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


% --- Executes just before configureAcqGUI is made visible.
function configureAcqGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configureAcqGUI (see VARARGIN)

%take in current DAQ parameters
daqParam = getappdata(0,'daqParam');

%set initial ScanLength
handles.scanLengthEdit.Value = daqParam.ScanLength;
handles.scanLengthEdit.String = num2str(handles.scanLengthEdit.Value);

%set initial Interval
handles.intervalEdit.Value = daqParam.Interval;
handles.intervalEdit.String = num2str(handles.intervalEdit.Value);

%set initial DwellTime
handles.dwellTimeEdit.Value = daqParam.DwellTime;
handles.dwellTimeEdit.String = num2str(handles.dwellTimeEdit.Value);

%set whether flow control is on or off
handles.flowControlCheck.Value = daqParam.FlowControl;


% Choose default command line output for configureAcqGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configureAcqGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configureAcqGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function scanLengthEdit_Callback(hObject, eventdata, handles)
hObject.Value = str2num(hObject.String);


% hObject    handle to scanLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of scanLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of scanLengthEdit as a double


% --- Executes during object creation, after setting all properties.
function scanLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intervalEdit_Callback(hObject, eventdata, handles)
hObject.Value = str2num(hObject.String);


% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intervalEdit as text
%        str2double(get(hObject,'String')) returns contents of intervalEdit as a double


% --- Executes during object creation, after setting all properties.
function intervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dwellTimeEdit_Callback(hObject, eventdata, handles)
hObject.Value = str2num(hObject.String);
% hObject    handle to dwellTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dwellTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of dwellTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function dwellTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwellTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateValues.
function updateValues_Callback(hObject, eventdata, handles)

%take in current DAQ parameters
daqParam = getappdata(0,'daqParam');

daqParam.ScanLength = handles.scanLengthEdit.Value;
daqParam.Interval = handles.intervalEdit.Value;
daqParam.DwellTime = handles.dwellTimeEdit.Value;
daqParam.FlowControl = handles.flowControlCheck.Value;


close

% hObject    handle to updateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flowControlCheck.
function flowControlCheck_Callback(hObject, eventdata, handles)
% hObject    handle to flowControlCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flowControlCheck


% --- Executes on button press in pHmeterCheck.
function pHmeterCheck_Callback(hObject, eventdata, handles)
% hObject    handle to pHmeterCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pHmeterCheck
