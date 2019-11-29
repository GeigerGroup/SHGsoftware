function varargout = configureScanGUI(varargin)
% CONFIGURESCANGUI MATLAB code for configureScanGUI.fig
%      CONFIGURESCANGUI, by itself, creates a new CONFIGURESCANGUI or raises the existing
%      singleton*.
%
%      H = CONFIGURESCANGUI returns the handle to a new CONFIGURESCANGUI or the handle to
%      the existing singleton*.
%
%      CONFIGURESCANGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURESCANGUI.M with the given input arguments.
%
%      CONFIGURESCANGUI('Property','Value',...) creates a new CONFIGURESCANGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configureScanGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configureScanGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureScanGUI

% Last Modified by GUIDE v2.5 29-Nov-2019 10:43:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureScanGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configureScanGUI_OutputFcn, ...
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


% --- Executes just before configureScanGUI is made visible.
function configureScanGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configureScanGUI (see VARARGIN)

% Choose default command line output for configureScanGUI
handles.output = hObject;

%get daqParam
daqParam = getappdata(0,'daqParam');

%set edit strings from stage
handles.posEdit.String = num2str(daqParam.PosPerScan);
handles.pointsEdit.String = num2str(daqParam.PointsPerPos);
%set value of peak find
handles.contModeCheck.Value = daqParam.ContMode;
%set value of speed
handles.speedEdit.String = num2str(daqParam.ScanSpeed);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configureScanGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configureScanGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in updateClosePush.
function updateClosePush_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)

%get daqParam
daqParam = getappdata(0,'daqParam');

%update number of points in scan
daqParam.PosPerScan = str2double(handles.posEdit.String);
daqParam.PointsPerPos = str2double(handles.pointsEdit.String); 

%update cont mode and speed
daqParam.ContMode = handles.contModeCheck.Value;
daqParam.ScanSpeed = str2double(handles.speedEdit.String);
daqParam.Stage.setSpeed(daqParam.ScanSpeed)

%calculate positions to move stage to from number of points
stageMin = 0;
stageMax = 99.7;
daqParam.ScanPositions = linspace(stageMin,stageMax,str2double(handles.posEdit.String));

%close
close
