function fsaverageLabelROIs(skeriNum,grayDir)
% converts V1 & MT ROIs from fsaverage to mrVista Gray using MNE morph maps
%
% usage: fsaverageLabelROIs(skeriNum,grayDir)
%   e.g. fsaverageLabelROIs(119,'/raid/MRI/data/Wadelab/LGN/skeri0119_071910/Gray')

% if nargin == 0
% % skeriNum = 134;
% % grayDir = fullfile(FindFMRIdata(skeriNum,'Wedge'),'Gray');
% skeriNum = 119;
% grayDir = 'X:\data\Wadelab\LGN\skeri0119_071910\Gray';
% end
nargmsg = nargchk(2,2,nargin,'string');
if ~isempty(nargmsg)
	help(mfilename)
	error(nargmsg)
end

% d2Thresh = 1.5^2;		% distance threshold for freesurfer midgray surface to mrVista gray (<=)
% sThresh = 0.25;		% stastistic threshold for mapped label (>=)
d2Thresh = 2^2;		% distance threshold for freesurfer midgray surface to mrVista gray (<=)
sThresh = 0.2;			% stastistic threshold for mapped label (>=)

% first run
% $ mne_make_morph_maps --from skeri####_fs4 --to mni0001_fs4
% try running mne_morph_labels too?  works on directories of label files, not individual files.

Subj1 = 'mni0001_fs4';									% fsaverage or Justin's mni0001_fs4
if isnumeric(skeriNum)
	Subj2 = sprintf('skeri%04d_fs4',skeriNum);
elseif ischar(skeriNum)
	Subj2 = skeriNum;
end

SUBJECTS_DIR = fullfile(SKERIanatDir,'FREESURFER_SUBS');

% Load MNE morphing maps [ toVertices x fromVertices ]
[morphL,morphR] = mne_read_morph_map(Subj1,Subj2,SUBJECTS_DIR);
% Get # vertices [L R]
% note: nV1 might not reflect total # vertices in Subj1's surfaces if the last one's aren't used in morph
[nV1,nV2] = deal([0 0]);
[nV2(1),nV1(1)] = size(morphL);
[nV2(2),nV1(2)] = size(morphR);


% Get used left & right Gray vertices in RAS coordinate system
G = load( fullfile(grayDir,'coords.mat') );
gL = [ G.allLeftNodes( 3,G.keepLeft ) - 128; 128 - G.allLeftNodes( 1:2,G.keepLeft ) ];
gR = [ G.allRightNodes(3,G.keepRight) - 128; 128 - G.allRightNodes(1:2,G.keepRight) ];
nG = [ size(gL,2), size(gR,2) ];
clear G

ROI = struct('color',[0 0 0],'comments','','coords',[],'created','','modified','','name','','viewType','Gray');
labels = {'V1','MT'};
% colors = {'r','y'};
colors = {[0.75 0 0],[0.6 0.6 0]};
surf = 'midgray';
writeAll = false;
fig = figure('name',Subj2);
for iHemi = 1:2

	hemi = [char(102+6*iHemi),'h'];

	V2 = read_surf(fullfile(SUBJECTS_DIR,Subj2,'surf',[hemi,'.',surf]));
