function varargout = setAnatomyLocationDialog(varargin)
% SETANATOMYLOCATIONDIALOG MATLAB code for setAnatomyLocationDialog.fig
%      SETANATOMYLOCATIONDIALOG, by itself, creates a new SETANATOMYLOCATIONDIALOG or raises the existing
%      singleton*.
%
%      H = SETANATOMYLOCATIONDIALOG returns the handle to a new SETANATOMYLOCATIONDIALOG or the handle to
%      the existing singleton*.
%
%      SETANATOMYLOCATIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETANATOMYLOCATIONDIALOG.M with the given input arguments.
%
%      SETANATOMYLOCATIONDIALOG('Property','Value',...) creates a new SETANATOMYLOCATIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setAnatomyLocationDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setAnatomyLocationDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setAnatomyLocationDialog

% Last Modified by GUIDE v2.5 01-Aug-2013 13:34:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setAnatomyLocationDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @setAnatomyLocationDialog_OutputFcn, ...
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


% --- Executes just before setAnatomyLocationDialog is made visible.
function setAnatomyLocationDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setAnatomyLocationDialog (see VARARGIN)

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Choose default command line output for setAnatomyLocationDialog
handles.output = hObject;
handles.errorString = {};
if nargin >= 4 && ~isempty(varargin{1});
    handles.subjId = varargin{1};
    set(handles.subjIdText,'String',handles.subjId);    
else
    handles.subjId = 'Input Subject Id';    
end

handles.fsSubjId = [handles.subjId '_fs4'];
set(handles.fsIdText,'String',handles.fsSubjId);    

% freesurfer SUBJECTS_DIR Matlab preference will override system environment variable
handles.fsSubjectsDir = '';

if ispref('freesurfer','SUBJECTS_DIR')
	SUBJECTS_DIR = getpref('freesurfer','SUBJECTS_DIR');
else
	% Check Freesurfer's SUBJECTS_DIR environment variable
	SUBJECTS_DIR = getenv('SUBJECTS_DIR');									% returns empty if none

end

if isempty(SUBJECTS_DIR)

    handles.errorString{end+1} = 'no freesurfer SUBJECTS_DIR environment variable or preference';
    set(handles.freesurferDirText,'BackgroundColor',[1 0 0]);
else
    handles.fsSubjectsDir = SUBJECTS_DIR;
%     guidata(hObject, handles);
%     validateFreesurferDir(hObject,handles)
%     handles = guidata(hObject);

end


handles.anatDir = '';
if ispref('mrCurrent','AnatomyFolder')
    handles.anatDir = getpref('mrCurrent','AnatomyFolder');
%     guidata(hObject, handles);
%     validateAnatomyDir(hObject,handles)
%     handles = guidata(hObject);
elseif ispref('VISTA','defaultAnatomyPath');
        handles.anatDir = getpref('VISTA','defaultAnatomyPath');
else
    handles.errorString{end+1} = 'no mrCurrent anatomy folder preference';
end

if ~ischar(handles.anatDir)
    handles.anatDir = '';
end


if ~ischar(handles.fsSubjectsDir)
    handles.fsSubjectsDir = '';
end


set(handles.msgBox,'String',handles.errorString);
handles.errorString = {};
% Update handles structure
guidata(hObject, handles);
validateInputs(hObject,handles);

% UIWAIT makes setAnatomyLocationDialog wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setAnatomyLocationDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.subjId;
% The figure can be deleted now
delete(handles.figure1);



function subjIdText_Callback(hObject, eventdata, handles)
% hObject    handle to subjIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjIdText as text
%        str2double(get(hObject,'String')) returns contents of subjIdText as a double

handles.subjId = get(hObject,'String');
handles.fsSubjId = [handles.subjId '_fs4'];

set(handles.fsIdText,'String',handles.fsSubjId);

guidata(hObject, handles);
validateInputs(hObject,handles);
%validateSubjectId(hObject, handles);

function isGood = validateSubjectId(hObject,handles)

subjectFreesurferDir = fullfile(handles.fsSubjectsDir,handles.fsSubjId);
subjectAnatomyDir = fullfile(handles.anatDir,handles.subjId);

if ~isdir(subjectFreesurferDir)
    handles.errorString{end+1} = ['Cannot Find SUBJECT ' handles.fsSubjId ' in freesurfer folder: ' subjectFreesurferDir];
    set(handles.fsIdText,'BackgroundColor',[1 0 0]);
    isGood = false;
else
    set(handles.fsIdText,'BackgroundColor',[.2 1 0]);
    isGood = true;
end

if ~isdir(subjectAnatomyDir)
    handles.errorString{end+1} = ['Cannot Find SUBJECT ' handles.subjId ' in anatomy folder: ' subjectAnatomyDir];
    set(handles.subjIdText,'BackgroundColor',[1 0 0]);
    isGood = false;
else
    set(handles.subjIdText,'BackgroundColor',[.2 1 0]);
    isGood = true;
end

