function varargout = controlSolenoidsGUI(varargin)
% CONTROLSOLENOIDSGUI MATLAB code for controlSolenoidsGUI.fig
%      CONTROLSOLENOIDSGUI, by itself, creates a new CONTROLSOLENOIDSGUI or raises the existing
%      singleton*.
%
%      H = CONTROLSOLENOIDSGUI returns the handle to a new CONTROLSOLENOIDSGUI or the handle to
%      the existing singleton*.
%
%      CONTROLSOLENOIDSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLSOLENOIDSGUI.M with the given input arguments.
%
%      CONTROLSOLENOIDSGUI('Property','Value',...) creates a new CONTROLSOLENOIDSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controlSolenoidsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controlSolenoidsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controlSolenoidsGUI

% Last Modified by GUIDE v2.5 08-Oct-2017 11:47:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @controlSolenoidsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @controlSolenoidsGUI_OutputFcn, ...
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


% --- Executes just before controlSolenoidsGUI is made visible.
function controlSolenoidsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to controlSolenoidsGUI (see VARARGIN)

% Choose default command line output for controlSolenoidsGUI
handles.output = hObject;

%get daqParam
daqParam = getappdata(0,'daqParam');

for i = 1:5
    str = strcat('checkbox',num2str(i)); %valve number
    handles.(str).Value = daqParam.SolStates(i); %set value from solstates
end
    
%rearrange items in hObject.Children so checkboxes are 1-5
uistack(hObject.Children(8),'up',8)
uistack(hObject.Children(9),'up',9)
uistack(hObject.Children(10),'up',10)
uistack(hObject.Children(11),'up',11)
uistack(hObject.Children(12),'up',12)


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes controlSolenoidsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = controlSolenoidsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get daqParam
daqParam = getappdata(0,'daqParam');

%change SolStates in daqParam
daqParam.SolStates(str2num(hObject.String)) = ...
    ~daqParam.SolStates(str2num(hObject.String));

%send to SolenoidValve to change
daqSession = getappdata(0,'daqSession');
daqSession.setValveStates(daqParam.SolStates);


% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%delete handle to figure
setappdata(0,'solGUI',[]);

%close window
close