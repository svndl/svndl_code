% set variable subjNum to run ViewFlatROIs.m
% e.g.
% >> clx, subjNum=48; ViewFlatROIs

% or to save jpg to /raid/MRI/data/RETINOTOPY/jpegs/
% >> clx, writeOut=true; subjNum=48; ViewFlatROIs

% This should run as a function?

% v1 only wedge scans
% v2 wedge+ring
% v3 uses FindFMRIdata + does either Retinotopy or Localizers

if ~exist('subjNum','var')
	help(mfilename)
	return
end

Sessions = {'Retinotopy','Localizers'};
Session = Sessions{1};								% Choose what session you want here.

pix = 500;					% pixel width,height
gap = 10;					% pixel border
m = 12;						% markersize

subjID = sprintf('skeri%04d',subjNum);

switch Session
case Sessions{1}
	co = 0.15;					% coherence threshold
	useRetCmaps = false;		% if true uses left/right wedge & expanding ring colormaps, if ~true uses hsv colormap for everything
	projDir = fullfile(SKERIanatDir,'..','data','RETINOTOPY');
	jpgTag = '_retROIs.jpg';
	[subjDir,dataType,j1] = FindFMRIdata(subjNum,'Wedge');
	[subjDir,dataType,j2] = FindFMRIdata(subjNum,'Ring');
case Sessions{2}
	co = 0.20;
	useRetCmaps = false;		% always false for Localizers
	projDir = fullfile(SKERIanatDir,'..','data','LOCMT_fMRI');
	jpgTag = '_localizerROIs.jpg';
	[subjDir,dataType,j1] = FindFMRIdata(subjNum,'LOC');
	[subjDir,dataType,j2] = FindFMRIdata(subjNum,'MT');
end

foundScans = ~isnan([j1 j2]) & [j1 j2]~=0;
if ~any(foundScans)
	error('No data found.')
end

% note: loadROI won't freak out if you ask for an ROI that doesn't exist
% on Linux these are case sensitive, not on PC
ROIlist = {'V1-L','V2D-L','V2V-L','V3D-L','V3V-L','V3A-L','V4-L','V1-R','V2D-R','V2V-R','V3D-R','V3V-R','V3A-R','V4-R','LOC-L','MT-L','LOC-R','MT-R'};
if isunix
	ROIlist = unique([ ROIlist, strrep(strrep(ROIlist,'D','d'),'V-','v-') ]);
end



FlatDirs = dir(fullfile(subjDir,'Flat*'));
FlatDirs = FlatDirs([FlatDirs.isdir]);
for i = 1:numel(FlatDirs)
	FlatDirs(i).hasROIs = isdir(fullfile(subjDir,FlatDirs(i).name,'ROIs')) && ~isempty(dir(fullfile(subjDir,FlatDirs(i).name,'ROIs','*.mat')));
end
FlatDirs = FlatDirs([FlatDirs.hasROIs]);
if isempty(FlatDirs)
	error('No Flat* directories w/ ROIs in %s',subjDir)
elseif numel(FlatDirs)>1
	i = menu('Choose unfold:',{FlatDirs.name});
	if i == 0
		return
	end
	FlatDirs = FlatDirs(i);
end

DT = load(fullfile(subjDir,'mrSESSION.mat'),'dataTYPES');
iDT = find(strcmp({DT.dataTYPES.name},dataType));
clear DT

disp('------------------------')

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
FLAT{selectedFLAT} = selectDataType( FLAT{selectedFLAT}, iDT );
FLAT{selectedFLAT} = setDisplayMode( FLAT{selectedFLAT}, 'ph' );
if ~useRetCmaps
	FLAT{selectedFLAT}.ui.phMode = setColormap( FLAT{selectedFLAT}.ui.phMode, 'hsvCmap' );
	cmap = hsvCmap( FLAT{selectedFLAT}.ui.phMode.numGrays, FLAT{selectedFLAT}.ui.phMode.numColors );
end

if sum(foundScans) == 1
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

if isfield(FLAT{selectedFLAT},'rotateImageDegrees')
	imgRot = -FLAT{selectedFLAT}.rotateImageDegrees;
else
	imgRot = [0 0];
end

% LEFT
if foundScans(1)
	imgFlip = strcmp(get(FLAT{selectedFLAT}.ui.flipLHMenu,'Checked'),'on');
	if any(RH)
		FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(RH,1,'last') );
	end
	selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 1 );
	% set Wedge or LOC scan
	FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j1 );
	if useRetCmaps
		FLAT{selectedFLAT} = cmapImportModeInformation( FLAT{selectedFLAT}, 'phMode', 'WedgeMapLeft.mat' );
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
		cmap = get(FLAT{selectedFLAT}.ui.figNum,'colormap');
	else
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
	end
	img = FLAT{selectedFLAT}.ui.image;
	if imgRot(1) ~= 0
		imgSize = size(img);
		img = imrotate(img,imgRot(1));
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	if imgFlip
		img = flipdim(img,2);
	end
	axes(axL(1))
	image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
end
if foundScans(2)
	% set Ring or MT scan
	FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j2 );
	if useRetCmaps
		FLAT{selectedFLAT} = cmapImportModeInformation(FLAT{selectedFLAT}, 'phMode', 'RingMapE.mat');
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
		cmap = get(FLAT{selectedFLAT}.ui.figNum,'colormap');
	else
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
	end
	img = FLAT{selectedFLAT}.ui.image;
	if imgRot(1) ~= 0
		imgSize = size(img);
		img = imrotate(img,imgRot(1));
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	if imgFlip
		img = flipdim(img,2);
	end
	axes(axL(1+foundScans(1)))
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
imgFlip = strcmp(get(FLAT{selectedFLAT}.ui.flipRHMenu,'Checked'),'on');
if ~all(RH)
	FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(~RH,1,'last') );
end
selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 2 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
if foundScans(2)
	% still on Ring or MT
	img = FLAT{selectedFLAT}.ui.image;
	if imgRot(2) ~= 0
		imgSize = size(img);
		img = imrotate(img,imgRot(2));
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	if imgFlip
		img = flipdim(img,2);
	end
	axes(axR(1+foundScans(1)))
	image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
end
if foundScans(1)
	% set Wedge or LOC scan
	FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j1 );
	if useRetCmaps
		FLAT{selectedFLAT} = cmapImportModeInformation( FLAT{selectedFLAT}, 'phMode', 'WedgeMapRight.mat' );
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
		cmap = get(FLAT{selectedFLAT}.ui.figNum,'colormap');
	else
		FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );
	end
	img = FLAT{selectedFLAT}.ui.image;
	if imgRot(2) ~= 0
		imgSize = size(img);
		img = imrotate(img,imgRot(2));
		img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
	end
	if imgFlip
		img = flipdim(img,2);
	end
	axes(axR(1))
	image(reshape(cmap(img(:)+1,:),[FLAT{selectedFLAT}.ui.imSize 3]))
end
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
	fname = fullfile(projDir,'jpegs',[subjID,jpgTag]);
	fprintf('writing %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)
end
fprintf('done\n')

