function varargout = programmedPumpControlGUI(varargin)
%PROGRAMMEDPUMPCONTROLGUI M-file for programmedPumpControlGUI.fig
%      PROGRAMMEDPUMPCONTROLGUI, by itself, creates a new PROGRAMMEDPUMPCONTROLGUI or raises the existing
%      singleton*.
%
%      H = PROGRAMMEDPUMPCONTROLGUI returns the handle to a new PROGRAMMEDPUMPCONTROLGUI or the handle to
%      the existing singleton*.
%
%      PROGRAMMEDPUMPCONTROLGUI('Property','Value',...) creates a new PROGRAMMEDPUMPCONTROLGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to programmedPumpControlGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PROGRAMMEDPUMPCONTROLGUI('CALLBACK') and PROGRAMMEDPUMPCONTROLGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PROGRAMMEDPUMPCONTROLGUI.M with the given input
%      arguments.
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help programmedPumpControlGUI

% Last Modified by GUIDE v2.5 16-Oct-2018 12:25:04

% Menu for specifying the points and conditions for the flow system made up
% of a pump and solenoid valve system, the data of which is stored in
% DAQparam.



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @programmedPumpControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @programmedPumpControlGUI_OutputFcn, ...
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


% --- Executes just before programmedPumpControlGUI is made visible.
function programmedPumpControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for programmedPumpControlGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes programmedPumpControlGUI wait for user response (see UIRESUME)
% uiwait(handles.configureFlowControl);


% --- Outputs from this function are returned to the command line.
function varargout = programmedPumpControlGUI_OutputFcn(hObject, eventdata, handles)
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
