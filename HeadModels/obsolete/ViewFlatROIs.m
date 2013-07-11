% set variable subjNum to run ViewFlatROIs.m
% e.g.
% >> clx, subjNum=48; ViewFlatROIs

% or to save jpg to /raid/MRI/data/RETINOTOPY/jpegs/
% >> clx, writeOut=true; subjNum=48; ViewFlatROIs

if ~exist('subjNum','var')
	help('ViewFlatROIs.m')
	return
end

co = 0.1;			% coherence threshold
pix = 500;			% pixel width,height
gap = 10;			% pixel border
m = 12;				% markersize


% note: loadROI won't freak out if you ask for an ROI that doesn't exist
% on Linux these are case sensitive, not on PC
ROIlist = {'V1-L','V2D-L','V2V-L','V3D-L','V3V-L','V3A-L','V4-L','V1-R','V2D-R','V2V-R','V3D-R','V3V-R','V3A-R','V4-R'};
if isunix
	ROIlist = unique([ ROIlist, strrep(strrep(ROIlist,'D','d'),'V-','v-') ]);
end

subjID = sprintf('skeri%04d',subjNum);

if ispc
	retDir = 'X:\data\RETINOTOPY';
else
	retDir = '/raid/MRI/data/RETINOTOPY';
end
subjDir = fullfile(retDir,subjID);
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

DT = load(fileName,'dataTYPES');
disp('------------------------')
for i = 1:numel(DT.dataTYPES)
	disp(DT.dataTYPES(i).name)
	if isempty(DT.dataTYPES(i).scanParams)
		disp({'!!!empty!!!'})
	else
		disp({DT.dataTYPES(i).scanParams.annotation}')
	end
end
i = menu('Choose dataTYPE:',{DT.dataTYPES.name});
if i == 0
	return
end
k = ~cellfun(@isempty,regexpi({DT.dataTYPES(i).scanParams.annotation},'.*wedge'));
if sum(k)==1
	j1 = find(k);
else
	j1 = menu('Choose WEDGE Scan:',{DT.dataTYPES(i).scanParams.annotation});
	if j1 == 0
		return
	end
end
clear DT

cd(subjDir)
mrVista('f')

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

% set scan
FLAT{selectedFLAT} = setCurScan( FLAT{selectedFLAT}, j1 );
% set ROI options & load
FLAT{selectedFLAT} = roiSetOptions( FLAT{selectedFLAT}, struct('selRoiColor',[1 1 1],'showRois',3,'drawFormat',3) );
FLAT{selectedFLAT} = loadROI( FLAT{selectedFLAT}, ROIlist, [], [], false, true );
RH = cellfun(@isempty,strfind(get(FLAT{1}.ui.ROI.popupHandle,'string'),'-L')) & cellfun(@isempty,strfind(get(FLAT{1}.ui.ROI.popupHandle,'string'),'-l'));
% set dataTYPE & load phase map
FLAT{selectedFLAT} = selectDataType( FLAT{selectedFLAT}, i );
FLAT{selectedFLAT} = setDisplayMode( FLAT{selectedFLAT}, 'ph' );

fig = figure('units','pixels','position',[200 500 2*pix+3*gap pix+2*gap],'color','k','name',subjID);
ax = [ axes('units','pixels','position',[gap gap pix pix]), axes('units','pixels','position',[pix+2*gap gap pix pix]) ];

% left
if any(RH)
	FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(RH,1,'first') );
end
selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 1 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );

img = FLAT{selectedFLAT}.ui.image;
imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
if imgRot ~= 0
	imgSize = size(img);
	img = imrotate(img,-imgRot*180/pi);
	img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
end
axes(ax(1))
image(img)
L = findobj(FLAT{selectedFLAT}.ui.mainAxisHandle,'type','line','visible','on');
for i = 1:numel(L)
	line(get(L(i),'xdata'),get(L(i),'ydata'),'color',get(L(i),'color'),...
		'linestyle','none','linewidth',1,'marker','.','markersize',m);
end


% right
if ~all(RH)
	FLAT{selectedFLAT} = selectROI( FLAT{selectedFLAT}, find(~RH,1,'first') );
end
selectButton( FLAT{selectedFLAT}.ui.sliceButtons, 2 );
FLAT{selectedFLAT} = refreshScreen( FLAT{selectedFLAT}, 2 );

img = FLAT{selectedFLAT}.ui.image;
imgRot = get(FLAT{selectedFLAT}.ui.ImageRotate.sliderHandle,'value');
if imgRot ~= 0
	imgSize = size(img);
	img = imrotate(img,-imgRot*180/pi);
	img = imcrop(img,[repmat((size(img,1)-imgSize(1))/2,1,2),imgSize-1]);
end
axes(ax(2))
image(img)
L = findobj(FLAT{selectedFLAT}.ui.mainAxisHandle,'type','line','visible','on');
for i = 1:numel(L)
	line(get(L(i),'xdata'),get(L(i),'ydata'),'color',get(L(i),'color'),...
		'linestyle','none','linewidth',1,'marker','.','markersize',m);
end

set(fig,'colormap',get(FLAT{selectedFLAT}.ui.figNum,'colormap'))
set(ax,'visible','off')

if exist('writeOut','var') && writeOut
	F = getframe(fig);
	fname = fullfile(retDir,'jpegs',[subjID,'_retROIs.jpg']);
	fprintf('writing %s ...',fname)
	imwrite(F.cdata,fname,'jpg','Quality',100)
end
fprintf('done\n')

% imresize(img,[pix pix],'nearest')