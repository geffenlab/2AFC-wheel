function varargout = mouse_2AFC_wheel(varargin)
% MOUSE_2AFC_WHEEL MATLAB code for mouse_2AFC_wheel.fig
%      MOUSE_2AFC_WHEEL, by itself, creates a new MOUSE_2AFC_WHEEL or raises the existing
%      singleton*.
%
%      H = MOUSE_2AFC_WHEEL returns the handle to a new MOUSE_2AFC_WHEEL or the handle to
%      the existing singleton*.
%
%      MOUSE_2AFC_WHEEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSE_2AFC_WHEEL.M with the given input arguments.
%
%      MOUSE_2AFC_WHEEL('Property','Value',...) creates a new MOUSE_2AFC_WHEEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mouse_2AFC_wheel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mouse_2AFC_wheel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mouse_2AFC_wheel

% Last Modified by GUIDE v2.5 07-Jun-2016 14:21:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mouse_2AFC_wheel_OpeningFcn, ...
                   'gui_OutputFcn',  @mouse_2AFC_wheel_OutputFcn, ...
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


% --- Executes just before mouse_2AFC_wheel is made visible.
function mouse_2AFC_wheel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mouse_2AFC_wheel (see VARARGIN)

% Choose default command line output for mouse_2AFC_wheel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% UIWAIT makes mouse_2AFC_wheel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mouse_2AFC_wheel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1. START BUTTON
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global wb
wb.run=1;
wheel_behaviour;


% --- Executes on button press in pushbutton2. STOP BUTTON
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global wb
wb.run=2;

