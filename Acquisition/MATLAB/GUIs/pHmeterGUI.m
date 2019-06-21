function varargout = pHmeterGUI(varargin)
% PHMETERGUI MATLAB code for pHmeterGUI.fig
%      PHMETERGUI, by itself, creates a new PHMETERGUI or raises the existing
%      singleton*.
%
%      H = PHMETERGUI returns the handle to a new PHMETERGUI or the handle to
%      the existing singleton*.
%
%      PHMETERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHMETERGUI.M with the given input arguments.
%
%      PHMETERGUI('Property','Value',...) creates a new PHMETERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pHmeterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pHmeterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pHmeterGUI

% Last Modified by GUIDE v2.5 25-May-2018 11:28:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pHmeterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @pHmeterGUI_OutputFcn, ...
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


% --- Executes just before pHmeterGUI is made visible.
function pHmeterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pHmeterGUI (see VARARGIN)

% Choose default command line output for pHmeterGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pHmeterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pHmeterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in getReadingButton.
function getReadingButton_Callback(hObject, eventdata, handles)
% hObject    handle to getReadingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
daqParam = getappdata(0,'daqParam');
pHmeter = daqParam.PHmeter;
[pH, cond] = pHmeter.getData();
handles.pHtext.String = num2str(pH);
handles.condText.String = num2str(cond);

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%remove handle to gui
setappdata(0,'pHGUI',[])
close
