function makeSkeriRoiLabels(roiList,subjList,targetSubj)
% makeSkeriRoiLabels(roiList,subjList)
% roiList  = cell array of Standard Gray ROI names w/o hemisphere tag
%            e.g. {'LOC','MT'}
% subjList = numeric row vector of SKERI subject IDs
%            e.g.
%            [1 3 4 9 17 36 37 39 47:57 62:64 66 69 71 73:77 79 81 82    95 100] - controls, NIC LOCMT on Westinghouse monitor
%            [                    53:59 62:64 66 69 71 73:77 79 81 82 93 95 100] - controls, NIC Retinotopy on Westinghouse monitor
%            [102 108 125 128 129 134]                                           - controls, NIC Litemax monitor (confirmed)
%            [101 112 116]                                                       - controls, NIC Litemax monitor (probable)
%            [1 3 4 9 17 36 37 39 44 47:57 62:64 66 69 71 73:77 79 81 82 95 100 101:102 108 112 116 125 128 129 134] - controls, skeri unflagged
%            [5 35 58 59 93 103 135] - controls, flagged

if ~exist('roiList','var') || isempty(roiList)
% 	roiList = {'LOC'};	% {'LOC','MT'};
	help(mfilename)
	return
end
if ~exist('subjList','var') || isempty(subjList)
	subjList = [1 3 4 9 17 36 37 39 47:57 62:64 66 69 71 73:77 79 81 82    95 100];		% controls, NIC LOCMT on Westinghouse monitor
%	subjList = [                    53:59 62:64 66 69 71 73:77 79 81 82 93 95 100];		% controls, NIC Retinotopy on Westinghouse monitor
%	subjList = [102 108 125 128 129 134];																% controls, NIC Litemax monitor (confirmed)
%	subjList = [101 112 116];																				% controls, NIC Litemax monitor (probable)
end

SUBJECTS_DIR = fullfile(SKERIanatDir,'FREESURFER_SUBS');
surf = 'midgray';

if ~exist('targetSubj','var') || isempty(targetSubj)
	Subj1 = 'mni0001_fs4';			% fsaverage or Justin's mni0001_fs4
else
	Subj1 = targetSubj;
end
% nV1 = [ size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','lh.curv')),1),...
% 		  size(read_curv(fullfile(SUBJECTS_DIR,Subj1,'surf','rh.curv')),1) ];
V1L = read_surf(fullfile(SUBJECTS_DIR,Subj1,'surf',['lh.',surf]));
V1R = read_surf(fullfile(SUBJECTS_DIR,Subj1,'surf',['rh.',surf]));
nV1 = [ size(V1L,1), size(V1R,1) ];
mapL = zeros(nV1(1),1);
mapR = zeros(nV1(2),1);
nSubj = 0;

for iROI = 1:numel(roiList)

	mapL(:) = 0;
	mapR(:) = 0;
	nSubj(:) = 0;

	for skeriNum = subjList

		% freesurfer ID
		if isnumeric(skeriNum)
			Subj2 = sprintf('skeri%04d_fs4',skeriNum);
		elseif ischar(skeriNum)
			Subj2 = skeriNum;
		end
		fprintf('%s ----------------------\n',Subj2)

		if any(strcmpi(roiList{iROI},{'MT','LOC'}))
			vistaDir = FindFMRIdata(skeriNum,upper(roiList{iROI}));
		else
			vistaDir = FindFMRIdata(skeriNum,'Wedge');	% 'Wedge', 'Ring', 'MT', or 'LOC'
		end
% 		vistaDir = 'X:\data\TylerLab\ADVANCED_RETINOTOPY\skeri0005_031803';	% ***
		
		if isempty(strfind(vistaDir,'xxx')) || ~isempty(strfind(Subj2,'xxx'))

			grayDir = fullfile(vistaDir,'Gray');
%			roiDir = fullfile(grayDir,'ROIs');
			if isnumeric(skeriNum)
				roiDir = fullfile(SKERIanatDir,sprintf('skeri%04d',skeriNum),'Standard','Gray','ROIs');
			elseif ischar(skeriNum)
				roiDir = fullfile(SKERIanatDir,skeriNum,'Standard','Gray','ROIs');
			end
