function varargout = mrcDataViewer(varargin)
% MRCDATAVIEWER M-file for mrcDataViewer.fig
%      MRCDATAVIEWER, by itself, creates a new MRCDATAVIEWER or raises the existing
%      singleton*.
%
%      H = MRCDATAVIEWER returns the handle to a new MRCDATAVIEWER or the handle to
%      the existing singleton*.
%
%      MRCDATAVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MRCDATAVIEWER.M with the given input arguments.
%
%      MRCDATAVIEWER('Property','Value',...) creates a new MRCDATAVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mrcDataViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mrcDataViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mrcDataViewer

% Last Modified by GUIDE v2.5 25-Aug-2010 11:43:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mrcDataViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @mrcDataViewer_OutputFcn, ...
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


% --- Executes just before mrcDataViewer is made visible.
function mrcDataViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mrcDataViewer (see VARARGIN)

% Choose default command line output for mrcDataViewer
handles.output = hObject;

set(handles.versionNumber,'String','v100');

availableHeadmodels = { 'mni0001','nih1511v2'};
set(handles.headmodelChoices,'String',availableHeadmodels);

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes mrcDataViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mrcDataViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadProject.
function loadProject_Callback(hObject, eventdata, handles)
% hObject    handle to loadProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


projDir = uigetdir();

if projDir==0
    return;
end

dirList = dir(projDir);

dirNames = {dirList([dirList(:).isdir]).name};
dirNames = {dirNames{~strncmp('.',dirNames,1)}};
%keyboard

for iSubj = 1:length(dirNames)
    
    subjId = dirNames{iSubj};
    
    exportDir = dir(fullfile(projDir,subjId,'Exp*'));
    
    if isempty(exportDir)
        disp(['Cannot find data for: ' subjId])
    end

    condFiles = dir(fullfile(projDir,subjId,exportDir(1).name,'Axx_c*.mat'));
    condFiles = {condFiles(:).name};
    
        
    for iCond = 1:length(condFiles)
        
        
        condFilename = fullfile(projDir,subjId,exportDir(1).name,condFiles{iCond});
        thisCondData = load(condFilename);
        
        disp( ['Processing: ' subjId ' condition: ' condFiles{iCond} ' number: ' num2str(iCond) ])

        
        %On first iteration initialize space for data;
        if iSubj ==1 && iCond ==1;    
            data = rmfield(thisCondData,{'Wave' 'Sin' 'Cos' 'Amp'});                    
            data.Spec = complex(zeros(length(dirNames),length(condFiles),thisCondData.nFr,thisCondData.nCh));
            data.Wave = zeros(length(dirNames),length(condFiles),thisCondData.nT,thisCondData.nCh);
            data.Cov = zeros(length(dirNames),length(condFiles),thisCondData.nCh,thisCondData.nCh);
            data.meanCov = zeros(length(dirNames),thisCondData.nCh,thisCondData.nCh);
            data.trialsPerCond = zeros(length(dirNames),length(condFiles));
        end
        

        if ~isfield(thisCondData,'nTrl')
            thisCondData.nTrl = 1;
        end
        
        data.trialsPerCond(iSubj,iCond) = thisCondData.nTrl;
        data.Spec(iSubj,iCond,:,:) = complex(thisCondData.Cos,thisCondData.Sin);
        %data.Wave(iSubj,iCond,:,:) = thisCondData.Wave;
        %Quick and Dirty DC offset removal, should make this an option.
        data.Wave(iSubj,iCond,:,:) = bsxfun(@minus,thisCondData.Wave,mean(thisCondData.Wave,1));
        data.Cov(iSubj,iCond,:,:) = thisCondData.Cov;
        
        

    end
    
    %weight estimate of noise covariance by number of trials
    trialWeighting = squeeze(data.trialsPerCond(iSubj,:)./sum(data.trialsPerCond(iSubj,:)))';
    weightCov = bsxfun(@times,squeeze(data.Cov(iSubj,:,:,:)),trialWeighting);    

    if ndims(weightCov) <4,
       weightCov = shiftdim(weightCov,-1);
    end
    
    data.meanCov(iSubj,:,:) = squeeze(sum(weightCov,2));
    
end

condList = condFiles;
data.nSubjects = length(dirNames);
data.xFrqs = 0:data.dFHz:(data.nFr-1)*data.dFHz;
data.xTms = 0:data.dTms:(data.nT-1)*data.dTms;
data.subjectScaling = ones(data.nSubjects,1,1,1);

set(handles.subjectListbox,'String',dirNames,'Value',1:length(dirNames))
set(handles.condListbox,'String',condList)

handles.data = data;

handles.data.allWave = handles.data.Wave; 
handles.data.allSpec = handles.data.Spec; 
handles.data.allCov  = handles.data.Cov; 

