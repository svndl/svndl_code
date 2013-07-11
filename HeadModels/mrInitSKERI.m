function mrInitSKERI(subj,blockCycles)
% Create a VistaSoft project from NIfTI *.nii.gz files
% GUI prompts for project folder, 3D inplane volume, & 4D functional files
%
% mrInitSKERI(subject,defaultBlockCycles)
% e.g. mrInitSKERI('skeri9999',10)

% to do:
% cleanup dataTYPES.scanParams.PfileName
% set MotionComp Ref frame & scan?

if ~exist('subj','var') || isempty(subj)
	subj = '';
end
if ~exist('blockCycles','var') || isempty(blockCycles)
	blockCycles = 1;
end

projDir = uigetdir(pwd,'Choose base directory for new VistaSoft project');
if isnumeric(projDir)
	return
end
if exist(fullfile(projDir,'mrSESSION.mat'),'file')
% 	if ~strcmp(questdlg('mrSESSION.mat exists.  Replace?','init mrVista','No','Yes','No'),'Yes')
% 		disp('user quit')
% 		return
% 	end
	error('mrSESSION.mat exists.')
end
disp(projDir)

projInfo = inputdlg({'subject','sessionCode','description','comment','#cycles'},['INFO FOR ',projDir],1,{subj,'','','',num2str(blockCycles)});
if isempty(projInfo)
	return
end
[subj,sess,desc,comm,ncyc]=deal(projInfo{:});
blockCycles = str2double(ncyc);

% [anatFile,anatDir] = uigetfile('*.nii.gz','Choose T1 Inplane Volume',fullfile(pwd,'..','MNI152_T1_3mm_CropXY.nii.gz'));
[anatFile,anatDir] = uigetfile(fullfile(projDir,'*.nii.gz'),'Choose T1 Inplane Volume');
if isnumeric(anatDir)
	return
end

[fmriFile,fmriDir] = uigetfile(fullfile(projDir,'*.nii.gz'),'Choose 4-D fMRI Volume(s)','MultiSelect','on');
if isnumeric(fmriDir)
	return
end
fmriFile = sort(fmriFile)';	% column
annot = strtok(fmriFile,'.');
fmriFile = cellfun( @(x) fullfile(fmriDir,x) ,fmriFile,'UniformOutput',false);

if ispref('VISTA','defaultAnatomyPath')
	vAnatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),'anatomy');
elseif ispc
	vAnatDir = 'X:\anatomy';
else
	vAnatDir = '/raid/MRI/anatomy';
end


%% ----------------------------------------

P = mrInitDefaultParams;
P.sessionDir = projDir;
P.sessionCode = sess;
P.doDescription   = 1;
P.doCrop          = 0;
P.doAnalParams    = 0;
P.doPreprocessing = 0;
P.doSkipFrames    = 0;

% [P,OK] = mrInitGUI_main(P);
P.inplane = [anatDir,anatFile];
P.functionals = fmriFile;
if ~isempty(subj)
	P.vAnatomy = fullfile(vAnatDir,subj,'vAnatomy.dat');
end

% P = mrInitGUI_description(P);
P.subject = subj;
P.description = desc;
P.comments = comm;
P.annotations = annot;

% P = mrInitGUI_skipFrames(P);
% P.keepFrames = [ 0 -1; 0 -1 ];		% skip #keep (-1=all), or leave empty??

% P = mrInitGUI_crop(P);
% P.crop = [];		% 2x2 matrix

% P = mrInitGUI_analParams(P);
% P.parfile = {};
% P.coParams = {};
% P.glmParams = {};
% P.scanGroups = {};

% P = mrInitGUI_preprocessing(P);
P.applyGlm = 0;
P.applyCorAnal = [];
P.motionComp = 0;
P.sliceTimingCorrection = 0;
P.motionCompRefScan = 1;
P.motionCompRefFrame = 1;

disp(P)

OK = mrInit2(P)

S = load(fullfile(projDir,'mrSESSION.mat'));
nScan = numel(S.mrSESSION.functionals);

S.dataTYPES.scanParams = struct(...
	'annotation',P.annotations',...
	'nFrames',{S.mrSESSION.functionals.nFrames},...
	'framePeriod',{S.mrSESSION.functionals.framePeriod},...
	'slices',{S.mrSESSION.functionals.slices},...
	'cropSize',{S.mrSESSION.functionals.cropSize},...
	'PfileName',{S.mrSESSION.functionals.PfileName},...
	'parfile','',...
	'scanGroup','');
S.dataTYPES.blockedAnalysisParams = struct(...
	'blockedAnalysis',num2cell(ones(1,nScan)),...
	'detrend',1,...
	'inhomoCorrect',1,...
	'temporalNormalization',0,...
	'nCycles',blockCycles);
S.dataTYPES.eventAnalysisParams = repmat(er_defaultParams,1,nScan);
S.vANATOMYPATH = P.vAnatomy;

save(fullfile(projDir,'mrSESSION.mat'),'-struct','S')
disp('updated dataTYPES')
