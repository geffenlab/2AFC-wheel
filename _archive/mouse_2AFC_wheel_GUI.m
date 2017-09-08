function varargout = mouse_2AFC_wheel_GUI(varargin)
% MOUSE_2AFC_WHEEL_GUI MATLAB code for mouse_2AFC_wheel_GUI.fig
%      MOUSE_2AFC_WHEEL_GUI, by itself, creates a new MOUSE_2AFC_WHEEL_GUI or raises the existing
%      singleton*.
%
%      H = MOUSE_2AFC_WHEEL_GUI returns the handle to a new MOUSE_2AFC_WHEEL_GUI or the handle to
%      the existing singleton*.
%
%      MOUSE_2AFC_WHEEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSE_2AFC_WHEEL_GUI.M with the given input arguments.
%
%      MOUSE_2AFC_WHEEL_GUI('Property','Value',...) creates a new MOUSE_2AFC_WHEEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mouse_2AFC_wheel_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mouse_2AFC_wheel_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mouse_2AFC_wheel_GUI

% Last Modified by GUIDE v2.5 19-Oct-2016 16:02:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mouse_2AFC_wheel_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mouse_2AFC_wheel_GUI_OutputFcn, ...
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


% --- Executes just before mouse_2AFC_wheel_GUI is made visible.
function mouse_2AFC_wheel_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mouse_2AFC_wheel_GUI (see VARARGIN)

% Choose default command line output for mouse_2AFC_wheel_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global wb
wb.gotMouse = 0;


% UIWAIT makes mouse_2AFC_wheel_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mouse_2AFC_wheel_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% START BUTTON
function pushbutton1_Callback(hObject, eventdata, handles)
global wb
if wb.gotMouse==0
    set(handles.text5,'String','Enter mouse number')
else
    set(handles.text5,'String','Running behaviour')
    wb.run=1;
    if strcmp(wb.dev,'nidaq')
        wheel_behaviour;
    else
        wheel_behaviour_soundCard;
    end
end


% STOP BUTTON
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PsychPortAudio('Stop', sc, 0); % 'Stop', pahandle [,waitForEndOfPlayback=0] 
PsychPortAudio('close',sc);
delete(sc);
disp('Session ended');
close all



% soundcard/nidaq
function popupmenu1_Callback(hObject, eventdata, handles)
global wb
contents = cellstr(get(hObject,'String'));
wb.dev=contents{get(hObject,'Value')};



% soundcard/nidaq
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global wb
contents = cellstr(get(hObject,'String'));
wb.dev=contents{get(hObject,'Value')};


% MOUSE NAME
function edit1_Callback(hObject, eventdata, handles)
global wb
wb.mouse = get(hObject,'String');
wb.gotMouse = 1;



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup3.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global wb
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton3'
        display('habituation');
        wb.behType = 1;
    case 'radiobutton2'
        display('training');
        wb.behType = 2;
    case 'radiobutton4'
        display('testing');
        wb.behType = 3;
end