%setappdata(hObject,'projData',data)
guidata(hObject, handles);

refreshOptions(hObject, eventdata, handles);
handles = guidata(hObject);

setWeighting(hObject, eventdata, handles);
handles = guidata(hObject);

guidata(hObject, handles);


%-------------
% sets all the UI handle options
function refreshOptions(hObject, eventdata, handles)

f1Start = str2double(get(handles.f1Start,'String'));
f1Stop = str2double(get(handles.f1Stop,'String'));

f2Start = str2double(get(handles.f2Start,'String'));
f2Stop = str2double(get(handles.f2Stop,'String'));


time1Start = str2double(get(handles.time1Start,'String'));
time1Stop = str2double(get(handles.time1Stop,'String'));

time2Start = str2double(get(handles.time2Start,'String'));
time2Stop = str2double(get(handles.time2Stop,'String'));

%Validate frequency inputs (str2double returns NaN on fail.
if isnan(f1Start)
    f1Start = handles.data.xFrqs(handles.data.i1F1+1);
    set(handles.f1Start,'String',num2str(f1Start));
end

if isnan(f1Stop)
    f1Stop = handles.data.xFrqs(end);
    set(handles.f1Stop,'String',num2str(f1Stop));
end

if isnan(f2Start)
    f2Start = handles.data.xFrqs(handles.data.i1F2+1);
    set(handles.f2Start,'String',num2str(f2Start));
end

if isnan(f2Stop)
    f2Stop = handles.data.xFrqs(end);
    set(handles.f2Stop,'String',num2str(f2Stop));
end


%Validate Time inputs (str2double returns NaN on fail.
if isnan(time1Start)
    time1Start = handles.data.xTms(1);
    set(handles.time1Start,'String',num2str(time1Start));
end

if isnan(time1Stop)
    time1Stop = handles.data.xTms(fix(end/2));
    set(handles.time1Stop,'String',num2str(time1Stop,3));
end

if isnan(time2Start)
    time2Start = 0;%handles.data.xTms(end);
    set(handles.time2Start,'String',num2str(time2Start));
end

if isnan(time2Stop)
    time2Stop = 0;%handles.data.xTms(end);
    set(handles.time2Stop,'String',num2str(time2Stop));
end



% 
% f1Start_Callback(hObject, eventdata, handles)
% f1Stop_Callback(hObject, eventdata, handles)
% f2Start_Callback(hObject, eventdata, handles)
% f2Stop_Callback(hObject, eventdata, handles)
% 
% time1Start_Callback(hObject, eventdata, handles)
% time1Stop_Callback(hObject, eventdata, handles)
% time2Start_Callback(hObject, eventdata, handles)
% time2Stop_Callback(hObject, eventdata, handles)

%
handles.data.f1Start = f1Start;
handles.data.f1Stop = f1Stop;
handles.data.f2Start = f2Start;
handles.data.f2Stop = f2Stop;

handles.data.time1Start = time1Start;
handles.data.time1Stop = time1Stop;
handles.data.time2Start = time2Start;
handles.data.time2Stop = time2Stop;

%

guidata(hObject, handles);




% --- Executes on selection change in subjectListbox.
function subjectListbox_Callback(hObject, eventdata, handles)
% hObject    handle to subjectListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setWeighting(hObject, eventdata, handles);

% Hints: contents = get(hObject,'String') returns subjectListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subjectListbox


% --- Executes during object creation, after setting all properties.
function subjectListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in condListbox.
function condListbox_Callback(hObject, eventdata, handles)
% hObject    handle to condListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns condListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from condListbox


% --- Executes during object creation, after setting all properties.
function condListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showWave.
function showWave_Callback(hObject, eventdata, handles)
% hObject    handle to showWave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);


xTimes = 0:handles.data.dTms:(handles.data.nT-1)*handles.data.dTms;

for iCond = selectedCond,
    figure;
    data2Plot = squeeze(handles.data.wgtWave(iCond,:,:));
    interactiveTopoWavePlot(data2Plot,xTimes);

    titleTxt(iCond) = uicontrol('Style', 'text','String', contents{iCond} , ...
         'units','normalized','Position',[.37 .95 .3 0.05],'fontsize',14, ...
        'HorizontalAlignment',  'center',  'backgroundcolor',get(gcf,'color') );
    
end


% --- Executes on button press in createAverage.
function createAverage_Callback(hObject, eventdata, handles)
% hObject    handle to createAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in showSpec.
function showSpec_Callback(hObject, eventdata, handles)
% hObject    handle to showSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);

[sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);

freqs = 0:handles.data.dFHz:(handles.data.nFr-1)*handles.data.dFHz;