% 	nV1(iHemi) = size(read_surf(fullfile(SUBJECTS_DIR,Subj1,'surf',[hemi,'.white'])),1);

	% label stat vectors
	s1 = zeros(nV1(iHemi),1);
	s2 = zeros(nV2(iHemi),1);
	sG = zeros(1,nG(iHemi));
	
	if iHemi == 1
		[kMap,d2] = nearpoints(gL,V2');			% 1 x nG(iHemi).  V2(kMap,:) ~ gL'
	else
		[kMap,d2] = nearpoints(gR,V2');
	end
	figure(fig)
	subplot(1,2,iHemi)
	hist(sqrt(d2),0.05:0.1:5)
	xlabel(['Gray distance to FS ',surf,' (mm)'])
	ylabel('frequency')
	title(upper(hemi))

	for iLabel = 1:numel(labels)
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

		kROI = sG >= sThresh & d2 <= d2Thresh;
		
		if any(strcmp(Subj1,{'mni0001_fs4','fsaverage'}))
			ROI.name = ['fsaverage-',labels{iLabel},'-',upper(hemi(1))];
		else
			ROI.name = [strrep(Subj1,'_fs4',''),'-',labels{iLabel},'-',upper(hemi(1))];
		end

% 		if strcmp(labels{iLabel},'MT')
% 			if iHemi == 1
% 				mapStruct = struct('map',{{}},'mapName','','mapUnits','','cmap',[gray(128);jet(128)],'clipMode',[0 1],'numColors',128,'numGrays',128);
% 				mapStruct.map{1} = [sG,zeros(1,nG(2))];
% 				mapStruct.mapName = [ROI.name(1:end-2),'-probability'];
% 			else
% 				mapStruct.map{1}(nG(1)+1:sum(nG)) = sG;
% 				filename = fullfile(grayDir,'Original',[mapStruct.mapName,'.mat']);
% 				writeFlag = exist(filename,'file') == 0;
% 				if ~writeFlag
% 					if strcmp(questdlg([filename,' exists. Replace?'],mfilename,'No','Yes','No'),'Yes')
% 						writeFlag = true;
% 					end
% 					drawnow
% 				end
% 				if writeFlag
% 					save(filename,'-struct','mapStruct')
% % 					disp(filename)
% 				end
% 			end
% 		end

		if any(kROI)

			ROI.color = colors{iLabel};
			if iHemi == 1
				ROI.coords = single( [ 128-gL([3 2],kROI); 128+gL(1,kROI) ] );		% swap 1st 2 dimensions.  nodes vs coords thing?
			else
				ROI.coords = single( [ 128-gR([3 2],kROI); 128+gR(1,kROI) ] );
			end
			[ROI.created,ROI.modified] = deal(datestr(now));

			if ~isdir(fullfile(grayDir,'ROIs'))
				[status,result] = system(['mkdir ',fullfile(grayDir,'ROIs')]);
				if status ~= 0
					error(result)
				end
			end
			filename = fullfile(grayDir,'ROIs',[ROI.name,'.mat']);
			writeFlag = writeAll || ( exist(filename,'file') == 0 );
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
				save(filename,'ROI')
				disp(filename)
			end
			
		else
			fprintf('WARNING: No vertices in ROI %s.  Not saving.\n',ROI.name)
		end

	end

	
end
disp('done')

return




%% =============================diagnostics=====================================
clear

skeriNum = 119;
grayDir = 'X:\data\WadeLab\LGN\skeri0119_071910\Gray';		% only need this for painting distance map
% skeriNum = 129;
% grayDir = ['X:\data\RETINOTOPY\',sprintf('skeri%04d',skeriNum),'\Gray'];
skeriNum = 113;
grayDir = '/raid/MRI/data/TylerLab/Shape/skeri0113_070910/Gray';

SUBJECTS_DIR = fullfile(SKERIanatDir,'FREESURFER_SUBS');
Subj1 = 'mni0001_fs4';									% fsaverage or Justin's mni0001_fs4
Subj2 = sprintf('skeri%04d_fs4',skeriNum);

labels = {'V1','MT','v1.predict','v1.prob'};			% in Subj2/label/ ?h.v1.prob.label & ?h.v1.predict.label
iLabel = 1;

iHemi = 1;
hemi = [char(102+6*iHemi),'h'];

if any(strcmp(labels{iLabel},{'V1','MT'}))
	% note: might not reflect total # vertices in Subj1's surfaces if the last one's aren't used in morph
	[morphL,morphR] = mne_read_morph_map(Subj1,Subj2,SUBJECTS_DIR);

	% ... will be nvertices-by-5, where each column means:
	% (1) vertex number, (2-4) xyz at each vertex, (5) stat
	% IMPORTANT: the vertex number is 0-based.
	L = read_label('',fullfile(SUBJECTS_DIR,Subj1,'label',[hemi,'.',labels{iLabel},'.label']));
	L(:,1) = L(:,1) + 1;

	if iHemi == 1
		s1 = zeros(size(morphL,2),1);
	else
		s1 = zeros(size(morphR,2),1);
	end
	s1(L(:,1)) = L(:,5);
	if iHemi == 1
		s2 = morphL * s1;		% nV2 x 1
	else
		s2 = morphR * s1;
	end
	
	roiName = ['fsaverage ',labels{iLabel}];	%,'-',upper(hemi(1))];
else
	L = read_label('',fullfile(SUBJECTS_DIR,Subj2,'label',[hemi,'.',labels{iLabel},'.label']));
	L(:,1) = L(:,1) + 1;
	
	s2 = zeros(size(read_curv(fullfile(SUBJECTS_DIR,Subj2,'surf',[hemi,'.curv']))));
	s2(L(:,1)) = L(:,5);

	roiName = 'V1_average';	%['V1_average-',upper(hemi(1))];
end

% ---------------

if ~true		% PLOT ON FSAVERAGE
	SubjPlot = Subj1;
	[V,F] = read_surf(fullfile(SUBJECTS_DIR,SubjPlot,'surf',[hemi,'.inflated']));
% 	C = ones(size(V,1),1);
% 	C(L(:,1)) = L(:,5)*10 + 1;		% 10 subjects
% 	C = 1 + s1*10;						% 1:11
% 	C = s1;
	C = read_curv(fullfile(SUBJECTS_DIR,SubjPlot,'surf',[hemi,'.sulc']));
	C = -0.5 - C/(2*max(abs(C)));
	C = -0.6 - 0.2*(C<-0.5);
	kp = s1 ~= 0;
	C(kp) = s1(kp);
% 	pROI = median(V(L(:,1),:));
% 	iROI = L(ceil(size(L,1)/2),1);
	iROI = L(nearpoints(median(V(L(:,1),:))',V(L(:,1),:)'),1);
else			% PLOT ON DESTINATION SUBJECT
	SubjPlot = Subj2;
	[V,F] = read_surf(fullfile(SUBJECTS_DIR,SubjPlot,'surf',[hemi,'.inflated']));
% 	C = s2;
	C = read_curv(fullfile(SUBJECTS_DIR,SubjPlot,'surf',[hemi,'.sulc']));
	C = -0.5 - C/(2*max(abs(C)));
	C = -0.6 - 0.2*(C<-0.5);
	kp = s2 ~= 0;
	C(kp) = s2(kp);
	[junk,iROI] = max(s2);
end
F = flipdim(F+1,2);	% outward normals

pROI = V(iROI,:);

clf
set(gcf,'Colormap',[gray(128);jet(128)],'Name',Subj1,'Color','w')
HP = patch('Vertices',V,'Faces',F,'FaceVertexCData',C,'FaceColor','interp','EdgeColor','none','FaceLighting','gouraud');
set(HP,'AmbientStrength',0.5,'DiffuseStrength',1,'SpecularStrength',0.4,'SpecularExponent',6)
% N = get(HP,'VertexNormals');

Vmin = min(V)-5;
Vmax = max(V)+5;

set(gca,'DataAspectRatio',[1 1 1],'View',[atan2(pROI(1),-pROI(2))*180/pi 0],'Position',[0.1 0.05 0.7 0.9],'CLim',[-1 1],...
	'XLim',[Vmin(1),Vmax(1)],'YLim',[Vmin(2),Vmax(2)],'ZLim',[Vmin(3),Vmax(3)],'XTick',[],'YTick',[],'ZTick',[])	%'visible','off')
HL = light('Position',pROI*2,'Color',[1 1 1],'Style','local');	%,'infinite');
% HL = light('Position',pROI+100/norm(N(iROI,:),'fro')*N(iROI,:),'Style','infinite','Color',[1 1 1]);

