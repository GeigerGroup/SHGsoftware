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
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configureFlowControlGUI

% Last Modified by GUIDE v2.5 02-Oct-2017 16:08:42

% Menu for specifying the points and conditions for the flow system made up
% of a pump and solenoid valve system, the data of which is stored in
% DAQparam.



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

% Table to hold the data that populates DAQparam FlowConcentrationPoint
% and FlowConcentrationValue. Its Data property is a cell array, column one
% represents the points and column two represents the values.

%get daqParam
daqParam = getappdata(0,'daqParam');

%horizontally concatenate and turn into cell array
data = horzcat(daqParam.FlowConcentrationPoint,daqParam.FlowConcentrationValue);
data = [num2cell(data);cell(1,2)]; %add blank row
hObject.Data = data;



% --- Executes when entered data in editable cell(s) in flowControlTable.
function flowControlTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to flowControlTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Turns the strings that are entered into numbers and, if there is no
% longer an empty row at the end of the table, will add another row.

%convert entered string to number
hObject.Data{eventdata.Indices(1),eventdata.Indices(2)} = str2double(eventdata.EditData);

%check if need to add more rows
%get length
last = size(hObject.Data);
last = last(1);

%check if either are not empty
if (~isempty(hObject.Data{last,1}) || ~isempty(hObject.Data{last,2}))
    %add row if so
    hObject.Data = [hObject.Data;cell(1,2)];
end


% --- Executes on button press in updateCloseButton.
function updateCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Takes the values that have been updated in the table and adds them to the
%DAQ parameters for flow control. Will crash if table doesn't have the same
%number of points and values. (fix?)

%convert from cell array to matrix
A = handles.flowControlTable.Data;
i1 = cellfun(@ischar,A);
sz = cellfun('size',A(~i1),2);
A(i1) = {nan(1,sz(1))};
C = cell2mat(A);

%get reference to daqparam and set values
daqParam = getappdata(0,'daqParam');
daqParam.FlowConcentrationPoint = C(:,1);
daqParam.FlowConcentrationValue = C(:,2);

close %close window