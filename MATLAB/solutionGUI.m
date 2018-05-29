function varargout = solutionGUI(varargin)
% SOLUTIONGUI MATLAB code for solutionGUI.fig
%      SOLUTIONGUI, by itself, creates a new SOLUTIONGUI or raises the existing
%      singleton*.
%
%      H = SOLUTIONGUI returns the handle to a new SOLUTIONGUI or the handle to
%      the existing singleton*.
%
%      SOLUTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOLUTIONGUI.M with the given input arguments.
%
%      SOLUTIONGUI('Property','Value',...) creates a new SOLUTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before solutionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to solutionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help solutionGUI

% Last Modified by GUIDE v2.5 09-Nov-2017 17:29:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @solutionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @solutionGUI_OutputFcn, ...
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


% --- Executes just before solutionGUI is made visible.
function solutionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to solutionGUI (see VARARGIN)

% Choose default command line output for solutionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

pump = getappdata(0,'pump');

%set whether pH or salt has been enabled
if pump.Mode
    %if salt mode
    handles.saltCheck.Value = true;
    handles.pHcheck.Value = false;
else
    %if pH mode
    handles.saltCheck.Value = false;
    handles.pHcheck.Value = true;
end

%populate ID possibilities here
tubeIDs = {'3.17','2.29','0.76','0.64'};
%set string
handles.tubeIDpopup.String = tubeIDs;
%set default
handles.tubeIDpopup.Value = find(ismember(tubeIDs,pump.TubeID));

%set total flow
handles.totalFlowEdit.String = num2str(pump.TotalFlow);
    
%set checkbox/editbox values
for i = 1:4
    %set each of the reservoirs that is enabled
    handles.(strcat('res',num2str(i),'check')).Value = pump.Reservoirs(i);
    
    %if salt is enabled
    if handles.saltCheck.Value
        %set salt values and default pH to 0
        handles.(strcat('salt',num2str(i),'edit')).String = ...
            num2str(pump.Concentrations(i));
        handles.(strcat('pH',num2str(i),'edit')).String = '0';
    else
        %else set pH values and default salt to 0
        handles.(strcat('pH',num2str(i),'edit')).String = ...
            num2str(pump.Concentrations(i));
        handles.(strcat('salt',num2str(i),'edit')).String = '0';
    end
end

% UIWAIT makes solutionGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = solutionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in saltCheck.
function saltCheck_Callback(hObject, eventdata, handles)
% hObject    handle to saltCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ensure pH and salt have opposite values
handles.pHcheck.Value = ~hObject.Value;


% --- Executes on button press in pHcheck.
function pHcheck_Callback(hObject, eventdata, handles)
% hObject    handle to pHcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ensure pH and salt have opposite values
handles.saltCheck.Value = ~hObject.Value;


% --- Executes on button press in updateClose.
function updateClose_Callback(hObject, eventdata, handles)
% hObject    handle to updateClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get pump object
pump = getappdata(0,'pump');

%set mode
pump.Mode = handles.saltCheck.Value;

%set total flow
pump.TotalFlow = str2double(handles.totalFlowEdit.String);


%set tubeID
pump.TubeID = handles.tubeIDpopup.String{handles.tubeIDpopup.Value};
pump.setTubeIDs(pump.TubeID); %set tube ID


%set check marks
for i = 1:4
    pump.Reservoirs(i) = handles.(strcat('res',num2str(i),'check')).Value;
    
    %if salt is enabled
    if handles.saltCheck.Value
        %set pump concentrations to salt values
        pump.Concentrations(i) = ...
            str2double(handles.(strcat('salt',num2str(i),'edit')).String);
    else
        %set pump concentrations to pH values
        pump.Concentrations(i) = ...
            str2double(handles.(strcat('pH',num2str(i),'edit')).String);
    end
end

close;