for iCond = selectedCond,
    figure;   
    data2Plot = squeeze(handles.data.wgtAmp(iCond,:,:));
    interactiveTopoSpecPlot(data2Plot,freqs,sigFreqs)
    
    titleTxt(iCond) = uicontrol('Style', 'text','String', contents{iCond} , ...
    'units','normalized','Position',[.37 .95 .3 0.05], 'fontsize',14, ...
    'HorizontalAlignment',  'center',  'backgroundcolor',get(gcf,'color') );

end

% topoAx = subplot(10,1,1:8);
% topoH = plotOnEgi(squeeze(handles.data.wgtAmp(selectedCond,sigFreqs(1),:)));
% 
% 
%
% 
% 
% %sigFreqs = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
% specAx = subplot(10,1,9:10);
% pdSpecPlot(freqs,data2Plot,sigFreqs);
% hold on;
% noiseEst = squeeze(handles.data.wgtAmpStdE(selectedCond,:,75));
% 
% hE = errorbar(freqs,data2Plot,noiseEst,noiseEst,'k','linestyle','none');
% 
% % adjust error bar width
% hE_c                   = ...
%     get(hE     , 'Children'    );
% errorbarXData          = ...
%     get(hE_c(2), 'XData'       );
% errorbarXData(4:9:end) = ...
%     errorbarXData(1:9:end) - 0.2;
% errorbarXData(7:9:end) = ....
%     errorbarXData(1:9:end) - 0.2;
% errorbarXData(5:9:end) = ...
%     errorbarXData(1:9:end) + 0.2;
% errorbarXData(8:9:end) = ...
%     errorbarXData(1:9:end) + 0.2;
% set(hE_c(2), 'XData', errorbarXData);


% --- Executes on button press in animateTopo.
function animateTopo_Callback(hObject, eventdata, handles)
% hObject    handle to animateTopo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);

xTimes = 0:handles.data.dTms:(handles.data.nT-1)*handles.data.dTms;
figure;
animatedTopoPlot(handles.data.wgtWave(selectedCond,:,:),xTimes,plotNames);        


% Sets the weighting vector.
function setWeighting(hObject, eventdata, handles)
% hObject    handle to showSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Determine the selected averaging.
str = get(handles.weightPopup, 'String');
val = get(handles.weightPopup,'Value');
% Set the subject weighting vector.

subjList = get(handles.subjectListbox,'Value');
allSubjList = get(handles.subjectListbox,'String');


handles.data.nSubjects = length(subjList);
handles.data.Wave = handles.data.allWave(subjList,:,:,:);
handles.data.Spec = handles.data.allSpec(subjList,:,:,:);
handles.data.Cov  = handles.data.allCov(subjList,:,:,:);

handles.data.subjectWeighting = ones(handles.data.nSubjects,1,1,handles.data.nCh);

switch lower(str{val});

    case 'equal' % User selected equal subject weighting.
        handles.data.subjectWeighting = ones(handles.data.nSubjects,1,1,handles.data.nCh)./handles.data.nSubjects;
    case 'noise variance' % User selected weighting by noise level.
        
        for iCh=1:handles.data.nCh,
            %calculate inverse variance for each channel
            invVar = squeeze(handles.data.meanCov(subjList,iCh,iCh)).^-1;
            invVar(isnan(invVar)) = 0;            
            handles.data.subjectWeighting(:,1,1,iCh) = invVar./nansum(invVar);
        end
        
        
        
    case 'snr' % User selected weighting based on SNR.
         handles.data.subjectWeighting = ones(handles.data.nSubjects,1,1,handles.data.nCh)./handles.data.nSubjects;
         
         
         %Check if SNR should be calculated in the frequency or time domain
         if get(handles.freqDomain,'Value') %User chose frequency
             
             [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);
             
             
             for iCh=1:handles.data.nCh,
                 %calculate signal and noise power summed over all conditions
                 %and for the chosen frequencies
                 %silly amount of nested functions proper order: abs, ^2,sum,sum,squeeze
                 noisePow = squeeze(nansum(nansum(abs(handles.data.Spec(:,:,noiseFreqs,iCh)).^2,3),2));
                 sigPow = squeeze(nansum(nansum(abs(handles.data.Spec(:,:,sigFreqs,iCh)).^2,3),2));
                 
                 snrPow = sigPow./noisePow;
                 snrPow(isnan(snrPow)) = 0;
                 
                 handles.data.subjectWeighting(:,1,1,iCh) = snrPow./(nansum(snrPow));
             end
             
         else % User chose time
             
             [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);
             
             
             for iCh=1:handles.data.nCh,
                 %calculate signal and noise power summed over all conditions
                 %and for the chosen time window
                 %silly amount of nested functions proper order: abs, ^2,sum,sum,squeeze
                 noisePow = squeeze(nansum(nansum(abs(handles.data.Wave(:,:,noiseTimes,iCh)).^2,3),2));
                 sigPow = squeeze(nansum(nansum(abs(handles.data.Wave(:,:,sigTimes,iCh)).^2,3),2));
                 
                 snrPow = sigPow./noisePow;
                 snrPow(isnan(snrPow)) = 0;
                 
                 handles.data.subjectWeighting(:,1,1,iCh) = snrPow./(nansum(snrPow));
                 
             end
           
             
         end
         
        