set(handles.msgBox,'String',handles.errorString);
handles.errorString = {};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function subjIdText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function anatomyDirText_Callback(hObject, eventdata, handles)
% hObject    handle to anatomyDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of anatomyDirText as text
%        str2double(get(hObject,'String')) returns contents of anatomyDirText as a double
handles.anatDir = get(hObject,'String');

guidata(hObject, handles);
validateInputs(hObject,handles)
%validateAnatomyDir(hObject,handles)

 

function isGood = validateAnatomyDir(hObject,handles)

if ~isdir(handles.anatDir)
    set(handles.anatomyDirText,'String',handles.anatDir);
    handles.errorString{end+1} = ['Cannot Find Directory: ' handles.anatDir];
    set(handles.anatomyDirText,'BackgroundColor',[1 0 0]);
    isGood = false;
else
    set(handles.anatomyDirText,'String',handles.anatDir);
    set(handles.anatomyDirText,'BackgroundColor',[.2 1 0]);
    isGood = true;
end

set(handles.msgBox,'String',handles.errorString);
handles.errorString = {};

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function anatomyDirText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anatomyDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freesurferDirText_Callback(hObject, eventdata, handles)
% hObject    handle to freesurferDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freesurferDirText as text
%        str2double(get(hObject,'String')) returns contents of freesurferDirText as a double
handles.fsSubjectsDir = get(hObject,'String');

guidata(hObject, handles);
validateInputs(hObject,handles);
%validateFreesurferDir(hObject,handles)

 

function isGood = validateFreesurferDir(hObject,handles)


if ~isdir(handles.fsSubjectsDir)
    set(handles.freesurferDirText,'String',handles.fsSubjectsDir);
    handles.errorString{end+1} = ['Cannot Find Directory: ' handles.fsSubjectsDir];
    set(handles.freesurferDirText,'BackgroundColor',[1 0 0]);
    isGood= false;
else
    set(handles.freesurferDirText,'String',handles.fsSubjectsDir);
    set(handles.freesurferDirText,'BackgroundColor',[.2 1 0]);
    isGood = true;
end

set(handles.msgBox,'String',handles.errorString);
handles.errorString = {};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function freesurferDirText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freesurferDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function fsIdText_Callback(hObject, eventdata, handles)
% hObject    handle to fsIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fsIdText as text
%        str2double(get(hObject,'String')) returns contents of fsIdText as a double

handles.errorString{end+1} = ['User Setting of This Field is Not Supported Yet'];
set(handles.msgBox,'String',handles.errorString);
handles.errorString = {};
set(hObject,'String',handles.fsSubjId);




% --- Executes during object creation, after setting all properties.
function fsIdText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function isGood = validateInputs(hObject,handles)

fsIsGood=validateFreesurferDir(hObject,handles);
anatIsGood=validateAnatomyDir(hObject,handles);
subjIsGood=validateSubjectId(hObject,handles);

isGood = fsIsGood && anatIsGood && subjIsGood;

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


inputIsGood = validateInputs(hObject,handles);

if ~inputIsGood
    
    handles.errorString{end+1} = '******************************';
    handles.errorString{end+1} = 'Cannot save because:';
    
    if ~validateFreesurferDir(hObject,handles);
        handles.errorString{end+1} = 'Freesurfer Dir Not Valid';
    end
    if ~validateAnatomyDir(hObject,handles);
        handles.errorString{end+1} = 'mrCurrent/mrVista Anatomy Directory Not Valid';
    end    
    if ~validateSubjectId(hObject,handles);
        handles.errorString{end+1} = 'Subject Data Not Found';
    end
    
    set(handles.msgBox,'String',handles.errorString);
%    set(handles.saveButton,'BackgroundColor',[1 0 0]);
    handles.errorString = {};
    
else
    handles.output = handles.subjId;
    
    setpref('freesurfer','SUBJECTS_DIR',handles.fsSubjectsDir);
    setpref('mrCurrent','AnatomyFolder',handles.anatDir);
    setpref('VISTA','defaultAnatomyPath',handles.anatDir);
    disp(['Setting freesurfer SUBJECTS_DIR to: ' handles.fsSubjectsDir]);
    disp(['Setting mrCurrent/mrVista anatomy directory to: ' handles.anatDir]);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure1);
end

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = [];
handles.subjId = [];
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in anatomyBrowseButton.
function anatomyBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to anatomyBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userDir = uigetdir('','Choose Anatomy Dir');

if userDir ==0
    return
end

handles.anatDir = userDir;

guidata(hObject, handles);
validateAnatomyDir(hObject,handles);


% --- Executes on button press in fsBrowseButton.
function fsBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to fsBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userDir = uigetdir('','Choose Freesurfer SUBJECTS_DIR Dir');

if userDir ==0
    return
end
handles.fsSubjectsDir = userDir;

guidata(hObject, handles);
validateFreesurferDir(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%CloseReqFCN
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
% Hint: delete(hObject) closes the figure
