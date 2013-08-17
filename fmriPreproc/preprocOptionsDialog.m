function varargout = preprocOptionsDialog(varargin)
% PREPROCOPTIONSDIALOG MATLAB code for preprocOptionsDialog.fig
%      PREPROCOPTIONSDIALOG by itself, creates a new PREPROCOPTIONSDIALOG or raises the
%      existing singleton*.
%
%      H = PREPROCOPTIONSDIALOG returns the handle to a new PREPROCOPTIONSDIALOG or the handle to
%      the existing singleton*.
%
%      PREPROCOPTIONSDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCOPTIONSDIALOG.M with the given input arguments.
%
%      PREPROCOPTIONSDIALOG('Property','Value',...) creates a new PREPROCOPTIONSDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocOptionsDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocOptionsDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocOptionsDialog

% Last Modified by GUIDE v2.5 17-Aug-2013 12:26:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocOptionsDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocOptionsDialog_OutputFcn, ...
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

% --- Executes just before preprocOptionsDialog is made visible.
function preprocOptionsDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preprocOptionsDialog (see VARARGIN)

% Choose default command line output for preprocOptionsDialog
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
% 
% if(nargin > 3)
%     for index = 1:2:(nargin-3),
%         if nargin-3==index, break, end
%         switch lower(varargin{index})
%          case 'title'
%           set(hObject, 'Name', varargin{index+1});
%          case 'string'
%           set(handles.text1, 'String', varargin{index+1});
%         end
%     end
% end



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

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% Default options
defaultOptions = struct(...
    'subjid','Input SubjectID',...
    'FSsubjid','',...
    'skipVols',0,...
    'keepVols',Inf,...
    'doSliceTimeCorr',true,...
    'doMotionCorr',true,...
    'sliceTimeFirstFlag',true,...		% true = slice time correction before motion correction
    'sliceUpFlag',true,...				% true = 1:N, false = N:-1:1
    'sliceInterleave',1,...				% 0 = sequential, 1 = odd,even, 2 = even,odd
    'revSliceOrderFlag',true,...		% slicetimer corrects properly when slice-order file is reverse of true order
    'replaceAll',0,...					% -1 = don't replace any existing files, 0 = ask, 1 = replace all existing files
    'verbose',~false,...					% dump system commands to Matlab command window
    'betFlag',~true,...					% bet before aligning to freesurfer space
    'iRef',1,...
    'mrVistaSession','',...
    'mrVistaDescription','',...
    'mrVistaComment','',...
    'mrVistaCycles',1	);
handles.reconOptions = defaultOptions;

if nargin >= 4 && ~isempty(varargin{1});
    
    if ischar(varargin{1})
        handles.reconOptions.subjid = varargin{1};
        handles.reconOptions.FSsubjid = [varargin{1} '_fs4'];
    elseif isstruct(varargin{1})
        handles.reconOptions = varargin{1};
    end
end


if ispref('mrCurrent','AnatomyFolder')
    handles.anatDir = getpref('mrCurrent','AnatomyFolder');
    handles.anatDir = fullfile(handles.anatDir, handles.reconOptions.subjid);
%     guidata(hObject, handles);
%     validateAnatomyDir(hObject,handles)
%     handles = guidata(hObject);
elseif ispref('VISTA','defaultAnatomyPath');
    handles.anatDir = getpref('VISTA','defaultAnatomyPath');
end

if ispref('freesurfer','SUBJECTS_DIR')
	handles.fsSubjectsDir = getpref('freesurfer','SUBJECTS_DIR');
end

if ~isfield(handles.reconOptions, 'vAnat') || isempty(handles.reconOptions.vAnat)    
    handles.reconOptions.vAnat = fullfile(handles.anatDir,'nifti','vAnat');
end

if ~isfield(handles.reconOptions, 'vBrain') || isempty(handles.reconOptions.vBrain)    
    handles.reconOptions.vBrain = fullfile(handles.anatDir,'nifti','vBrain');
end

if ~isfield(handles.reconOptions, 'vClass') || isempty(handles.reconOptions.vClass)    
    handles.reconOptions.vClass = fullfile(handles.anatDir,'nifti','vClass');
end

if ~isfield(handles.reconOptions, 'vWm') || isempty(handles.reconOptions.vWm)    
    handles.reconOptions.vWm = fullfile(handles.anatDir,'nifti','vWm');
end

handles.inputDir = pwd;

refreshGui(hObject,handles)

% UIWAIT makes preprocOptionsDialog wait for user response (see UIRESUME)
uiwait(handles.figure1);

function refreshGui(hObject,handles)

