function varargout = DAQprogramMainGUI(varargin)
% DAQprogramMainGUI MATLAB code for DAQprogramMainGUI.fig
%      DAQprogramMainGUI, by itself, creates a new DAQprogramMainGUI or raises the existing
%      singleton*.
%
%      H = DAQprogramMainGUI returns the handle to a new DAQprogramMainGUI or the handle to
%      the existing singleton*.
%
%      DAQprogramMainGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAQprogramMainGUI.M with the given input arguments.
%
%      DAQprogramMainGUI('Property','Value',...) creates a new DAQprogramMainGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DAQprogramMainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DAQprogramMainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DAQprogramMainGUI

% Last Modified by GUIDE v2.5 08-Oct-2017 12:51:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DAQprogramMainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DAQprogramMainGUI_OutputFcn, ...
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


% --- Executes just before DAQprogramMainGUI is made visible.
function DAQprogramMainGUI_OpeningFcn(hObject, eventdata, handles, varargin)


% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DAQprogramMainGUI (see VARARGIN)

%take in DAQ parameters
daqParam = DAQparam();
setappdata(0,'daqParam',daqParam);

handles.photonCounterCheckbox.Value = daqParam.PhotonCounter;
handles.NIDAQcheckbox.Value = daqParam.NIDAQ;
handles.pHmeterCheckbox.Value = daqParam.PHmeter;
handles.pumpCheckbox.Value = daqParam.Pump;

% Choose default command line output for DAQprogramMainGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DAQprogramMainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DAQprogramMainGUI_OutputFcn(hObject, eventdata, handles) 
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
% hObject    handle to manageConnections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manageConnectionsGUI(handles)


% --- Executes on button press in configureMeasurement.
function configureMeasurement_Callback(hObject, eventdata, handles)
% hObject    handle to configureMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
configureAcqGUI


% --- Executes on button press in configureControl.
function configureControl_Callback(hObject, eventdata, handles)
% hObject    handle to configureControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
configureFlowControlGUI

% --- Executes on button press in startExperiment.
function startExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to startExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%initialize acquisition with name from edit box
acquisition = Acquisition(handles.acqNameEdit.String);
setappdata(0,handles.acqNameEdit.String,acquisition);

acquisition.startAcquisition;

% --- Executes on button press in stopExperiment.
function stopExperiment_Callback(hObject, eventdata, handles)
acquisition = getappdata(0,'acquisition');
acquisition.stopAcquisition;
% hObject    handle to stopExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pauseExperiment.
function pauseExperiment_Callback(hObject, eventdata, handles)
acquisition = getappdata(0,'acquisition');
acquisition.pauseAcquisition;

% hObject    handle to pauseExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resumeExperiment.
function resumeExperiment_Callback(hObject, eventdata, handles)
acquisition = getappdata(0,'acquisition');
acquisition.resumeAcquisition
% hObject    handle to resumeExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in closeProgram.
function closeProgram_Callback(hObject, eventdata, handles)
% hObject    handle to closeProgram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

daqParam = getappdata(0,'daqParam');

%delete NIDAQ session
if daqParam.NIDAQ
    daqSession = getappdata(0,'daqSession');
    release(daqSession.Session)
    delete(daqSession.Session)
    daqreset
end

%delete serial instruments
delete(instrfind)

%close window
close


function acqNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to acqNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acqNameEdit as text
%        str2double(get(hObject,'String')) returns contents of acqNameEdit as a double


% --- Executes during object creation, after setting all properties.
function acqNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acqNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in controlSolenoids.
function controlSolenoids_Callback(hObject, eventdata, handles)
% hObject    handle to controlSolenoids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
controlSolenoidsGUI

% --- Executes on button press in controlPump.
function controlPump_Callback(hObject, eventdata, handles)
% hObject    handle to controlPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