end

guidata(hObject, handles);
calcAverage(hObject, eventdata, handles);

% Sets the the scaling of each subject.
function setScaling(hObject, eventdata, handles)
% hObject    handle to showSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected averaging.
str = get(handles.scalePopup, 'String');
val = get(handles.scalePopup,'Value');
% Set the subject weighting vector.

subjList = get(handles.subjectListbox,'Value');
allSubjList = get(handles.subjectListbox,'String');


handles.data.nSubjects = length(subjList);

handles.data.subjectScaling = ones(handles.data.nSubjects,1,1,1);

switch lower(str{val});

    case 'unity' % User selected equal subject weighting.
        handles.data.subjectScaling = ones(handles.data.nSubjects,1,1,1);
    case 'signal amplitude' % User selected weighting by noise level.
         
         %Check if SNR should be calculated in the frequency or time domain
         if get(handles.freqDomain,'Value') %User chose frequency
             
             [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);
             
             
                 %calculate signal and noise power summed over all conditions
                 %and for the chosen frequencies
                 %silly amount of nested functions proper order: abs, ^2,sum,sum,squeeze
%                  noisePow = squeeze(nansum(nansum(abs(handles.data.Spec(:,:,noiseFreqs,iCh)).^2,3),2));
                 sigPow = squeeze(nansum(nansum(nansum(abs(handles.data.allSpec(:,:,sigFreqs,:)).^2,4),3),2));
%                  snrPow = sigPow./noisePow;
%                  snrPow(isnan(snrPow)) = 0;
                 handles.data.subjectScaling(:,1,1,1) = 1./sqrt(sigPow);
             
         else % User chose time
             
             [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);
             
                 %calculate signal and noise power summed over all conditions
                 %and for the chosen time window
                 %silly amount of nested functions proper order: abs, ^2,sum,sum,squeeze
                 sigPow = squeeze(nansum(nansum(nansum(abs(handles.data.allWave(:,:,sigTimes,:)).^2,4),3),2));
                                  
                 handles.data.subjectScaling(:,1,1,1) = 1./sqrt(sigPow);
                 

           
             
         end
         
        
end
guidata(hObject, handles);
calcAverage(hObject, eventdata, handles);

% calculate cross subject average..
function calcAverage(hObject, eventdata, handles)
% hObject    handle to showSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subjList = get(handles.subjectListbox,'Value');
allSubjList = get(handles.subjectListbox,'String');

%Corrected degrees of freedom
V2 = nansum( handles.data.subjectWeighting.^2);
handles.data.weightedDoF = V2.^-1;

%Scale subjects
scaledWave   = bsxfun(@times,handles.data.Wave, handles.data.subjectScaling(subjList,:,:,:));
scaledAmp    = bsxfun(@times,abs(handles.data.Spec),  handles.data.subjectScaling(subjList,:,:,:));
scaledSpec   = bsxfun(@times,handles.data.Spec, handles.data.subjectScaling(subjList,:,:,:));

%Weight subjects&electrodes
str = get(handles.scalePopup, 'String');
val = get(handles.scalePopup,'Value');


switch lower(str{val});
    case 'unity' % User selected equal subject weighting.
        
        weightedWave = scaledWave;
        weightedAmp  = scaledAmp;
        weightedSpec = scaledSpec;
        
    otherwise
        
        weightedWave = bsxfun(@times,scaledWave, handles.data.subjectWeighting);
        weightedAmp  = bsxfun(@times,scaledAmp,  handles.data.subjectWeighting);
        weightedSpec = bsxfun(@times,scaledSpec, handles.data.subjectWeighting);
end
        

%
handles.data.wgtWave = squeeze(nansum(weightedWave,1));
handles.data.wgtAmp  = squeeze(nansum(weightedAmp,1));
handles.data.wgtSpec = squeeze(nansum(weightedSpec,1));


%If there is only 1 condition, squeezing things makes the cond dim go away
%these lines unsqueeze do the proper dimensions
if ndims( handles.data.wgtWave ) == 2,
    handles.data.wgtWave = shiftdim(handles.data.wgtWave,-1);
    handles.data.wgtAmp  = shiftdim(handles.data.wgtAmp,-1);
    handles.data.wgtSpec = shiftdim(handles.data.wgtSpec,-1);
