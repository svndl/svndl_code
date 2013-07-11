% set variable subjID to run ViewFlatROIs_LOCMT.m
% e.g.
% >> clx, subjID='skeri0048'; ViewFlatROIs_LOCMT

% or to save jpg to /raid/MRI/data/LOCMT_fMRI/jpegs/
% >> clx, writeOut=true; subjID='skeri0048'; ViewFlatROIs_LOCMT

error('FIX THIS FOR LR FLIPS! (see ViewFlatROIs2.m)') % & rotations too

clx
writeOut = ~false;
subjID ='skeri0062';

if ~exist('subjID','var')
	help('ViewFlatROIs_LOCMT.m')
	return
end

co = 0.20;					% coherence threshold
pix = 500;					% pixel width,height
gap = 10;					% pixel border
m = 12;						% markersize


% note: loadROI won't freak out if you ask for an ROI that doesn't exist
% on Linux these are case sensitive, not on PC
ROIlist = {'V1-L','V2D-L','V2V-L','V3D-L','V3V-L','V3A-L','V4-L','V1-R','V2D-R','V2V-R','V3D-R','V3V-R','V3A-R','V4-R','MT-L','MT-R','LOC-L','LOC-R'};
if isunix
	ROIlist = unique([ ROIlist, strrep(strrep(ROIlist,'D','d'),'V-','v-') ]);
end


if ispc
	projDir = 'X:\data\LOCMT_fMRI';
else
	projDir = '/raid/MRI/data/LOCMT_fMRI';
end
sessionID = dir(fullfile(projDir,[subjID,'*']));
if numel(sessionID)==1
	sessionID = sessionID(1).name;
else
	i = menu('Choose session:',{sessionID.name});
	if i == 0
		return
	end
	sessionID = sessionID(i).name;
end
subjDir = fullfile(projDir,sessionID);
if ~exist(subjDir,'dir')
	error('%s does not exist',subjDir)
end
fileName = fullfile(subjDir,'mrSESSION.mat');
if ~exist(fileName,'file')
% 	error('no mrSESSION.mat in %s',subjDir)
	[fileName,subjDir] = uigetfile(fullfile(subjDir,'*.mat'),['Locate ',subjID,' mrSESSION'],'mrSESSION.mat');
	if isnumeric(fileName)
		return
	end
	fileName = strcat(subjDir,fileName);
end

FlatDirs = dir(fullfile(subjDir,'Flat*'));
FlatDirs = FlatDirs([FlatDirs.isdir]);
% for i = 1:numel(FlatDirs)
% 	FlatDirs(i).hasROIs = isdir(fullfile(subjDir,FlatDirs(i).name,'ROIs')) && ~isempty(dir(fullfile(subjDir,FlatDirs(i).name,'ROIs','MT*.mat')));
% end
% FlatDirs = FlatDirs([FlatDirs.hasROIs]);
if isempty(FlatDirs)
	error('No Flat* directories in %s',subjDir)
elseif numel(FlatDirs)>1
	i = menu('Choose unfold:',{FlatDirs.name});
	if i == 0
		return
	end
	FlatDirs = FlatDirs(i);
end

DT = load(fileName,'dataTYPES');
disp('------------------------')
for i = 1:numel(DT.dataTYPES)
	DT.dataTYPES(i).hasCorAnal = isdir(fullfile(subjDir,FlatDirs.name,DT.dataTYPES(i).name)) && exist(fullfile(subjDir,FlatDirs.name,DT.dataTYPES(i).name,'corAnal.mat'),'file');
	if DT.dataTYPES(i).hasCorAnal
		disp(DT.dataTYPES(i).name)
		if isempty(DT.dataTYPES(i).scanParams)
			disp({'!!!empty!!!'})
		else
			disp({DT.dataTYPES(i).scanParams.annotation}')
		end
	end
end
k = [DT.dataTYPES.hasCorAnal];
if ~any(k)
	error('No corAnals found in %s.',FlatDirs.name)
end
if sum(k)==1
	i = find(k);
else
	i = menu('Choose dataTYPE:',{DT.dataTYPES(k).name});
	if i == 0
		return
	end
	k = find(k);
	i = k(i);
end
k = ~cellfun(@isempty,regexpi({DT.dataTYPES(i).scanParams.annotation},'.*loc'));
autoLOC = sum(k) == 1;
if autoLOC
	j1 = find(k);
else
	j1 = menu('Choose LOC Scan:',{DT.dataTYPES(i).scanParams.annotation});
	if j1 == 0
		return
	end
end
switch numel(DT.dataTYPES(i).scanParams)
case 1
	j2 = 0;
case 2
	j2 = 3-j1;
otherwise
	k = ~cellfun(@isempty,regexpi({DT.dataTYPES(i).scanParams.annotation},'.*mt'));
	if sum(k)==1 && autoLOC
		j2 = find(k);
	else
		j2 = menu('Choose MT Scan:',{DT.dataTYPES(i).scanParams.annotation});
	end
end
clear DT

cd(subjDir)
mrVista('f',FlatDirs.name)

% resize flat window
set( FLAT{selectedFLAT}.ui.figNum, 'position', [0.35 0.25 0.55 0.55] )

% fix anatomy
a = load(fullfile(subjDir,FLAT{selectedFLAT}.subdir,'anat.mat'));
a.anat = a.anat - min(a.anat(:));
a.anat = a.anat / max(a.anat(:));
FLAT{selectedFLAT}.anat = a.anat;
clear a

% set sliders
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.anatMin, 0 ); 
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.anatMax, 1 );
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.cothresh, co); 
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.phWinMin, 0); 
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.phWinMax, 2*pi);
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.mapWinMin, get(FLAT{selectedFLAT}.ui.mapWinMin.sliderHandle,'min') );
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.mapWinMax, get(FLAT{selectedFLAT}.ui.mapWinMax.sliderHandle,'max') );
setSlider( FLAT{selectedFLAT}, FLAT{selectedFLAT}.ui.scan, j1 );


