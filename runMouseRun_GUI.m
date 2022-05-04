function varargout = runMouseRun_GUI(varargin)
% RUNMOUSERUN_GUI MATLAB code for runMouseRun_GUI.fig
%      RUNMOUSERUN_GUI, by itself, creates a new RUNMOUSERUN_GUI or raises the existing
%      singleton*.
%
%      H = RUNMOUSERUN_GUI returns the handle to a new RUNMOUSERUN_GUI or the handle to
%      the existing singleton*.
%
%      RUNMOUSERUN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNMOUSERUN_GUI.M with the given input arguments.
%
%      RUNMOUSERUN_GUI('Property','Value',...) creates a new RUNMOUSERUN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runMouseRun_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runMouseRun_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runMouseRun_GUI

% Last Modified by GUIDE v2.5 08-Jun-2017 16:25:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runMouseRun_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @runMouseRun_GUI_OutputFcn, ...
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


% --- Executes just before runMouseRun_GUI is made visible.
function runMouseRun_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runMouseRun_GUI (see VARARGIN)

% Choose default command line output for runMouseRun_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Populate the listboxes
global baseDir
%baseDir = ['..'];
baseDir = '.';


projects = dir([baseDir filesep 'projects']);
projects(~[projects.isdir])=[]; 
projects(strcmp({projects.name},'.'))=[]; 
projects(strcmp({projects.name},'..'))=[]; 
projects = {projects.name}';
set(handles.listbox1,'String',projects);

% UIWAIT makes runMouseRun_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runMouseRun_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% MOUSE LIST BOX
function listbox1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
global baseDir
contents = cellstr(get(hObject,'String'));
projSel = contents{get(hObject,'Value')};

mice = dir([baseDir filesep 'mice']);
mice(~[mice.isdir]) = [];
mice(strcmp({mice.name},'.'))=[]; 
mice(strcmp({mice.name},'..'))=[]; 
mice = {mice.name}';
set(handles.listbox2,'String',mice);

stim = dir([baseDir filesep 'projects' filesep projSel filesep '*params*']);
stim([stim.isdir]) = [];
stim = {stim.name}';
set(handles.listbox3,'Value',1);
set(handles.listbox3,'String',stim);



function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% SELECT PROJECT
function listbox2_Callback(hObject, eventdata, handles) %#ok<*INUSL>



% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% FILE SELECTION
function listbox3_Callback(hObject, eventdata, handles)

function listbox3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% START
function pushbutton1_Callback(hObject, eventdata, handles)
global baseDir

blockVector = str2num(get(handles.edit1,'String')')';
contents = cellstr(get(handles.listbox3,'String'));
parameterFile = contents{get(handles.listbox3,'Value')};
contents = cellstr(get(handles.listbox1,'String'));
project = contents{get(handles.listbox1,'Value')};
contents = cellstr(get(handles.listbox2,'String'));
mouse = contents{get(handles.listbox2,'Value')};

run(sprintf('%s\\projects\\%s\\%s',baseDir,project,parameterFile));
feval(params.beh_func,mouse,baseDir,project,parameterFile);


% switch project
%     case 'wheel_toneClouds'
%         %wheel_behaviour_TESTINGgui(mouse,project,parameterFile);
%         wheel_2AFC(mouse,baseDir,project,parameterFile);
%     case 'speech_in_noise'
%         wheel_2AFC(mouse,baseDir,project,parameterFile);
%     case 'habituation'
%         wheel_2AFC_habituation(mouse,baseDir,project,parameterFile);
%     otherwise
%          wheel_2AFC_kcw(mouse,baseDir,project,parameterFile);
%         
% end
