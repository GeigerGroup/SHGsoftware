function varargout = controlPumpGUI(varargin)
% CONTROLPUMPGUI MATLAB code for controlPumpGUI.fig
%      CONTROLPUMPGUI, by itself, creates a new CONTROLPUMPGUI or raises the existing
%      singleton*.
%
%      H = CONTROLPUMPGUI returns the handle to a new CONTROLPUMPGUI or the handle to
%      the existing singleton*.
%
%      CONTROLPUMPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLPUMPGUI.M with the given input arguments.
%
%      CONTROLPUMPGUI('Property','Value',...) creates a new CONTROLPUMPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controlPumpGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controlPumpGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controlPumpGUI

% Last Modified by GUIDE v2.5 08-Oct-2017 13:08:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @controlPumpGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @controlPumpGUI_OutputFcn, ...
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


% --- Executes just before controlPumpGUI is made visible.
function controlPumpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to controlPumpGUI (see VARARGIN)

% Choose default command line output for controlPumpGUI
handles.output = hObject;

%set pump as user data
handles.UserData = getappdata(0,'pump');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes controlPumpGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = controlPumpGUI_OutputFcn(hObject, eventdata, handles) 
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

%rate from entered value
rate = str2double(hObject.String);

%channel from which box edited
channel = str2double(hObject.Tag(end));

%set flow rate
handles.UserData.setFlowRate(channel,rate);

% --- Executes during object creation, after setting all properties.
function flowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flowEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get channel pressed
channel = str2double(hObject.Tag(end));

%start flow
handles.UserData.startFlow(channel);


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get channel pressed
channel = str2double(hObject.Tag(end));

%start flow
handles.UserData.stopFlow(channel);

% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