set(handles.subjectId,'String',handles.reconOptions.subjid);    
set(handles.freesurferId,'String',handles.reconOptions.FSsubjid);    
set(handles.skipVol,'String',num2str(handles.reconOptions.skipVols));    
set(handles.keepVol,'String',num2str(handles.reconOptions.keepVols));    

set(handles.correctSliceTime,'Value',handles.reconOptions.doSliceTimeCorr);    
set(handles.correctMotion,'Value',handles.reconOptions.doMotionCorr);    

if handles.reconOptions.sliceTimeFirstFlag
set(handles.processingOrder,'Value',1);    
else
set(handles.processingOrder,'Value',2);
end

if handles.reconOptions.sliceUpFlag
set(handles.sliceOrder,'Value',1);    
else
set(handles.sliceOrder,'Value',2);
end

set(handles.interleaveOrder,'Value',handles.reconOptions.sliceInterleave+1);
set(handles.reverseSliceFile,'Value',handles.reconOptions.revSliceOrderFlag);

set(handles.overwritePolicy,'Value',handles.reconOptions.replaceAll+2);
set(handles.extractBrain,'Value',handles.reconOptions.betFlag);

set(handles.refScanIndex,'String',num2str(handles.reconOptions.iRef));    


set(handles.volumeAnatomyText,'String',handles.reconOptions.vAnat);
set(handles.volumeBrainText,'String',handles.reconOptions.vBrain);
set(handles.volumeClassText,'String',handles.reconOptions.vClass);
set(handles.volumeWmText,'String',handles.reconOptions.vWm);


guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = preprocOptionsDialog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in continueButton.
function continueButton_Callback(hObject, eventdata, handles)
% hObject    handle to continueButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.reconOptions;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.output = get(hObject,'String');
% 
% % Update handles structure
% guidata(hObject, handles);
% 
% % Use UIRESUME instead of delete because the OutputFcn needs
% % to get the updated handles structure.
% uiresume(handles.figure1);

handles.output = [];

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = '';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
   handles.output = handles.reconOptions;
    
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.figure1);
end    



function subjectId_Callback(hObject, eventdata, handles)
% hObject    handle to subjectId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectId as text
%        str2double(get(hObject,'String')) returns contents of subjectId as a double
subjid = get(hObject,'String');
handles.reconOptions.subjid = subjid;
handles.reconOptions.FSsubjid = [subjid '_fs4'];

refreshGui(hObject, handles);

% --- Executes during object creation, after setting all properties.
function subjectId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freesurferId_Callback(hObject, eventdata, handles)
% hObject    handle to freesurferId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freesurferId as text
%        str2double(get(hObject,'String')) returns contents of freesurferId as a double

handles.reconOptions.FSsubjid = get(hObject,'String');
refreshGui(hObject, handles);

% --- Executes during object creation, after setting all properties.
function freesurferId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freesurferId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipVol_Callback(hObject, eventdata, handles)
% hObject    handle to skipVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skipVol as text
%        str2double(get(hObject,'String')) returns contents of skipVol as a double
handles.reconOptions.skipVols = str2double(get(hObject,'String'));
refreshGui(hObject,handles);

% --- Executes during object creation, after setting all properties.
function skipVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function keepVol_Callback(hObject, eventdata, handles)
% hObject    handle to keepVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of keepVol as text
%        str2double(get(hObject,'String')) returns contents of keepVol as a double
handles.reconOptions.keepVols = str2double(get(hObject,'String'));
refreshGui(hObject,handles);


% --- Executes during object creation, after setting all properties.
function keepVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keepVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in correctSliceTime.
function correctSliceTime_Callback(hObject, eventdata, handles)
% hObject    handle to correctSliceTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctSliceTime
handles.reconOptions.doSliceTimeCorr = get(hObject,'Value');
refreshGui(hObject,handles);


% --- Executes on button press in correctMotion.
function correctMotion_Callback(hObject, eventdata, handles)
% hObject    handle to correctMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctMotion

handles.reconOptions.doMotionCorr = get(hObject,'Value');
refreshGui(hObject,handles);

% --- Executes on selection change in processingOrder.
function processingOrder_Callback(hObject, eventdata, handles)
% hObject    handle to processingOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processingOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processingOrder

% Update handles structure
selection = get(hObject,'Value');
if selection ==1
    handles.reconOptions.sliceTimeFirstFlag = true;
elseif selection ==2
    handles.reconOptions.sliceTimeFirstFlag = false;
end

refreshGui(hObject,handles);

% --- Executes during object creation, after setting all properties.
function processingOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processingOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sliceOrder.
function sliceOrder_Callback(hObject, eventdata, handles)
% hObject    handle to sliceOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sliceOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sliceOrder

selection = get(hObject,'Value');

