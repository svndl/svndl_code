function ok = checkCompleteHeadmodel(skeriNum)
% OK = checkCompleteHeadmodel(skeriNum)


subjid = sprintf('skeri%04d',skeriNum);
anatDir = SKERIanatDir;
fsDir = fullfile(anatDir,'FREESURFER_SUBS',strcat(subjid,'_fs4'));
anatDir = fullfile(anatDir,subjid);

% Retinotopic ROIs
ROIretinotopy = {'V1','V2D','V2V','V3D','V3V','V3A','V4'};
% fMRI Localizer ROIs
ROIlocalizer = {'MT','LOC'};
% Freesurfer Desikan atlas ROIs (later versions add insula)
ROIatlas = {'bankssts','caudalanteriorcingulate','caudalmiddlefrontal','corpuscallosum','cuneus',...
	'entorhinal','frontalpole','fusiform','inferiorparietal','inferiortemporal','isthmuscingulate',...
	'lateraloccipital','lateralorbitofrontal','lingual','medialorbitofrontal','middletemporal',...
	'paracentral','parahippocampal','parsopercularis','parsorbitalis','parstriangularis','pericalcarine',...
	'postcentral','posteriorcingulate','precentral','precuneus','rostralanteriorcingulate','rostralmiddlefrontal',...
	'superiorfrontal','superiorparietal','superiortemporal','supramarginal','temporalpole','transversetemporal',...
	'unknown'};

% Expected files
files = { ...
	fullfile(anatDir,'vAnatomy.dat') ...
	fullfile(anatDir,'left','left.Class') ...
	fullfile(anatDir,'left','left.Gray') ...
	fullfile(anatDir,'left','3DMeshes','left.MrM') ...
	fullfile(anatDir,'right','right.Class') ...
	fullfile(anatDir,'right','right.Gray') ...
	fullfile(anatDir,'right','3DMeshes','right.MrM') ...
	fullfile(anatDir,'Standard','meshes','defaultCortex.mat') ...
	fullfile(anatDir,'Standard','meshes','ROIs_correlation.mat') ...
	fullfile(fsDir,'surf','lh.midgray') ...
	fullfile(fsDir,'surf','rh.midgray') ...
	fullfile(fsDir,'bem',strcat(subjid,'_fiducials.txt')) ...
	fullfile(fsDir,'bem',strcat(subjid,'_fs4-head.fif')) ...
	fullfile(fsDir,'bem','inner_skull.tri') ...
	fullfile(fsDir,'bem','outer_skull.tri') ...
	fullfile(fsDir,'bem','outer_skin.tri') ...
	fullfile(fsDir,'bem',strcat(subjid,'_fs4-ico-5-src.fif')) ...
	fullfile(fsDir,'bem',strcat(subjid,'_fs4-ico-5p-src.fif')) ...
	fullfile(fsDir,'bem',strcat(subjid,'_fs4-bem.fif')) ...
	fullfile(fsDir,'bem',strcat(subjid,'_fs4-bem-sol.fif')) ...
	fullfile(fsDir,'surf','lh.smseghead') ...
	fullfile(fsDir,'surf','lh.seghead') ...
};

nFile = numel(files);
fileFlag = false(1,nFile);

for i = 1:nFile-2
	fileFlag(i) = exist(files{i},'file');
	if ~fileFlag(i)
		fprintf('Missing %s\n',files{i})
	end
end
for i = nFile-1:nFile
	fileFlag(i) = exist(files{i},'file');
end
if any(fileFlag(nFile-1:nFile))
	OK = all(fileFlag(1:nFile-2));
else
	OK = false;
	fprintf('%s has no lh.smseghead or lh.seghead\n',subjid)
end

% T2-weighted anatomy
file = fullfile(anatDir,'nifti','FSL_T2_*_FINAL.nii.gz');
T2flag = ~isempty(dir(file));
if ~T2flag
	file = fullfile(anatDir,'nifti',strcat(subjid,'_*_T2*.nii.gz'));
	T2flag = ~isempty(dir(file));
