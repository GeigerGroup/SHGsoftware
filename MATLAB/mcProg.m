function varargout = mcProg(varargin)
% MCPROG MATLAB code for mcProg.fig
%      MCPROG, by itself, creates a new MCPROG or raises the existing
%      singleton*.
%
%      H = MCPROG returns the handle to a new MCPROG or the handle to
%      the existing singleton*.
%
%      MCPROG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MCPROG.M with the given input arguments.
%
%      MCPROG('Property','Value',...) creates a new MCPROG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mcProg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mcProg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mcProg

% Last Modified by GUIDE v2.5 01-Jun-2017 20:12:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mcProg_OpeningFcn, ...
                   'gui_OutputFcn',  @mcProg_OutputFcn, ...
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


% --- Executes just before mcProg is made visible.
function mcProg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mcProg (see VARARGIN)

%get list of com ports to populate popmenus
list = instrhwinfo('serial');
ports = cell(1);
ports{1} = 'Serial Port';
for i = 1:length(list.SerialPorts)
    ports{i+1} = char(list.SerialPorts(i));
end

%popuplate each popup menu with com ports
set(handles.popupSpPc,'String',ports);
set(handles.popupSpDAQ,'String',ports);
set(handles.popupSppH,'String',ports);
set(handles.popupSpPump,'String',ports);


% Choose default command line output for mcProg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mcProg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mcProg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectPC.
function connectPC_Callback(hObject, eventdata, handles)
% hObject    handle to connectPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupSpPc.
function popupSpPc_Callback(hObject, eventdata, handles)
% hObject    handle to popupSpPc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSpPc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSpPc


% --- Executes during object creation, after setting all properties.
function popupSpPc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSpPc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in connectDAQ.
function connectDAQ_Callback(hObject, eventdata, handles)
% hObject    handle to connectDAQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupSpDAQ.
function popupSpDAQ_Callback(hObject, eventdata, handles)
% hObject    handle to popupSpDAQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSpDAQ contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSpDAQ


% --- Executes during object creation, after setting all properties.
function popupSpDAQ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSpDAQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectpH.
function connectpH_Callback(hObject, eventdata, handles)
% hObject    handle to connectpH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupSppH.
function popupSppH_Callback(hObject, eventdata, handles)
% hObject    handle to popupSppH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSppH contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSppH


% --- Executes during object creation, after setting all properties.
function popupSppH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSppH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectPump.
function connectPump_Callback(hObject, eventdata, handles)
% hObject    handle to connectPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupSpPump.
function popupSpPump_Callback(hObject, eventdata, handles)
% hObject    handle to popupSpPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSpPump contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSpPump


% --- Executes during object creation, after setting all properties.
function popupSpPump_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSpPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkPC.
function checkPC_Callback(hObject, eventdata, handles)
% hObject    handle to checkPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPC


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in connectAll.
function connectAll_Callback(hObject, eventdata, handles)
% hObject    handle to connectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in configureMeasurement.
function configureMeasurement_Callback(hObject, eventdata, handles)
% hObject    handle to configureMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in configureControl.
function configureControl_Callback(hObject, eventdata, handles)
% hObject    handle to configureControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startExp.
function startExp_Callback(hObject, eventdata, handles)
% hObject    handle to startExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in abortExperiment.
function abortExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to abortExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pauseExp.
function pauseExp_Callback(hObject, eventdata, handles)
% hObject    handle to pauseExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