% set ROI options & load
FLAT{selectedFLAT} = roiSetOptions( FLAT{selectedFLAT}, struct('selRoiColor',[1 1 1],'showRois',3,'drawFormat',3) );
FLAT{selectedFLAT} = loadROI( FLAT{selectedFLAT}, ROIlist, [], [], false, true );
RH = cellfun(@isempty,strfind(get(FLAT{1}.ui.ROI.popupHandle,'string'),'-L')) & cellfun(@isempty,strfind(get(FLAT{1}.ui.ROI.popupHandle,'string'),'-l'));
% set dataTYPE & load phase map
FLAT{selectedFLAT} = selectDataType( FLAT{selectedFLAT}, i );
FLAT{selectedFLAT} = setDisplayMode( FLAT{selectedFLAT}, 'ph' );
FLAT{selectedFLAT}.ui.phMode = setColormap( FLAT{selectedFLAT}.ui.phMode, 'hsvCmap' );
cmap = hsvCmap( FLAT{selectedFLAT}.ui.phMode.numGrays, FLAT{selectedFLAT}.ui.phMode.numColors );

if j2 == 0
	fig = figure('units','pixels','position',[200 500 2*pix+3*gap pix+2*gap],'color','k','name',subjID,'menubar','none');
	ax = [ ...
		axes('units','pixels','position',[      gap       gap pix pix])...
		axes('units','pixels','position',[pix+2*gap       gap pix pix])...
		];
	axL = ax(1);
	axR = ax(2);
else
	fig = figure('units','pixels','position',[200 100 2*pix+3*gap 2*pix+3*gap],'color','k','name',subjID,'menubar','none');
	ax = [ ...
		axes('units','pixels','position',[      gap pix+2*gap pix pix])...
		axes('units','pixels','position',[pix+2*gap pix+2*gap pix pix])...
		axes('units','pixels','position',[      gap       gap pix pix])...
		axes('units','pixels','position',[pix+2*gap       gap pix pix])...
		];
	axL = ax([1 3]);
	axR = ax([2 4]);
end

% LEFT
if any(RH)
	FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(RH,1,'first') );
end
selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 1 );
% set LOC scan
FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j1 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
img = FLAT{selectedFLAT}.ui.image;
imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
if imgRot ~= 0
	imgSize = size(img);
	img = imrotate(img,-imgRot*180/pi);
	img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
end
axes(ax(1))
image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
if j2 ~= 0
	% set MT scan
	FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j2 );
	FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
	img = FLAT{selectedFLAT}.ui.image;
	imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
	if imgRot ~= 0
		imgSize = size(img);
		img = imrotate(img,-imgRot*180/pi);
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	axes(ax(3))
	image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
end
% add ROIs
L = findobj(FLAT{selectedFLAT}.ui.mainAxisHandle,'type','line','visible','on');
for i = 1:numel(L)
	for a = axL
		axes(a)
		line(get(L(i),'xdata'),get(L(i),'ydata'),'color',get(L(i),'color'),'linestyle','none','linewidth',1,'marker','.','markersize',m)
	end
end


% RIGHT
if ~all(RH)
	FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(~RH,1,'first') );
end
selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 2 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
if j2 ~= 0
	% still on MT
	img = FLAT{selectedFLAT}.ui.image;
	imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
	if imgRot ~= 0
		imgSize = size(img);
		img = imrotate(img,-imgRot*180/pi);
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	axes(ax(4))
	image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
end
% set LOC scan
FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j1 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
img = FLAT{selectedFLAT}.ui.image;
imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
if imgRot ~= 0
	imgSize = size(img);
	img = imrotate(img,-imgRot*180/pi);
	img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
end
axes(ax(2))
image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
% add ROIs
L = findobj(FLAT{selectedFLAT}.ui.mainAxisHandle,'type','line','visible','on');
for i = 1:numel(L)
	for a = axR
		axes(a)
		line(get(L(i),'xdata'),get(L(i),'ydata'),'color',get(L(i),'color'),'linestyle','none','linewidth',1,'marker','.','markersize',m)
	end
end

set(fig,'colormap',get(FLAT{selectedFLAT}.ui.figNum,'colormap'))
set(ax,'visible','off')

if exist('writeOut','var') && writeOut
	F = getframe(fig);
	fname = fullfile(projDir,'jpegs',[subjID,'_localizerROIs.jpg']);
	fprintf('writing %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)
end
fprintf('done\n')