end


%Weighted sample variance: 1/(1-V2)*sum( w*(x-mu).^2);
%get difference from mean for each subject
weightedWaveDiff = bsxfun(@minus,scaledWave,nansum(weightedWave,1)).^2;

weightedAmpDiff  = bsxfun(@minus,scaledAmp,nansum(weightedAmp,1)).^2;

%weight the difference by the chosen weighting and sum the total
handles.data.wgtWaveVar  = nansum(bsxfun(@times,weightedWaveDiff,handles.data.subjectWeighting),1);
handles.data.wgtAmpVar   = nansum(bsxfun(@times,weightedAmpDiff,handles.data.subjectWeighting),1);

%Correct the variance to be an unbiased estimator (Like dividing by n-1 for
%the unweighted sample variance estimator
handles.data.wgtWaveVar  = (bsxfun(@times,(1./(1-V2)),handles.data.wgtWaveVar));
handles.data.wgtAmpVar   = (bsxfun(@times,(1./(1-V2)),handles.data.wgtAmpVar));

%1/V2 is equal to the corrected degrees of freedom
%The standard error of the mean is thus: sqrt(var)./sqrt(1/V2)
handles.data.wgtWaveStdE  = sqrt(bsxfun(@times,handles.data.wgtWaveVar,V2));
handles.data.wgtAmpStdE  = sqrt(bsxfun(@times,handles.data.wgtAmpVar,V2));

handles.data.wgtWaveStdE = squeeze(handles.data.wgtWaveStdE);
handles.data.wgtWaveVar = squeeze(handles.data.wgtWaveVar);

handles.data.wgtAmpStdE = squeeze(handles.data.wgtAmpStdE);
handles.data.wgtAmpVar = squeeze(handles.data.wgtAmpVar);

if get(handles.freqDomain,'Value') %User chose frequency    
    
    
    for iCond = 1:size(handles.data.wgtSpec,1),
    
    %TODO change weighting of sig and noiseCov to be better.
    [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);
    
    
    unCmplxDat = cat(2,real(handles.data.wgtSpec(iCond,sigFreqs,:)),imag(handles.data.wgtSpec(iCond,sigFreqs,:)));

    handles.data.wgtSigCov(iCond,:,:) = cov(squeeze(unCmplxDat));
    
    unCmplxDat = cat(2,real(handles.data.wgtSpec(iCond,noiseFreqs,:)),imag(handles.data.wgtSpec(iCond,noiseFreqs,:)));   
    handles.data.wgtNoiseCov(iCond,:,:) = cov(squeeze(unCmplxDat));
    end
else
    [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);
    
    for iCond = 1:size(handles.data.wgtWave,1),
        handles.data.wgtSigCov(iCond,:,:) = cov(squeeze(handles.data.wgtWave(iCond,sigTimes,:)));
        handles.data.wgtNoiseCov(iCond,:,:) = cov(squeeze(handles.data.wgtWave(iCond,noiseTimes,:)));
    end
end


    

guidata(hObject, handles);


% Sorts frequency list into signal and noise harmonics.
function [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);


sigFreqs1f1 = (handles.data.i1F1:handles.data.i1F1:handles.data.nFr-1)+1;
sigFreqs1f2 = (handles.data.i1F2:handles.data.i1F2:handles.data.nFr-1)+1;

sigFreqs = [sigFreqs1f1 sigFreqs1f2];

sigFreqsHz = (sigFreqs-1)*handles.data.dFHz;

%Find signal frequency indices that are within the chosen window
f1Start  = handles.data.f1Start;
f1Stop   = handles.data.f1Stop;
f2Start  = handles.data.f2Start;
f2Stop   = handles.data.f2Stop;

f1Window = sigFreqs(sigFreqsHz>=f1Start & sigFreqsHz<=f1Stop);
f2Window = sigFreqs(sigFreqsHz>=f2Start & sigFreqsHz<=f2Stop);

sigFreqs = [f1Window f2Window];

noiseP1 = sigFreqs+1;
noiseM1 = sigFreqs-1;

%Combine +/- noise bins
noiseAll = unique([noiseP1 noiseM1]);

%cut out noise <1 and > maxFr
noiseFreqs = noiseAll( noiseAll>0 & noiseAll<=handles.data.nFr);


% Sorts frequency list into signal and noise harmonics.
function [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);

%Find signal frequency indices that are within the chosen window
time1Start  = handles.data.time1Start;
time1Stop   = handles.data.time1Stop;

time2Start  = handles.data.time2Start;
time2Stop   = handles.data.time2Stop;

%Convert time in ms to index into data
[tmp time1StartIdx] = min(abs(handles.data.xTms-time1Start));
[tmp time1StopIdx]  = min(abs(handles.data.xTms-time1Stop));

[tmp time2StartIdx] = min(abs(handles.data.xTms-time2Start));
[tmp time2StopIdx] = min(abs(handles.data.xTms-time2Stop));

time1Window = time1StartIdx:time1StopIdx;
time2Window = time2StartIdx:time2StopIdx;

%Combine signal window, removing overlapping indices
sigTimes = [time1Window time2Window];
sigTimes = unique(sigTimes);

%Noise window is everything that is not in the signal window
noiseTimes = setdiff(1:handles.data.nT,sigTimes);

%cut out any bad indices i.e. <1 and > maxTms
sigTimes = sigTimes( sigTimes > 0 & sigTimes<=handles.data.nT);
noiseTimes = noiseTimes( noiseTimes > 0 & noiseTimes<=handles.data.nT);



% --- Executes on button press in pushData.
function pushData_Callback(hObject, eventdata, handles)
% hObject    handle to pushData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin( 'base', 'mrcData', handles.data );


% --- Executes on selection change in weightPopup.
function weightPopup_Callback(hObject, eventdata, handles)
% hObject    handle to weightPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns weightPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from weightPopup

setWeighting(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function weightPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weightPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in scalePopup.
function scalePopup_Callback(hObject, eventdata, handles)
% hObject    handle to scalePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns scalePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scalePopup
setScaling(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function scalePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function f1Start_Callback(hObject, eventdata, handles)
% hObject    handle to f1Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f1Start as text
%        str2double(get(hObject,'String')) returns contents of f1Start as a double

handles.data.f1Start = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function f1Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f1Stop_Callback(hObject, eventdata, handles)
% hObject    handle to f1Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f1Stop as text
%        str2double(get(hObject,'String')) returns contents of f1Stop as a double
handles.data.f1Stop = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function f1Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function f2Start_Callback(hObject, eventdata, handles)
% hObject    handle to f2Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f2Start as text
%        str2double(get(hObject,'String')) returns contents of f2Start as a double

handles.data.f2Stop = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function f2Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function f2Stop_Callback(hObject, eventdata, handles)
% hObject    handle to f2Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f2Stop as text
%        str2double(get(hObject,'String')) returns contents of f2Stop as a double
handles.data.f2Stop = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function f2Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time1Start_Callback(hObject, eventdata, handles)
% hObject    handle to time1Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1Start as text
%        str2double(get(hObject,'String')) returns contents of time1Start as a double

handles.data.time1Start = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function time1Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time1Stop_Callback(hObject, eventdata, handles)
% hObject    handle to time1Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1Stop as text
%        str2double(get(hObject,'String')) returns contents of time1Stop as a double

handles.data.time1Stop = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function time1Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time2Start_Callback(hObject, eventdata, handles)
% hObject    handle to time2Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2Start as text
%        str2double(get(hObject,'String')) returns contents of time2Start as a double
handles.data.time2Start = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function time2Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time2Stop_Callback(hObject, eventdata, handles)
% hObject    handle to time2Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2Stop as text
%        str2double(get(hObject,'String')) returns contents of time2Stop as a double

handles.data.time2Stop = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function time2Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in freqDomain.
function freqDomain_Callback(hObject, eventdata, handles)
% hObject    handle to freqDomain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of freqDomain


% --- Executes on button press in timeDomain.
function timeDomain_Callback(hObject, eventdata, handles)
% hObject    handle to timeDomain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeDomain


% --- Executes on button press in doBeamform.
function doBeamform_Callback(hObject, eventdata, handles)
% hObject    handle to doBeamform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
calcAverage(hObject, eventdata, handles);

handles = guidata(hObject);

selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);


if ~isfield(handles.data,'Afree') || isempty(handles.data.Afree)
    anatDir = getpref('mrCurrent','AnatomyFolder');
    
    fwd = load(fullfile(anatDir,'mni0001','fwdFiles','mni0001-fwd.mat'));
    
    handles.data.Afree = fwd.Afree;
    handles.data.A = fwd.A;
end

if length(selectedCond) ==1

    Cnoise = squeeze(handles.data.wgtNoiseCov(selectedCond,:,:));

    Csig = squeeze(handles.data.wgtSigCov(selectedCond,:,:));

    lambda = .01*mean(diag(Cnoise))*eye(size(Cnoise));

    [tSig] = lcmvBeamform(handles.data.Afree,Csig + lambda);
    [tNoise] = lcmvBeamform(handles.data.Afree,Cnoise + lambda);
    
    ctxFig = figure;
    ctxH = drawAnatomySurface('mni0001','cortex','facealpha',1);
    
    set(ctxH,'facevertexCdata',sqrt(tSig./tNoise),'facecolor','interp')
    handles.data.beamformResults.tSig = tSig;
    handles.data.beamformResults.tNoise = tNoise;
    
    title(['BEAMFORMER RESULTS FOR: ' plotNames{1} ' Versus Noise'])
    
elseif length(selectedCond) == 2
    
    Ccnd1 = squeeze(handles.data.wgtSigCov(selectedCond(1),:,:));

    Ccnd2 = squeeze(handles.data.wgtSigCov(selectedCond(2),:,:));

    Cnoise = squeeze(mean(handles.data.wgtNoiseCov(selectedCond,:,:),1));
    
    lambda = .01*mean(diag(Cnoise))*eye(size(Cnoise));

    [tCnd1] = lcmvBeamform(handles.data.Afree,Ccnd1 + lambda);
    [tCnd2] = lcmvBeamform(handles.data.Afree,Ccnd2 + lambda);
    
    ctxFig = figure;
    ctxH = drawAnatomySurface('mni0001','cortex','facealpha',1);
    
    set(ctxH,'facevertexCdata',sqrt(tCnd1./tCnd2),'facecolor','interp')
    
    handles.data.beamformResults.tCnd1 = tCnd1;
    handles.data.beamformResults.tCnd2 = tCnd2;
    
    
    title(['BEAMFORMER RESULTS FOR: ' plotNames{1} ' Versus ' plotNames{2}])
    
    
else
    disp('ACTION UNDEFINED FOR MORE THAN 2 CONDITIONS, CHOOSE LESS')
end



guidata(hObject, handles);


% --- Executes on button press in doMinNormGcv.
function doMinNormGcv_Callback(hObject, eventdata, handles)
% hObject    handle to doMinNormGcv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);

if length(selectedCond)>1
    disp('CHOOSE ONLY 1 CONDITION!');
    return;
end


if ~isfield(handles.data,'A') || isempty(handles.data.A)
    
    anatDir = getpref('mrCurrent','AnatomyFolder');
    fwd = load(fullfile(anatDir,'mni0001','fwdFiles','mni0001-fwd.mat'));   
    handles.data.Afree = fwd.Afree;
    handles.data.A = fwd.A;
end

% Decomposition of the forward matrix in singular values
[u,s,v] = csvd(handles.data.A);

%Check if SNR should be calculated in the frequency or time domain
if get(handles.freqDomain,'Value') %User chose frequency
    
    [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);
    
%     noiseSpec = cat(2,real(handles.data.wgtSpec(selectedCond,noiseFreqs,:)), ...
%         imag(handles.data.wgtSpec(selectedCond,noiseFreqs,:)));
    
    
    sigSpec = cat(2,real(handles.data.wgtSpec(selectedCond,sigFreqs,:)), ...
        imag(handles.data.wgtSpec(selectedCond,sigFreqs,:)));
    
    sigData = squeeze(sigSpec)';
    
            
else % User chose time
    
    [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);
    
    sigData = squeeze(handles.data.wgtWave(selectedCond,sigTimes,:));    
    
end

lambda = gcv(u,s,sigData,'Tikh')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tikhonov regularized inverse matrix
reg_s = diag( s ./ (s.^2 + lambda^2 ));
sol = v * reg_s * u';


% ctxFig = figure;
% ctxH = drawAnatomySurface('mni0001','cortex','facealpha',1);

% set(ctxH,'facevertexCdata',sol*,'facecolor','interp')
handles.data.sol = sol;
guidata(hObject, handles);

figure
data = squeeze(handles.data.wgtWave(selectedCond,:,:));  
interactiveCortexWavePlot(data,sol,'mni0001',handles.data.xTms)



% if get(handles.freqDomain,'Value') %User chose frequency
%  
% else % User chose time
%     
% 
%     xTimes = 0:handles.data.dTms:(handles.data.nT-1)*handles.data.dTms;
% 
%     figure;
%     
%     data2Plot = squeeze(handles.data.wgtWave(selectedCond,:,:));
%     
%     interactiveCortexWave(data2Plot,sol,xTimes);
%     
%     titleTxt(iCond) = uicontrol('Style', 'text','String', contents{iCond} , ...
%          'units','normalized','Position',[.37 .95 .3 0.05],'fontsize',14, ...
%         'HorizontalAlignment',  'center',  'backgroundcolor',get(gcf,'color') );
%     
%     
% end
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in doVolMinNormGcv.
function doVolMinNormGcv_Callback(hObject, eventdata, handles)
% hObject    handle to doVolMinNormGcv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCond = get(handles.condListbox,'Value');
contents = get(handles.condListbox,'String');
plotNames = contents(selectedCond);
str = get(handles.headmodelChoices, 'String');
val = get(handles.headmodelChoices,'Value');
modelName = str{val};

if length(selectedCond)>1
    disp('CHOOSE ONLY 1 CONDITION!');
    return;
end


if ~isfield(handles.data,'Afree') || isempty(handles.data.Afree)
    
    anatDir = getpref('mrCurrent','AnatomyFolder');

    fwd = load(fullfile(anatDir,modelName,'fwdFiles',[modelName '-vol-sph-fwd.mat']));   
    handles.data.Afree = fwd.Afree;
end


if ~isfield(handles.data,'interpMtx') || isempty(handles.data.interpMtx)
    anatDir = getpref('mrCurrent','AnatomyFolder');

    interp = load(fullfile(anatDir,modelName,'fwdFiles',[modelName '-src2mri-interp.mat']));   
    handles.data.interpMtx = interp.interpMtx;
end


% Decomposition of the forward matrix in singular values
[u,s,v] = svd(handles.data.Afree,'econ');
s = diag(s);

%Check if SNR should be calculated in the frequency or time domain
if get(handles.freqDomain,'Value') %User chose frequency
    
    [sigFreqs noiseFreqs] = getDrivenFrequencies(hObject, eventdata, handles);
    
%     noiseSpec = cat(2,real(handles.data.wgtSpec(selectedCond,noiseFreqs,:)), ...
%         imag(handles.data.wgtSpec(selectedCond,noiseFreqs,:)));
    
    
    sigSpec = cat(2,real(handles.data.wgtSpec(selectedCond,sigFreqs,:)), ...
        imag(handles.data.wgtSpec(selectedCond,sigFreqs,:)));
    
    sigData = squeeze(sigSpec)';
    
    funcVol.dataSeries.sigFreqs = sigFreqs;
    funcVol.dataSeries.xFrqs = handles.data.xFrqs;
    funcVol.dataSeries.dataType = 'spec';
    thisData = squeeze(handles.data.wgtSpec(selectedCond,:,:)); 
    funcVol.dataSeries.spec = thisData;
    funcVol.dataSeries.allCondSpec = handles.data.wgtSpec;
else % User chose time
    
    [sigTimes noiseTimes] = getSignalWindow(hObject, eventdata, handles);
    sigData = squeeze(handles.data.wgtWave(selectedCond,sigTimes,:));
    sigData = shiftdim(sigData,2);
    sigData = sigData(:,:)';
    
    funcVol.dataSeries.xTms = handles.data.xTms;
    funcVol.dataSeries.dataType = 'wave'
    thisData = squeeze(handles.data.wgtWave(selectedCond,:,:)); 
    funcVol.dataSeries.wave = thisData;
    funcVol.dataSeries.allCondSpec = handles.data.wgtSpec;

end

% CHANGE THIS. SHOULD CALC GCV OVER ALL CONDITIONS
lambda = gcv(u,s,sigData,'Tikh')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tikhonov regularized inverse matrix
reg_s = diag( s ./ (s.^2 + lambda^2 ));
funcVol.inverse = v * reg_s * u';
funcVol.interpMtx = handles.data.interpMtx;
funcVol.initDepthWeight = calcDepthWeight(handles.data.Afree,1,inf);


% ctxFig = figure;
% ctxH = drawAnatomySurface('mni0001','cortex','facealpha',1);

% set(ctxH,'facevertexCdata',sol*,'facecolor','interp')
guidata(hObject, handles);


argList = {'subjId',modelName};
anatVol = setupVolumeSliceObject(argList{:});
[xS yS zS] = size(anatVol.volData);
%copy anatatomy volume to functional volume, removing fields we don't need

funcVol.volName = 'mneInverse';



sourceData = combineTriplet(abs(funcVol.inverse*thisData(2,:)'));
size(sourceData)
funcVol.volData = reshape(funcVol.interpMtx*sourceData,xS,yS,zS);

sliceViewer(anatVol,funcVol)

% --- Executes on selection change in headmodelChoices.
function headmodelChoices_Callback(hObject, eventdata, handles)
% hObject    handle to headmodelChoices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns headmodelChoices contents as cell array
%        contents{get(hObject,'Value')} returns selected item from headmodelChoices

contents = get(hObject,'String');
modelChoice = contents{get(hObject,'Value')};

switch modelChoice
    
    case 'mni0001'
        modelName = 'mni0001'
    case 'nih1511v2'
        modelName = 'nih1511v2'
        
end

anatDir = getpref('mrCurrent','AnatomyFolder');

fwd = load(fullfile(anatDir,modelName,'fwdFiles',[modelName '-vol-sph-fwd.mat']));
handles.data.Afree = fwd.Afree;
    
interp = load(fullfile(anatDir,modelName,'fwdFiles',[modelName '-src2mri-interp.mat']));
handles.data.interpMtx = interp.interpMtx;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function headmodelChoices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to headmodelChoices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