end
if ~T2flag
	fprintf('Can''t find T2-weighted anatomy for %s\n',subjid)
end


nRetinotopy = numel(ROIretinotopy);
nLocalizer = numel(ROIlocalizer);
nAtlas = numel(ROIatlas);


% functional ROIs, Standard Gray and meshes
ROIlist = cat(2,ROIretinotopy,ROIlocalizer);
nList = 2*(nRetinotopy+nLocalizer);
ROIlist = reshape(cat(1,strcat(ROIlist,'-L.mat'),strcat(ROIlist,'-R.mat')),1,nList);
[grayFlag,meshFlag] = deal(false(1,nList));
for i = 1:nList
	file = fullfile(anatDir,'Standard','Gray','ROIs',ROIlist{i});
	grayFlag(i) = exist(file,'file');
	if ~grayFlag(i)
		fprintf('Missing %s\n',file)
	end
end
for i = 1:nList
	file = fullfile(anatDir,'Standard','meshes','ROIs',ROIlist{i});
	meshFlag(i) = exist(file,'file');
	if ~meshFlag(i)
		fprintf('Missing %s\n',file)
	end
end
OK = OK && all(grayFlag) && all(meshFlag);

% Freesurfer atlas ROIs, Standard meshes only
nList = 2*nAtlas;
ROIlist = reshape(cat(1,strcat(ROIatlas,'-L.mat'),strcat(ROIatlas,'-R.mat')),1,nList);
atlasFlag = false(1,nList);
for i = 1:nList
	file = fullfile(anatDir,'Standard','meshes','ROIs',ROIlist{i});
	atlasFlag(i) = exist(file,'file');
	if ~atlasFlag(i)
		fprintf('Missing %s\n',file)
	end
end
OK = OK && all(atlasFlag);

if nargout ~= 0
	ok = OK;
% else
% 	T1 = any(fileFlag([1:8,10:11,13,17:18,21:22])) + 1;
% 	noyes = {'&mdash;','x','?'};
% 	fprintf('\n')
% 	fprintf('<tr><td>%04d</td> <td class=column>%s</td>\n',skeriNum,'xxx')
% 	fprintf('\t<td>%s</td> <td>%s</td> <td>%s</td>\n',noyes{T1},noyes{3},noyes{3})
% 	fprintf('\t<td>%s</td> <td>%s</td> <td>%s</td> <td class=column>%s</td>\n',noyes{3},noyes{3},noyes{3},noyes{3})
% 	fprintf('\t<td class=column>%s</td>\n',noyes{ any(fileFlag([10:11,17:18])) + 1 })
% 	fprintf('\t<td class=column>%s</td>\n',noyes{ all(fileFlag(1:7)) + 1 })
% 	fprintf('\t<td>%s</td> <td>%s</td> <td>%s</td> <td class=column>%s</td>\n',noyes{ fileFlag(12)+1 },noyes{ fileFlag(18)+1 },noyes{ fileFlag(20)+1 },noyes{ fileFlag(13)+1 })
% 	fprintf('\t<td class=column>%s</td>\n',noyes{ fileFlag(8)+1 })
% 	fprintf('\t<td>%s</td> <td>%s</td> <td>%s</td> <td>%s</td> <td>%s</td>\n',noyes{ all(atlasFlag)+1 },noyes{ all(meshFlag(1:2*nRetinotopy))+1 },noyes{ all(meshFlag(2*nRetinotopy+1:end))+1 },noyes{3},noyes{3})
end

return

%% skipping 34,105,110,130 ?104?
for i = [1 3 4 5 9 17 35:37 39 44 47:69 71:79 81:84 87 93:103 108:109 112 116 121:122 125 127:129]
	OK = checkCompleteHeadmodel(i);
end
disp('DONE')
