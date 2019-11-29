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

% Last Modified by GUIDE v2.5 07-Oct-2018 16:20:22

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
handles.scanLengthEdit.String = num2str(daqParam.ScanLength);

%set whether to communicate with the photon counter
handles.photonCounterCheck.Value = daqParam.PhotonCounterEnabled;

%set whether ADC power monitoring is on or off
handles.adcPowerCheck.Value = daqParam.PowerADCEnabled;

%set whether flow control is on or off
handles.flowControlCheck.Value = daqParam.FlowControl;

%set whether pH meter monitoring is on or off
handles.pHmeterCheck.Value = daqParam.PHmeterEnabled;

%set autopause value
handles.autoPauseEdit.String = num2str(daqParam.AutoPause);

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


% --- Executes on button press in updateValues.
function updateValues_Callback(hObject, eventdata, handles)
% hObject    handle to updateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%take in current DAQ parameters
daqParam = getappdata(0,'daqParam');

%convert to numbers and set scan length
daqParam.ScanLength = str2double(handles.scanLengthEdit.String);

%set boolean parameters
daqParam.PhotonCounterEnabled = handles.photonCounterCheck.Value;
daqParam.PowerADCEnabled = handles.adcPowerCheck.Value;
daqParam.FlowControl = handles.flowControlCheck.Value;
daqParam.PHmeterEnabled = handles.pHmeterCheck.Value;

%convert to number and set autopause
daqParam.AutoPause = str2double(handles.autoPauseEdit.String);

%close update values and close window
close
