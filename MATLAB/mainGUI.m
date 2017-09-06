function varargout = mainGUI(varargin)
% mainGUI MATLAB code for mainGUI.fig
%      mainGUI, by itself, creates a new mainGUI or raises the existing
%      singleton*.
%
%      H = mainGUI returns the handle to a new mainGUI or the handle to
%      the existing singleton*.
%
%      mainGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mainGUI.M with the given input arguments.
%
%      mainGUI('Property','Value',...) creates a new mainGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGUI

% Last Modified by GUIDE v2.5 30-Aug-2017 14:46:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGUI_OutputFcn, ...
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


% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)


% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGUI (see VARARGIN)

%take in DAQ parameters
handles.UserData = getappdata(0,'DAQparam');


handles.photonCounterCheckbox.Value = handles.UserData.photonCounter;
handles.NIDAQcheckbox.Value = handles.UserData.NIDAQ;
handles.pHmeterCheckbox.Value = handles.UserData.pHmeter;
handles.pumpCheckbox.Value = handles.UserData.pump;

% Choose default command line output for mainGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in photonCounterCheckbox.
function photonCounterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to photonCounterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of photonCounterCheckbox


% --- Executes on button press in NIDAQcheckbox.
function NIDAQcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to NIDAQcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NIDAQcheckbox


% --- Executes on button press in pHmeterCheckbox.
function pHmeterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to pHmeterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pHmeterCheckbox


% --- Executes on button press in pumpCheckbox.
function pumpCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to pumpCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pumpCheckbox


% --- Executes on button press in manageConnections.
function manageConnections_Callback(hObject, eventdata, handles)
manageConnectionsGUI
% hObject    handle to manageConnections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in configureMeasurement.
function configureMeasurement_Callback(hObject, eventdata, handles)
configureAcqGUI
% hObject    handle to configureMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in configureControl.
function configureControl_Callback(hObject, eventdata, handles)
% hObject    handle to configureControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startExperiment.
function startExperiment_Callback(hObject, eventdata, handles)
startAcquisition
% hObject    handle to startExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stopExperiment.
function stopExperiment_Callback(hObject, eventdata, handles)
stopAcquisition
% hObject    handle to stopExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pauseExperiment.
function pauseExperiment_Callback(hObject, eventdata, handles)
pauseAcquisition

% hObject    handle to pauseExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resumeExperiment.
function resumeExperiment_Callback(hObject, eventdata, handles)
t = getappdata(0,'timer');
start(t);
% hObject    handle to resumeExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
