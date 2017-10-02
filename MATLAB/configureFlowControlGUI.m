function varargout = configureFlowControlGUI(varargin)
%CONFIGUREFLOWCONTROLGUI M-file for configureFlowControlGUI.fig
%      CONFIGUREFLOWCONTROLGUI, by itself, creates a new CONFIGUREFLOWCONTROLGUI or raises the existing
%      singleton*.
%
%      H = CONFIGUREFLOWCONTROLGUI returns the handle to a new CONFIGUREFLOWCONTROLGUI or the handle to
%      the existing singleton*.
%
%      CONFIGUREFLOWCONTROLGUI('Property','Value',...) creates a new CONFIGUREFLOWCONTROLGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to configureFlowControlGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONFIGUREFLOWCONTROLGUI('CALLBACK') and CONFIGUREFLOWCONTROLGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONFIGUREFLOWCONTROLGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureFlowControlGUI

% Last Modified by GUIDE v2.5 02-Oct-2017 11:53:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configureFlowControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configureFlowControlGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before configureFlowControlGUI is made visible.
function configureFlowControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for configureFlowControlGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configureFlowControlGUI wait for user response (see UIRESUME)
% uiwait(handles.configureFlowControl);


% --- Outputs from this function are returned to the command line.
function varargout = configureFlowControlGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function configureFlowControl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configureFlowControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function flowControlTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flowControlTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
daqParam = getappdata(0,'daqParam');

hObject.Data{1} = daqParam.FlowConcentrationPoint;
hObject.Data{2} = daqParam.FlowConcentrationValue;


