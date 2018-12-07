function varargout = configurePumpAndSolutionsGUI(varargin)
% CONFIGUREPUMPANDSOLUTIONSGUI MATLAB code for configurePumpAndSolutionsGUI.fig
%      CONFIGUREPUMPANDSOLUTIONSGUI, by itself, creates a new CONFIGUREPUMPANDSOLUTIONSGUI or raises the existing
%      singleton*.
%
%      H = CONFIGUREPUMPANDSOLUTIONSGUI returns the handle to a new CONFIGUREPUMPANDSOLUTIONSGUI or the handle to
%      the existing singleton*.
%
%      CONFIGUREPUMPANDSOLUTIONSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGUREPUMPANDSOLUTIONSGUI.M with the given input arguments.
%
%      CONFIGUREPUMPANDSOLUTIONSGUI('Property','Value',...) creates a new CONFIGUREPUMPANDSOLUTIONSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configurePumpAndSolutionsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configurePumpAndSolutionsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configurePumpAndSolutionsGUI

% Last Modified by GUIDE v2.5 16-Oct-2018 12:10:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configurePumpAndSolutionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @configurePumpAndSolutionsGUI_OutputFcn, ...
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


% --- Executes just before configurePumpAndSolutionsGUI is made visible.
function configurePumpAndSolutionsGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configurePumpAndSolutionsGUI (see VARARGIN)
% Choose default command line output for configurePumpAndSolutionsGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%get daqParam
daqParam = getappdata(0,'daqParam');
pump = daqParam.FlowSystem.Pump;
% if no pump is connected, return without doing anything.
if isempty(pump)
    disp('No pump connected.')
    return
end
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
handles.totalFlowEdit.String = num2str(daqParam.FlowSystem.TotalFlow);
%set checkbox/editbox values
for i = 1:4
    %set each of the reservoirs that is enabled
    handles.(strcat('res',num2str(i),'check')).Value = daqParam.FlowSystem.Reservoirs(i);
    %if salt is enabled
    if handles.saltCheck.Value
        %set salt values and default pH to 0
        handles.(strcat('salt',num2str(i),'edit')).String = ...
            num2str(daqParam.FlowSystem.Concentrations(i));
        handles.(strcat('pH',num2str(i),'edit')).String = '0';
    else
        %else set pH values and default salt to 0
        handles.(strcat('pH',num2str(i),'edit')).String = ...
            num2str(daqParam.FlowSystem.Concentrations(i));
        handles.(strcat('salt',num2str(i),'edit')).String = '0';
    end
end
% UIWAIT makes configurePumpAndSolutionsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = configurePumpAndSolutionsGUI_OutputFcn(~,~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% handles    structure with handles and user data (see GUIDATA)
%if no pump is connnected, close
daqParam = getappdata(0,'daqParam');
if isempty(daqParam.Pump)
    close
    return
end
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in saltCheck.
function saltCheck_Callback(hObject, ~, handles)
% hObject    handle to saltCheck (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
%ensure pH and salt have opposite values
handles.pHcheck.Value = ~hObject.Value;

% --- Executes on button press in pHcheck.
function pHcheck_Callback(hObject,~, handles)
% hObject    handle to pHcheck (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
%ensure pH and salt have opposite values
handles.saltCheck.Value = ~hObject.Value;

% --- Executes on button press in updateClose.
function updateClose_Callback(~,~, handles)
% handles    structure with handles and user data (see GUIDATA)
%get pump object
daqParam = getappdata(0,'daqParam');
flowsystem = daqParam.FlowSystem;
pump = flowsystem.Pump;

%set mode
flowsystem.Mode = handles.saltCheck.Value;
%set total flow
flowsystem.TotalFlow = str2double(handles.totalFlowEdit.String);
%set tubeID
pump.TubeID = handles.tubeIDpopup.String{handles.tubeIDpopup.Value};
pump.setTubeIDs(pump.TubeID); %set tube ID
%set check marks
for i = 1:4
    flowsystem.Reservoirs(i) = handles.(strcat('res',num2str(i),'check')).Value;
    %if salt is enabled
    if handles.saltCheck.Value
        %set pump concentrations to salt values
        flowsystem.Concentrations(i) = ...
            str2double(handles.(strcat('salt',num2str(i),'edit')).String);
    else
        %set pump concentrations to pH values
        flowsystem.Concentrations(i) = ...
            str2double(handles.(strcat('pH',num2str(i),'edit')).String);
    end
end
close;
