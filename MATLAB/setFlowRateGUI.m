function varargout = setFlowRateGUI(varargin)
% SETFLOWRATEGUI MATLAB code for setFlowRateGUI.fig
%      SETFLOWRATEGUI, by itself, creates a new SETFLOWRATEGUI or raises the existing
%      singleton*.
%
%      H = SETFLOWRATEGUI returns the handle to a new SETFLOWRATEGUI or the handle to
%      the existing singleton*.
%
%      SETFLOWRATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETFLOWRATEGUI.M with the given input arguments.
%
%      SETFLOWRATEGUI('Property','Value',...) creates a new SETFLOWRATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setFlowRateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setFlowRateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setFlowRateGUI

% Last Modified by GUIDE v2.5 24-May-2018 12:13:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setFlowRateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @setFlowRateGUI_OutputFcn, ...
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


% --- Executes just before setFlowRateGUI is made visible.
function setFlowRateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setFlowRateGUI (see VARARGIN)

% Choose default command line output for setFlowRateGUI
handles.output = hObject;

%get daqParam
daqParam = getappdata(0,'daqParam');

%set edit strings from PumpStates from daqParam
for i = 1:4
    str = strcat('flowEdit',num2str(i));
    handles.(str).String = num2str(daqParam.PumpStates(i));
end

%rearrange items in hObject.Children so edits are 1-4
uistack(hObject.Children(8),'up',8)
uistack(hObject.Children(9),'up',9)
uistack(hObject.Children(10),'up',10)
uistack(hObject.Children(11),'up',11)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setFlowRateGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setFlowRateGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function flowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to flowEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flowEdit1 as text
%        str2double(get(hObject,'String')) returns contents of flowEdit1 as a double

%get pump
pump = getappdata(0,'pump');

%rate from entered value
rate = str2double(hObject.String);

%channel from which box edited
channel = str2double(hObject.Tag(end));

%get daqParam
daqParam = getappdata(0,'daqParam');

%set flow rate in daqParam
daqParam.PumpStates(channel) = rate;

%set flow rate
pump.setFlowRate(channel,rate);


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get pump
pump = getappdata(0,'pump');

%get daqParam
daqParam = getappdata(0,'daqParam');
pump.setFlowRates(daqParam.PumpStates);

%start flow
pump.startFlows;


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get pump
pump = getappdata(0,'pump');

%stop flow
pump.stopFlows;

% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%remove reference to pumpGUI
setappdata(0,'pumpGUI',[]);

%close window
close
