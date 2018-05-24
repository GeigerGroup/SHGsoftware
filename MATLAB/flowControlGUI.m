function varargout = flowControlGUI(varargin)
% FLOWCONTROLGUI MATLAB code for flowControlGUI.fig
%      FLOWCONTROLGUI, by itself, creates a new FLOWCONTROLGUI or raises the existing
%      singleton*.
%
%      H = FLOWCONTROLGUI returns the handle to a new FLOWCONTROLGUI or the handle to
%      the existing singleton*.
%
%      FLOWCONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLOWCONTROLGUI.M with the given input arguments.
%
%      FLOWCONTROLGUI('Property','Value',...) creates a new FLOWCONTROLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flowControlGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flowControlGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flowControlGUI

% Last Modified by GUIDE v2.5 24-May-2018 12:42:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flowControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @flowControlGUI_OutputFcn, ...
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


% --- Executes just before flowControlGUI is made visible.
function flowControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flowControlGUI (see VARARGIN)

% Choose default command line output for flowControlGUI
handles.output = hObject;

%get daqParam
daqParam = getappdata(0,'daqParam');

for i = 1:4
    str = strcat('checkbox',num2str(i)); %valve number
    handles.(str).Value = daqParam.SolStates(i); %set value from solstates
end
    
%rearrange items in hObject.Children so checkboxes are 1-4
uistack(hObject.Children(9),'up',9)
uistack(hObject.Children(10),'up',10)
uistack(hObject.Children(11),'up',11)
uistack(hObject.Children(12),'up',12)


% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = flowControlGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton.
function pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get daqParam
daqParam = getappdata(0,'daqParam');

%get pump
pump = getappdata(0,'pump');

%if pump flow rate is set greater than 0
if daqParam.PumpStates(str2num(hObject.String)) > 0
    
    %change SolStates in daqParam
    daqParam.SolStates(str2num(hObject.String)) = ...
        ~daqParam.SolStates(str2num(hObject.String));
    
    %send to SolenoidValve to change
    daqSession = getappdata(0,'daqSession');
    daqSession.setValveStates(daqParam.SolStates);
    
    handles.output.Children(str2num(hObject.String)).Value = ...
        ~handles.output.Children(str2num(hObject.String)).Value;
    
   
    if daqParam.SolStates(str2num(hObject.String))
         %if you just turned it on
        pump.startFlow(str2num(hObject.String));
    else
         %if you just turned it off
        pump.stopFlow(str2num(hObject.String));
    end
end


% --- Executes on button press in startAllButton.
function startAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to startAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pump = getappdata(0,'pump');
pump.startFlowOpenValves();

% --- Executes on button press in stopAllButton.
function stopAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pump = getappdata(0,'pump');
pump.stopFlowCloseValves();


% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%delete handle to figure
setappdata(0,'flowGUI',[]);

%close window
close

