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

% Last Modified by GUIDE v2.5 06-Oct-2018 15:35:33

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
function manageConnectionsGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manageConnectionsGUI (see VARARGIN)

%get in checkvalues
daqParam = getappdata(0,'daqParam');

handles.photonCounterCheckbox.Value = ~isempty(daqParam.PhotonCounter);
handles.ADCcheckbox.Value = ~isempty(daqParam.ADC);

handles.valveControlCheckbox.Value = ~isempty(daqParam.FlowSystem.ValveControl);
handles.pumpCheckbox.Value = ~isempty(daqParam.FlowSystem.Pump);
handles.pHmeterCheckbox.Value = ~isempty(daqParam.PHmeter);

handles.stageCheckbox.Value = ~isempty(daqParam.Stage);

%get in handles to master figure to output checkbox values
handles.UserData = varargin{1};

%get list of com ports to populate popmenus
list = instrhwinfo('serial');
ports = cell(1);
ports{1} = 'Serial Port';
for i = 1:length(list.SerialPorts)
    ports{i+1} = char(list.SerialPorts(i));
end

%populate each serial popup menu with com ports
handles.photonCounterPopup.String = ports;
handles.pHmeterPopup.String = ports;
handles.pumpPopup.String = ports;

%**************set default values***************%
%computer specific

%photon counter COM3
if ismember('COM3',ports)
    handles.photonCounterPopup.Value = find(ismember(ports,'COM3'));
end

%pump COM9
if ismember('COM9',ports)
    handles.pumpPopup.Value = find(ismember(ports,'COM9'));
end

%pH meter COM8
if ismember('COM8',ports)
    handles.pHmeterPopup.Value = find(ismember(ports,'COM8'));
end

%******* end default values ******%

% Choose default command line output for manageConnectionsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manageConnectionsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manageConnectionsGUI_OutputFcn(~,~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in photonCounterConnect.
function photonCounterConnect_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)

%get port
COMport = handles.photonCounterPopup.String{handles.photonCounterPopup.Value};

%initialize object
photonCounter = PhotonCounter(COMport);

%put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.PhotonCounter = photonCounter;

%set checkboxes to 1
handles.photonCounterCheckbox.Value = 1;
handles.UserData.photonCounterCheckbox.Value = 1;


% --- Executes on button press in ADCconnect.
function ADCconnect_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
%create object
labJack = LabJackADC();

%put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.ADC = labJack;

%set checkbox to 1
handles.ADCcheckbox.Value = 1;
handles.UserData.ADCcheckbox.Value = 1;


% --- Executes on button press in NIDAQconnect.
function NIDAQconnect_Callback(~,~,handles)
% handles    structure with handles and user data (see GUIDATA)
%create object
daqSession = DAQsession();

%put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.NIDAQ = daqSession;

%set checkbox to 1
handles.NIDAQcheckbox.Value = 1;
handles.UserData.NIDAQcheckbox.Value = 1;


% --- Executes on button press in pHmeterConnect.
function pHmeterConnect_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
%get port
COMport = handles.pHmeterPopup.String{handles.pHmeterPopup.Value};
%initiliaze object
pHmeter = PHmeter(COMport);

%put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.PHmeter = pHmeter;

%set checkbox to 1
handles.pHmeterCheckbox.Value = 1;
handles.UserData.pHmeterCheckbox.Value = 1;


% --- Executes on button press in pumpConnect.
function pumpConnect_Callback(~,~, handles)
% handles structure with handles and user data (see GUIDATA)

%get port
COMport = handles.pumpPopup.String{handles.pumpPopup.Value};

%initialize object
pump = Pump(COMport);

%put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.Pump = pump;

%set checkbox to 1
handles.pumpCheckbox.Value = 1;
handles.UserData.pumpCheckbox.Value = 1;


% --- Executes on button press in stageConnect.
function stageConnect_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
%create object
stage = Stage();

% put object in daqParam
daqParam = getappdata(0,'daqParam');
daqParam.Stage = stage;

%set checkbox to 1
handles.stageCheckbox.Value = 1;
handles.UserData.stageCheckbox.Value = 1;


% --- Executes on button press in closeWindow.
function closeWindow_Callback(~,~,~)
close