title([roiName,' on ',SubjPlot],'Interpreter','none')
colorbar('YLim',[0 1])

azSign = ( 2*(iHemi==2)-1 )*( 2*strcmp(labels{iLabel},'MT')-1 );
set(gca,'View',[90*azSign 0],'XColor','w','YColor','w','ZColor','w','Position',[0.1 0.05 0.7 0.9])		% need position again?
set(HL,'Position',[500*azSign -100 -50])



%% view distance on mesh
G = load( fullfile(grayDir,'coords.mat') );
if iHemi == 1
	g = [ G.allLeftNodes( 3,G.keepLeft ) - 128; 128 - G.allLeftNodes( 1:2,G.keepLeft ) ];
else
	g = [ G.allRightNodes(3,G.keepRight) - 128; 128 - G.allRightNodes(1:2,G.keepRight) ];
end
Vmg = read_surf(fullfile(SUBJECTS_DIR,Subj2,'surf',[hemi,'.midgray']));
% [kMap,d] = nearpoints(g,Vmg');			% Vmg(kMap,:) ~ g'
[kMap,d] = nearpoints(Vmg',g);			% g(:,kMap) ~ Vmg'
clear G g Vmg kMap
d = sqrt(d)';
% set(HP,'FaceVertexCData',min(d,5))
set(HP,'FaceVertexCData',max(d,1.5))
set(HP,'Vertices',read_surf(fullfile(SUBJECTS_DIR,SubjPlot,'surf',[hemi,'.midgray'])))

set(gcf,'Colormap',jet(256))
set(gca,'ClimMode','auto')
	
	
	