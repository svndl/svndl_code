function fsaverageLabelMaps(skeriNum,vistaDir,dataTypeName,labels,sourceSubj)
% converts probability maps from fsaverage to mrVista Gray using MNE morph maps
%
% usage: fsaverageLabelMaps(skeriNum,vistaDir,dataTypeName,[labels])
%   e.g. fsaverageLabelMaps(119,'/raid/MRI/data/Wadelab/LGN/skeri0119_071910','Original')
%
% skeriNum input can be either numeric shorthand for 'skeri####_fs4', or a Freesurfer ID string
% labels input (optional) is cell array 
%        possible elements are BA1, BA2, BA3a, BA3b, BA4a, BA4p, BA6, BA44 BA45, V1, V2, MT
%                              Skeri45Subj-V1,V2D,V2V,V3D,V3V,V3A,V4,MT,LOC
%        default labels = {'V1','MT'}

nargmsg = nargchk(3,5,nargin,'string');
if ~isempty(nargmsg)
	help(mfilename)
	error(nargmsg)
end

grayDir = fullfile(vistaDir,'Gray');
grayMapDir = fullfile(grayDir,dataTypeName);
if ~isdir(grayMapDir)
% 	[status,result] = system(['mkdir ',grayMapDir]);
% 	if status ~= 0
% 		error(result)
% 	end
	error('%s does not exist',grayMapDir)
end

DT = load(fullfile(vistaDir,'mrSESSION.mat'),'dataTYPES');
kDT = strcmp({DT.dataTYPES.name},dataTypeName);
switch sum(kDT)
case 1
	nScan = size(DT.dataTYPES(kDT).scanParams,2);
case 0
	error('no dataTYPE %s in %s mrSESSION',dataTypeName,vistaDir)
otherwise
	warning('Multiple dataTYPES with same name in %s',vistaDir)
	nScan = size(DT.dataTYPES(find(kDT,1,'first')).scanParams,2);
end
if nScan == 0
	error('empty scanParams in %s',dataTypeName)
end
mapStruct = struct('map',{cell(1,nScan)},'mapName','','mapUnits','','cmap',[gray(128);jet(128)],'clipMode',[0 1],'numColors',128,'numGrays',128);


d2Thresh = 3.5^2;		% distance threshold for freesurfer midgray surface to mrVista gray (<=)

% first run
% $ mne_make_morph_maps --from skeri####_fs4 --to mni0001_fs4
% try running mne_morph_labels too?  works on directories of label files, not individual files.

if ~exist('sourceSubj','var') || isempty(sourceSubj)
	Subj1 = 'mni0001_fs4';									% fsaverage or Justin's mni0001_fs4
else
	Subj1 = sourceSubj;
end
if isnumeric(skeriNum)
	Subj2 = sprintf('skeri%04d_fs4',skeriNum);
elseif ischar(skeriNum)
	Subj2 = skeriNum;
end

SUBJECTS_DIR = fullfile(SKERIanatDir,'FREESURFER_SUBS');

if strcmp(Subj1,Subj2)
	[morphL,morphR] = deal(1);
	nV1 = [	size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','lh.curv')),1),...
				size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','rh.curv')),1)	];
	nV2 = nV1;
else
	% Load MNE morphing maps [ toVertices x fromVertices ]
	[morphL,morphR] = mne_read_morph_map(Subj1,Subj2,SUBJECTS_DIR);		% mne_read_morph_map(from,to,...).  size out = to x from
	% Get # vertices [L R]
	% note: nV1 might not reflect total # vertices in Subj1's surfaces if the last one's aren't used in morph
	[nV1,nV2] = deal([0 0]);
	[nV2(1),nV1(1)] = size(morphL);
	[nV2(2),nV1(2)] = size(morphR);
	nV1e = nV1;
	nV1(1) = size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','lh.curv')),1);
	nV1(2) = size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','rh.curv')),1);
	if nV1e(1) < nV1(1)
		morphL(nV2(1),nV1(1)) = 0;
		fprintf('padding left morph for %s.\n',Subj1)
	end
	if nV1e(2) < nV1(2)
		morphR(nV2(2),nV1(2)) = 0;
		fprintf('padding right morph for %s.\n',Subj1)
	end
end

% Get used left & right Gray vertices in RAS coordinate system
G = load( fullfile(grayDir,'coords.mat') );
gL = [ G.allLeftNodes( 3,G.keepLeft ) - 128; 128 - G.allLeftNodes( 1:2,G.keepLeft ) ];
gR = [ G.allRightNodes(3,G.keepRight) - 128; 128 - G.allRightNodes(1:2,G.keepRight) ];
nG = [ size(gL,2), size(gR,2) ];
clear G

if ~exist('labels','var') || isempty(labels)
	labels = {'V1','MT'};
end
surf = 'midgray';
writeAll = false;

fig = figure('name',Subj2);

for iLabel = 1:numel(labels)

	for iHemi = 1:2

		hemi = [char(102+6*iHemi),'h'];

		V2 = read_surf(fullfile(SUBJECTS_DIR,Subj2,'surf',[hemi,'.',surf]));

		% label stat vectors
		s1 = zeros(nV1(iHemi),1);
		s2 = zeros(nV2(iHemi),1);
		sG = zeros(1,nG(iHemi));

		if iHemi == 1
			[kMap,d2] = nearpoints(gL,V2');			% 1 x nG(iHemi).  V2(kMap,:) ~ gL'
		else
			[kMap,d2] = nearpoints(gR,V2');
		end
		
		if iLabel == 1
			figure(fig)
			subplot(1,2,iHemi)
			hist(sqrt(d2),0.05:0.1:5)
			xlabel(['Gray distance to FS ',surf,' (mm)'])
			ylabel('frequency')
			title(upper(hemi))
		end

		% ... will be nvertices-by-5, where each column means:
		% (1) vertex number, (2-4) xyz at each vertex, (5) stat
		% IMPORTANT: the vertex number is 0-based.
		L = read_label('',fullfile(SUBJECTS_DIR,Subj1,'label',[hemi,'.',labels{iLabel},'.label']));
		s1(:) = 0;
		s1(L(:,1)+1) = L(:,5);	% 0..1, probability?
		fprintf('%s %s.%s: min=%g, max=%g\n',Subj1,hemi,labels{iLabel},min(s1(s1~=0)),max(s1))

		if iHemi == 1
			s2(:) = morphL * s1;		% nV2 x 1
		else
			s2(:) = morphR * s1;
		end
		sG(:) = s2(kMap);
		sG( d2 > d2Thresh ) = NaN;

		if iHemi == 1
			mapStruct.map{1} = [sG,zeros(1,nG(2))];
			if any(strcmp(Subj1,{'mni0001_fs4','fsaverage'}))
				mapStruct.mapName = ['fsaverage-',labels{iLabel},'-probability'];
			else
				mapStruct.mapName = [strrep(Subj1,'_fs4',''),'-',labels{iLabel},'-probability'];
			end
		else
			mapStruct.map{1}(nG(1)+1:sum(nG)) = sG;
			filename = fullfile(grayMapDir,[mapStruct.mapName,'.mat']);
			writeFlag = writeAll || exist(filename,'file') == 0;
			if ~writeFlag
				switch questdlg([filename,' exists. Replace?'],mfilename,'No','Yes','Yes All','No')
				case 'Yes'
					writeFlag = true;
				case 'Yes All'
					[writeFlag,writeAll] = deal(true);
				end
				drawnow
			end
			if writeFlag
				save(filename,'-struct','mapStruct')
				disp(filename)
			end
		end


	end

	
end
disp('done')