if selection ==1
    handles.reconOptions.sliceUpFlag = true;
elseif selection ==2
    handles.reconOptions.sliceUpFlag = false;
end

refreshGui(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sliceOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in interleaveOrder.
function interleaveOrder_Callback(hObject, eventdata, handles)
% hObject    handle to interleaveOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns interleaveOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from interleaveOrder

selection = get(hObject,'Value');
handles.reconOptions.sliceInterleave=selection-1;
refreshGui(hObject,handles);


% --- Executes during object creation, after setting all properties.
function interleaveOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interleaveOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reverseSliceFile.
function reverseSliceFile_Callback(hObject, eventdata, handles)
% hObject    handle to reverseSliceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reverseSliceFile
handles.reconOptions.revSliceOrderFlag = get(hObject,'Value');
refreshGui(hObject,handles);

% --- Executes on selection change in overwritePolicy.
function overwritePolicy_Callback(hObject, eventdata, handles)
% hObject    handle to overwritePolicy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns overwritePolicy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from overwritePolicy

handles.reconOptions.replaceAll=get(hObject,'Value')-2;
refreshGui(hObject,handles);


% --- Executes during object creation, after setting all properties.
function overwritePolicy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overwritePolicy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in verbose.
function verbose_Callback(hObject, eventdata, handles)
% hObject    handle to verbose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of verbose

handles.reconOptions.verbose = get(hObject,'Value');
refreshGui(hObject,handles);


function refScanIndex_Callback(hObject, eventdata, handles)
% hObject    handle to refScanIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of refScanIndex as text
%        str2double(get(hObject,'String')) returns contents of refScanIndex as a double


% --- Executes during object creation, after setting all properties.
function refScanIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refScanIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fmriScans.
function fmriScans_Callback(hObject, eventdata, handles)
% hObject    handle to fmriScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fmriScans contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fmriScans

refScanIdx = get(hObject,'Value');
set(handles.refScanIndex,'String',num2str(refScanIdx));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function fmriScans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmriScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectScans.
function selectScans_Callback(hObject, eventdata, handles)
% hObject    handle to selectScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fMRIfiles,inputDir] = uigetfile(fullfile(handles.inputDir,'*.nii.gz'),'CHOOSE fMRI FILE(S)','MultiSelect','on');
handles.inputDir = inputDir;

set(handles.fmriScans,'String',fMRIfiles)
set(handles.fmriScans,'Value',1)
guidata(hObject, handles);



% --- Executes on button press in extractBrain.
function extractBrain_Callback(hObject, eventdata, handles)
% hObject    handle to extractBrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extractBrain
handles.reconOptions.betFlag = get(hObject,'Value');
refreshGui(hObject,handles);


function volumeAnatomyText_Callback(hObject, eventdata, handles)
% hObject    handle to volumeAnatomyText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volumeAnatomyText as text
%        str2double(get(hObject,'String')) returns contents of volumeAnatomyText as a double
handles.anatDir = get(hObject,'String');

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function volumeAnatomyText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeAnatomyText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volumeAnatomyButton.
function volumeAnatomyButton_Callback(hObject, eventdata, handles)
% hObject    handle to volumeAnatomyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[userFile userDir] = uigetfile('','Choose Volume Anatomy');

if userDir ==0
    return
end

handles.reconOptions.vAnat = fullfile(userDir,userFile);
set(handles.volumeAnatomyText,'String',fullfile(userDir,userFile));

guidata(hObject, handles);



function volumeBrainText_Callback(hObject, eventdata, handles)
% hObject    handle to volumeBrainText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volumeBrainText as text
%        str2double(get(hObject,'String')) returns contents of volumeBrainText as a double


% --- Executes during object creation, after setting all properties.
function volumeBrainText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeBrainText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volumeBrainButton.
function volumeBrainButton_Callback(hObject, eventdata, handles)
% hObject    handle to volumeBrainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function volumeWmText_Callback(hObject, eventdata, handles)
% hObject    handle to volumeWmText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volumeWmText as text
%        str2double(get(hObject,'String')) returns contents of volumeWmText as a double


% --- Executes during object creation, after setting all properties.
function volumeWmText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeWmText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volumeWmButton.
function volumeWmButton_Callback(hObject, eventdata, handles)
% hObject    handle to volumeWmButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function volumeClassText_Callback(hObject, eventdata, handles)
% hObject    handle to volumeClassText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volumeClassText as text
%        str2double(get(hObject,'String')) returns contents of volumeClassText as a double


% --- Executes during object creation, after setting all properties.
function volumeClassText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeClassText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volumeClassButton.
function volumeClassButton_Callback(hObject, eventdata, handles)
% hObject    handle to volumeClassButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