% 			roiDir = fullfile(vistaDir,'Gray','ROIs');	% ***

			roiFiles = { fullfile(roiDir,[roiList{iROI},'-L.mat']), fullfile(roiDir,[roiList{iROI},'-R.mat']) };
			foundL = exist(roiFiles{1},'file');
			if ~foundL
				switch roiList{iROI}
				case {'V2D','V3D'}
					roiFiles{1} = fullfile(roiDir,[roiList{iROI}(1:2),'d-L.mat']);
				case {'V2V','V3V'}
					roiFiles{1} = fullfile(roiDir,[roiList{iROI}(1:2),'v-L.mat']);
				end
				foundL = exist(roiFiles{1},'file');
			end
			foundR = exist(roiFiles{2},'file');
			if ~foundR
				switch roiList{iROI}
				case {'V2D','V3D'}
					roiFiles{2} = fullfile(roiDir,[roiList{iROI}(1:2),'d-R.mat']);
				case {'V2V','V3V'}
					roiFiles{2} = fullfile(roiDir,[roiList{iROI}(1:2),'v-R.mat']);
				end
				foundR = exist(roiFiles{2},'file');
			end
			if foundL && foundR

				% Get used left & right Gray vertices in RAS coordinate system
				% layer = nodes row 6
				G = load( fullfile(grayDir,'coords.mat') );
				if true	% all Nodes
					gL = [ G.allLeftNodes( 3,:) - 128; 128 - G.allLeftNodes( 1:2,:) ];
					gR = [ G.allRightNodes(3,:) - 128; 128 - G.allRightNodes(1:2,:) ];
				else		% used Nodes
					gL = [ G.allLeftNodes( 3,G.keepLeft ) - 128; 128 - G.allLeftNodes( 1:2,G.keepLeft ) ];
					gR = [ G.allRightNodes(3,G.keepRight) - 128; 128 - G.allRightNodes(1:2,G.keepRight) ];
				end
				clear G

				% load Freesurfer surfaces
				V2L = read_surf(fullfile(SUBJECTS_DIR,Subj2,'surf',['lh.',surf]));
				V2R = read_surf(fullfile(SUBJECTS_DIR,Subj2,'surf',['rh.',surf]));
				nV2 = [ size(V2L,1), size(V2R,1) ];

				% DO SOME SORT OF DISTANCE CHECKS???
				[kMapL] = nearpoints(V2L',gL);			% 1 x size(V2L,1).  gL(:,kMapL)' ~ V2L
				[kMapR] = nearpoints(V2R',gR);

				% Load MNE morphing maps [ toVertices x fromVertices ]
				[morphL,morphR] = mne_read_morph_map(Subj2,Subj1,SUBJECTS_DIR);		% (from,to,...)
				% Get # vertices [L R]
				% note: rows might not reflect total #vertices in from subject's surfaces if the last one's aren't used in morph
				nV2e = [ size(morphL,2), size(morphR,2) ];
				if nV2e(1) < nV2(1)
					morphL(nV1(1),nV2(1)) = 0;
					fprintf('padding left morph for %s.\n',Subj2)
				end
				if nV2e(2) < nV2(2)
					morphR(nV1(2),nV2(2)) = 0;
					fprintf('padding right morph for %s.\n',Subj2)
				end

				roi = load(roiFiles{1});
				mapGL = zeros(size(gL,2),1);
				mapGL(ismember(gL',[ roi.ROI.coords(3,:)-128; 128-roi.ROI.coords([2 1],:) ]','rows')) = 1;
				mapL(:) = mapL(:) + morphL * mapGL(kMapL);

				roi = load(roiFiles{2});
				mapGR = zeros(size(gR,2),1);
				mapGR(ismember(gR',[ roi.ROI.coords(3,:)-128; 128-roi.ROI.coords([2 1],:) ]','rows')) = 1;
				mapR(:) = mapR(:) + morphR * mapGR(kMapR);

				nSubj(:) = nSubj + 1;

			else
				warning('%s has incomplete ROI %s - skipped.',Subj2,roiList{iROI})
			end
			
		end
			
	end			% skeriNum
	mapL(:) = mapL / nSubj;
	mapR(:) = mapR / nSubj;
	
	labelRoot = sprintf('Skeri%dSubj-%s',nSubj,roiList{iROI});
% 	labelRoot = sprintf('%s-%s',Subj2,roiList{iROI});		% ***

	labelFile = fullfile(SUBJECTS_DIR,Subj1,'label',['lh.',labelRoot,'.label']);
	k = mapL(:) ~= 0;
	OK = write_label(find(k)-1,V1L(k,:),mapL(k),labelFile,Subj1);
	if OK == 1
		fprintf('wrote %s\n',labelFile)
	else
		error('Problem writing %s',labelFile)
	end
	
	labelFile = fullfile(SUBJECTS_DIR,Subj1,'label',['rh.',labelRoot,'.label']);
	k = mapR(:) ~= 0;
	OK = write_label(find(k)-1,V1R(k,:),mapR(k),labelFile,Subj1);
	if OK == 1
		fprintf('wrote %s\n',labelFile)
	else
		error('Problem writing %s',labelFile)
	end

end				% iROI


return

%%
clear
hemi = 'rh';
labs = {'Skeri45Subj-MT','Skeri45Subj-LOC','Skeri45Subj-V4','Skeri45Subj-V3A','Skeri45Subj-V3V','Skeri45Subj-V3D','Skeri41Subj-V2V','Skeri45Subj-V2D','Skeri45Subj-V1'};
vals = [6 5 4 4 3 3 2 2 1];
pROI = [0.25 0.25 0.35 0.35 0.35 0.35 0.35 0.35 0.5];
n = numel(labs);
if any( [numel(vals) numel(pROI)] ~= n )
	error('mismatch')
end
subjID = 'mni0001_fs4';
subjDIR = fullfile(SKERIanatDir,'FREESURFER_SUBS',subjID);
V = read_surf(fullfile(subjDIR,'surf',[hemi,'.midgray']));
nV = size(V,1);
k = false(nV,1);
M = zeros(nV,1);
for i = 1:n
	% ... will be nvertices-by-5, where each column means:
	% (1) vertex number, (2-4) xyz at each vertex, (5) stat
	% IMPORTANT: the vertex number is 0-based.
	L = read_label('',fullfile(subjDIR,'label',[hemi,'.',labs{i},'.label']));
	j = L( L(:,5) >= pROI(i), 1 ) + 1;
	k(j) = true;
	M(j) = vals(i);
end
labelFile = fullfile(subjDIR,'label',[hemi,'.Skeri45Subj-Ret.label']);
OK = write_label(find(k)-1,V(k,:),M(k),labelFile,subjID)
if OK == 1
	fprintf('wrote %s\n',labelFile)
else
	error('Problem writing %s',labelFile)
end


