function varargout = configureStageControlGUI(varargin)
% CONFIGURESTAGECONTROLGUI MATLAB code for configureStageControlGUI.fig
%      CONFIGURESTAGECONTROLGUI, by itself, creates a new CONFIGURESTAGECONTROLGUI or raises the existing
%      singleton*.
%
%      H = CONFIGURESTAGECONTROLGUI returns the handle to a new CONFIGURESTAGECONTROLGUI or the handle to
%      the existing singleton*.
%
%      CONFIGURESTAGECONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURESTAGECONTROLGUI.M with the given input arguments.
%
%      CONFIGURESTAGECONTROLGUI('Property','Value',...) creates a new CONFIGURESTAGECONTROLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configureStageControlGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configureStageControlGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureStageControlGUI

% Last Modified by GUIDE v2.5 28-May-2019 13:25:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureStageControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configureStageControlGUI_OutputFcn, ...
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


% --- Executes just before configureStageControlGUI is made visible.
function configureStageControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configureStageControlGUI (see VARARGIN)

% Choose default command line output for configureStageControlGUI
handles.output = hObject;

%get daqParam
daqParam = getappdata(0,'daqParam');

%set edit strings from stage
handles.posEdit.String = num2str(daqParam.Stage.PosPerScan);
handles.pointsEdit.String = num2str(daqParam.Stage.PointsPerPos);
%set value of peak find
handles.contModeCheck.Value = daqParam.Stage.ContMode;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configureStageControlGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configureStageControlGUI_OutputFcn(hObject, eventdata, handles) 
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

%update number of points in scan and whether peak find is on
daqParam.Stage.PosPerScan = str2double(handles.posEdit.String);
daqParam.Stage.PointsPerPos = str2double(handles.pointsEdit.String); 
daqParam.Stage.ContMode = handles.contModeCheck.Value;

%calculate positions to move stage to from number of points
stageMin = 0;
stageMax = 99.7;
daqParam.Stage.ScanPositions = linspace(stageMin,stageMax,str2double(handles.posEdit.String));

%close
close
