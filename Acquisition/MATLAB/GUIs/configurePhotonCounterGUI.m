function varargout = configurePhotonCounterGUI(varargin)
% CONFIGUREPHOTONCOUNTERGUI MATLAB code for configurePhotonCounterGUI.fig
%      CONFIGUREPHOTONCOUNTERGUI, by itself, creates a new CONFIGUREPHOTONCOUNTERGUI or raises the existing
%      singleton*.
%
%      H = CONFIGUREPHOTONCOUNTERGUI returns the handle to a new CONFIGUREPHOTONCOUNTERGUI or the handle to
%      the existing singleton*.
%
%      CONFIGUREPHOTONCOUNTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGUREPHOTONCOUNTERGUI.M with the given input arguments.
%
%      CONFIGUREPHOTONCOUNTERGUI('Property','Value',...) creates a new CONFIGUREPHOTONCOUNTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configurePhotonCounterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configurePhotonCounterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configurePhotonCounterGUI

% Last Modified by GUIDE v2.5 09-May-2019 12:09:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configurePhotonCounterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configurePhotonCounterGUI_OutputFcn, ...
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


% --- Executes just before configurePhotonCounterGUI is made visible.
function configurePhotonCounterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configurePhotonCounterGUI (see VARARGIN)

% Choose default command line output for configurePhotonCounterGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configurePhotonCounterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configurePhotonCounterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on selection change in channelPopup.
function channelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to channelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelPopup
daqParam = getappdata(0,'daqParam');
daqParam.Channel = hObject.String{hObject.Value};


% --- Executes during object creation, after setting all properties.
function channelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%can be A, B, or AB
hObject.String = {'A','B','AB'};

%find setting and set default
daqParam = getappdata(0,'daqParam');
hObject.Value = find(ismember(hObject.String,daqParam.Channel));


function intervalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%change setting in photon counter, that also updates daqParam
photonCounter = getappdata(0,'photonCounter');
photonCounter.setInterval(str2double(hObject.String));


% --- Executes during object creation, after setting all properties.
function intervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set value from daqParam
daqParam = getappdata(0,'daqParam');
hObject.String = num2str(daqParam.Interval);



function dwellTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dwellTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%change setting in photon counter, that also edits daqParam
photonCounter = getappdata(0,'photonCounter');
photonCounter.setDwellTime(str2double(hObject.String));

% --- Executes during object creation, after setting all properties.
function dwellTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwellTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set value from daqParam
daqParam = getappdata(0,'daqParam');
hObject.String = num2str(daqParam.DwellTime);


% --- Executes on button press in setPharosButton.
function setPharosButton_Callback(hObject, eventdata, handles)
% hObject    handle to setPharosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
daqParam = getappdata(0,'daqParam');
pc = daqParam.PhotonCounter;
pc.setPharosSettings();

% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
