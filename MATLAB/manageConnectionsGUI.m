function varargout = manageConnectionsGUI(varargin)
% manageConnectionsGUI MATLAB code for manageConnectionsGUI.fig
%      manageConnectionsGUI, by itself, creates a new manageConnectionsGUI or raises the existing
%      singleton*.
%
%      H = manageConnectionsGUI returns the handle to a new manageConnectionsGUI or the handle to
%      the existing singleton*.
%
%      manageConnectionsGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in manageConnectionsGUI.M with the given input arguments.
%
%      manageConnectionsGUI('Property','Value',...) creates a new manageConnectionsGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manageConnectionsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manageConnectionsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manageConnectionsGUI

% Last Modified by GUIDE v2.5 30-Aug-2017 15:09:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manageConnectionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @manageConnectionsGUI_OutputFcn, ...
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


% --- Executes just before manageConnectionsGUI is made visible.
function manageConnectionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manageConnectionsGUI (see VARARGIN)

%take in DAQ parameters
handles.UserData = getappdata(0,'DAQparam');

handles.photonCounterCheckbox.Value = handles.UserData.photonCounter;
handles.NIDAQcheckbox.Value = handles.UserData.NIDAQ;
handles.pHmeterCheckbox.Value = handles.UserData.pHmeter;
handles.pumpCheckbox.Value = handles.UserData.pump;

%get list of com ports to populate popmenus
list = instrhwinfo('serial');
ports = cell(1);
ports{1} = 'Serial Port';
for i = 1:length(list.SerialPorts)
    ports{i+1} = char(list.SerialPorts(i));
end

%popuplate each serial popup menu with com ports
handles.photonCounterPopup.String = ports;
handles.pHmeterPopup.String = ports;
handles.pumpPopup.String = ports;

%get list of device names
daqIDs = daq.getDevices();
daqs = cell(1);
daqs{1} = 'Devices';
for i = 1:length(daqIDs)
    daqs{i+1} = daqIDs(1).ID;
end

%populate NIDAQ with device names
handles.NIDAQpopup.String = daqs;



%**************set default values***************%
%computer specific

%photon counter COM1
if ismember('COM1',ports)
    handles.photonCounterPopup.Value = find(ismember(ports,'COM1'));
end

%pump COM7
if ismember('COM7',ports)
    handles.pumpPopup.Value = find(ismember(ports,'COM7'));
end

%pH meter COM3
if ismember('COM3',ports)
    handles.pHmeterPopup.Value = find(ismember(ports,'COM3'));
end

%NIDAQ Dev1
if ismember('Dev1',daqs)
    handles.NIDAQpopup.Value = find(ismember(daqs,'Dev1'));
end
%******* end default values ******%

% Choose default command line output for manageConnectionsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manageConnectionsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manageConnectionsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in photonCounterConnect.
function photonCounterConnect_Callback(hObject, eventdata, handles)
% hObject    handle to photonCounterConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get port
COMport = handles.photonCounterPopup.String{handles.photonCounterPopup.Value};
serialPhotonCounter = serial(COMport);
serialPhotonCounter.BaudRate = 19200;
serialPhotonCounter.StopBits = 2;
serialPhotonCounter.DataBits = 8;
serialPump.Terminator = 'CR';

%open port
fopen(serialPhotonCounter)

%save port
setappdata(0,'serialPhotonCounter',serialPhotonCounter)

%set checkbox to 1
handles.photonCounterCheckbox.Value = 1;

%set photon counter connect status to 1
DAQparam = getappdata(0,'DAQparam');
DAQparam.photonCounter = 1;
setappdata(0,'DAQparam',DAQparam)




% --- Executes on selection change in photonCounterPopup.
function photonCounterPopup_Callback(hObject, eventdata, handles)
% hObject    handle to photonCounterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns photonCounterPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from photonCounterPopup


% --- Executes during object creation, after setting all properties.
function photonCounterPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to photonCounterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NIDAQconnect.
function NIDAQconnect_Callback(hObject, eventdata, handles)
% hObject    handle to NIDAQconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in NIDAQpopup.
function NIDAQpopup_Callback(hObject, eventdata, handles)
% hObject    handle to NIDAQpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NIDAQpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NIDAQpopup


% --- Executes during object creation, after setting all properties.
function NIDAQpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NIDAQpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pHmeterConnect.
function pHmeterConnect_Callback(hObject, eventdata, handles)
% hObject    handle to pHmeterConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get port
COMport = handles.pHmeterPopup.String{handles.pHmeterPopup.Value};
serialpHmeter = serial(COMport);
serialpHmeter.BaudRate = 9600;
serialpHmeter.StopBits = 1;
serialpHmeter.DataBits = 8;
serialPump.Terminator = 'CR';

%open port
fopen(serialpHmeter)

%save port
setappdata(0,'serialpHmeter',serialpHmeter)

%set checkbox to 1
handles.pHmeterCheckbox.Value = 1;

%set photon counter connect status to 1
DAQparam = getappdata(0,'DAQparam');
DAQparam.pHmeter = 1;
setappdata(0,'DAQparam',DAQparam)


% --- Executes on selection change in pHmeterPopup.
function pHmeterPopup_Callback(hObject, eventdata, handles)
% hObject    handle to pHmeterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pHmeterPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pHmeterPopup


% --- Executes during object creation, after setting all properties.
function pHmeterPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pHmeterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pumpConnect.
function pumpConnect_Callback(hObject, eventdata, handles)
% hObject    handle to pumpConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get port
COMport = handles.pumpPopup.String{handles.pumpPopup.Value};
serialPump = serial(COMport);
serialPump.BaudRate = 9600;
serialPump.StopBits = 1;
serialPump.DataBits = 8;
serialPump.Terminator = 'CR';

%open port
fopen(serialPump)

%save port
setappdata(0,'serialPump',serialPump)

%set checkbox to 1
handles.pumpCheckbox.Value = 1;

%set photon counter connect status to 1
DAQparam = getappdata(0,'DAQparam');
DAQparam.pump = 1;
setappdata(0,'DAQparam',DAQparam)


% --- Executes on selection change in pumpPopup.
function pumpPopup_Callback(hObject, eventdata, handles)
% hObject    handle to pumpPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumpPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumpPopup


% --- Executes during object creation, after setting all properties.
function pumpPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumpPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in closeWindow.
function closeWindow_Callback(hObject, eventdata, handles)
close
% hObject    handle to closeWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
