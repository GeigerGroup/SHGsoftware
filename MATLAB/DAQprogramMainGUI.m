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

% Last Modified by GUIDE v2.5 07-Oct-2018 18:41:25

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
function DAQprogramMainGUI_OpeningFcn(hObject,~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DAQprogramMainGUI (see VARARGIN)

%take in DAQ parameters
daqParam = DAQparam();
setappdata(0,'daqParam',daqParam);

handles.photonCounterCheckbox.Value = daqParam.PhotonCounter;
handles.NIDAQcheckbox.Value = daqParam.NIDAQ;
handles.ADCcheckbox.Value = daqParam.ADC;
handles.pHmeterCheckbox.Value = daqParam.PHmeter;
handles.pumpCheckbox.Value = daqParam.Pump;
handles.stageCheckbox.Value = daqParam.Stage;

handles.targetConcEdit.String = num2str(daqParam.TargetConc);

% Choose default command line output for DAQprogramMainGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DAQprogramMainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DAQprogramMainGUI_OutputFcn(~,~,handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in manageConnections.
function manageConnections_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
manageConnectionsGUI(handles);

% --- Executes on button press in photonCounterPush.
function photonCounterPush_Callback(~,~,~)
configurePhotonCounterGUI;

% --- Executes on button press in pHmeterGUIbutton.
function pHmeterGUIbutton_Callback(~,~,~)
pHGUI = pHmeterGUI;
setappdata(0,'pHGUI',pHGUI);

% --- Executes on button press in flowControl.
function flowControl_Callback(~,~,~)
flowGUI = flowControlGUI;
setappdata(0,'flowGUI',flowGUI);

% --- Executes on button press in setFlowRate.
function setFlowRate_Callback(~,~,~)
flowRateGUI = setFlowRateGUI;
setappdata(0,'flowRateGUI',flowRateGUI);

% --- Executes on button press in solutionGUI.
function solutionGUI_Callback(~,~,~)
solutionGUI;

function targetConcEdit_Callback(hObject,~,~)
% hObject    handle to targetConcEdit (see GCBO)
%set TargetConc from edit
daqParam = getappdata(0,'daqParam');
daqParam.TargetConc = str2double(hObject.String);

% --- Executes on button press in flowTargetConcButton.
function flowTargetConcButton_Callback(~,~,~)
%calculate rates
pump = getappdata(0,'pump');
daqParam = getappdata(0,'daqParam');
rates = pump.calculateRates(daqParam.TargetConc);

%set rates
pump.setFlowRates(rates);

%start flow
pump.startFlowOpenValves();

% --- Executes on button press in stopFlowButton.
function stopFlowButton_Callback(~,~,~)
pump = getappdata(0,'pump');
pump.stopFlowCloseValves();

% --- Executes on button press in configureMeasurement.
function configureMeasurement_Callback(~,~,~)
configureAcqGUI;

% --- Executes on button press in configureFlowControl.
function configureFlowControl_Callback(~,~,~)
configureFlowControlGUI;

% --- Executes on button press in configureStageControl.
function configureStageControl_Callback(~,~,~)
configureStageControlGUI;

function acqNameEdit_Callback(hObject,~,~)
% hObject    handle to acqNameEdit (see GCBO)
%get daqParam, set the name
daqParam = getappdata(0,'daqParam');
daqParam.Name = hObject.String;

% --- Executes on button press in startExperiment.
function startExperiment_Callback(~,~,~)
% handles    structure with handles and user data (see GUIDATA)
%get daqParam for name
daqParam = getappdata(0,'daqParam');
%initialize acquisition with name from edit box
acquisition = Acquisition(daqParam.Name);
setappdata(0,daqParam.Name,acquisition);
acquisition.startAcquisition;

% --- Executes on button press in pauseExperiment.
function pauseExperiment_Callback(~,~,~)
%get daqParam for name
daqParam = getappdata(0,'daqParam');
acquisition = getappdata(0,daqParam.Name);
acquisition.pauseAcquisition;

% --- Executes on button press in resumeExperiment.
function resumeExperiment_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
%get daqParam for name
daqParam = getappdata(0,'daqParam');
acquisition = getappdata(0,daqParam.Name);
acquisition.resumeAcquisition;

% --- Executes on button press in stopExperiment.
function stopExperiment_Callback(~,~,~)
%get daqParam for name
daqParam = getappdata(0,'daqParam');
acquisition = getappdata(0,daqParam.Name);
acquisition.stopAcquisition;

% --- Executes on button press in closeProgram.
function closeProgram_Callback(~,~,~)
daqParam = getappdata(0,'daqParam');

%delete NIDAQ session
if daqParam.NIDAQ
    daqSession = getappdata(0,'daqSession');
    release(daqSession.Session)
    delete(daqSession.Session)
    daqreset
end

%release stage
if daqParam.Stage
    stage = getappdata(0,'stage');
    stage.close()
end

%delete serial instruments
delete(instrfind)

%close window
close
