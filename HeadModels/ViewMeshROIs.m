function ViewMeshROIs(subjNum,writeJPG)
% ViewMeshROIs(subjectNumber)

subjid = sprintf('skeri%04d',subjNum);
if ~exist('writeJPG','var') || isempty(writeJPG)
	writeJPG = false;
end
ROIlist = {'V1','V2D','V2V','V3D','V3V','V3A','V4','MT','LOC'};
ROIcolor = [ 1 0 0; 0 1 0; 0 1 0; 0 0 1; 0 0 1; 0 0.875 0.875; 1 0 1; 0.875 0.875 0; 1 0.5 0 ];

if ispc
	mriDir = 'X:';
else
	mriDir = '/raid/MRI';
end
anatDir = fullfile(mriDir,'anatomy');

% RAS (mm)?

D = load(fullfile(anatDir,subjid,'Standard','meshes','defaultCortex.mat'));

if ~all(D.msh.nVertexLR==repmat(10242,1,2))
	error('not MNE mesh')
end
kL =     1:10242;
kR = 10243:20484;

P = D.msh.data.vertices' - 128;
P = [ P(:,3), -P(:,1:2) ];

VL = freesurfer_read_surf(fullfile(anatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf','lh.pial'));
VR = freesurfer_read_surf(fullfile(anatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf','rh.pial'));

[iL,dL]=nearpoints(P(kL,:)',VL');
[iR,dR]=nearpoints(P(kR,:)',VR');
if max([dL;dR])>1e-6
	error('mesh mismatch')
end

% surf = 'inflated';
surf = 'sphere';
% surf = 'sphere.reg';
VL = freesurfer_read_surf(fullfile(anatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf',['lh.',surf]));
VR = freesurfer_read_surf(fullfile(anatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf',['rh.',surf]));
VL = VL(iL,:);
VR = VR(iR,:);

% if isempty(strfind(surf,'sphere'))
% else
% 	VL(:,1) = VL(:,1) - 110;
% 	VR(:,1) = VR(:,1) + 110;
% end


if size(D.msh.data.triangles,2)~=40960 || find(max(D.msh.data.triangles'+1,[],2)<=10242,1,'last') ~= 20480
	error('face problem')
end
kL = 1:20480;
kR = 20481:40960;

%%
[thetaLeft,thetaRight] = deal(-pi/2);
[phiLeft,phiRight] = deal(-pi/6);

badColor = false(1,2);
threshColor = 0.25;
threshH = 0.90;
bgColor = repmat([0 1 0],2,1);
[cL,cR] = deal(ones(10242,3));
for i = 1:numel(ROIlist)
	% Left hemisphere
	roiFile = fullfile(anatDir,subjid,'Standard','meshes','ROIs',[ROIlist{i},'-L.mat']);
	if exist(roiFile,'file')
		roi = load(roiFile);
		rgb = color2rgb(roi.ROI.color);
		badColor(1) = norm( rgb - ROIcolor(i,:) ) > threshColor;
		if badColor(1)
			disp([roiFile,' is wrong color'])
		end
		rgb = ROIcolor(i,:);
		kH = roi.ROI.meshIndices <= 10242;
		if all( kH )
			cL(roi.ROI.meshIndices,:) = repmat( rgb, numel(roi.ROI.meshIndices), 1 );
		elseif ~any( kH )
			disp([roiFile,' is in wrong hemisphere'])
			bgColor(1,:) = [1 0 0];
		else
			fH = sum(kH)/numel(kH);
			if fH >= threshH
				cL(roi.ROI.meshIndices(kH),:) = repmat( rgb, sum(kH), 1 );
				if ~all( bgColor(1,:) == [1 0 0] )
					bgColor(1,:) = [1 1 0];
				end
			else
				bgColor(1,:) = [1 0 0];
			end
			disp([roiFile,' has ',num2str((1-fH)*100),'% indices in right hemisphere'])
		end
		if strcmp(ROIlist{i},'V1')
			[xMin,iMin] = min(VL(roi.ROI.meshIndices(kH),1));
			iMin = find(kH,iMin);
			iMin = roi.ROI.meshIndices(iMin(end));
			[thetaLeft,phiLeft] = cart2sph(VL(iMin,1),VL(iMin,2),VL(iMin,3));
			fprintf('Left  fovea: theta = %0.1f, phi = %0.1f\n',thetaLeft*180/pi,phiLeft*180/pi)
		end
	else
		disp([roiFile,' not found.'])
		bgColor(1,:) = [1 0 0];
	end
	
	% Right hemisphere
	roiFile = fullfile(anatDir,subjid,'Standard','meshes','ROIs',[ROIlist{i},'-R.mat']);
	if exist(roiFile,'file')
		roi = load(roiFile);
		rgb = color2rgb(roi.ROI.color);
		badColor(2) = norm( rgb - ROIcolor(i,:) ) > threshColor;
		if badColor(2);
			disp([roiFile,' is wrong color'])
		end
		rgb = ROIcolor(i,:);
		roi.ROI.meshIndices = roi.ROI.meshIndices - 10242;
		kH = roi.ROI.meshIndices >= 1;
		if all( kH )
			cR(roi.ROI.meshIndices,:) = repmat( rgb, numel(roi.ROI.meshIndices), 1 );
		elseif ~any( kH )
			disp([roiFile,' is in wrong hemisphere'])
			bgColor(2,:) = [1 0 0];
		else
			fH = sum(kH)/numel(kH);
			if fH >= threshH
				cR(roi.ROI.meshIndices(kH),:) = repmat( rgb, sum(kH), 1 );
				if ~all( bgColor(2,:) == [1 0 0] )
					bgColor(2,:) = [1 1 0];
				end
			else
				bgColor(2,:) = [1 0 0];
			end
			disp([roiFile,' has ',num2str((1-fH)*100),'% indices in left hemisphere'])
		end
		if strcmp(ROIlist{i},'V1')
			[xMax,iMax] = max(VR(roi.ROI.meshIndices(kH),1));
			iMax = find(kH,iMax);
			iMax = roi.ROI.meshIndices(iMax(end));
			[thetaRight,phiRight] = cart2sph(VR(iMax,1),VR(iMax,2),VR(iMax,3));
			fprintf('Right fovea: theta = %0.1f, phi = %0.1f\n',thetaRight*180/pi,phiRight*180/pi)
		end
	else
		disp([roiFile,' not found.'])
		bgColor(2,:) = [1 0 0];
	end
end

rx = mean([phiLeft,phiRight]);	%-pi/6;
if rx ~= 0
	Rx = [ 1 0 0; 0 cos(rx) sin(rx); 0 -sin(rx) cos(rx) ];
	VL = VL*Rx;
	VR = VR*Rx;
end

rz = pi/6;
if rz ~= 0 && isempty(strfind(surf,'sphere'))
	VL = VL*[ cos( rz) sin( rz) 0; -sin( rz) cos( rz) 0; 0 0 1 ];
	VR = VR*[ cos(-rz) sin(-rz) 0; -sin(-rz) cos(-rz) 0; 0 0 1 ];
end


fig = findobj('Type','figure','Tag','ViewMeshROIs.m');
if isempty(fig)
	fig = figure('Units','pixels','Position',[100 600 1000 500],'Tag','ViewMeshROIs.m');
else
	fig = fig(1);
	clf(fig)
	figPos = get(fig,'Position');
	if ~all(figPos(3:4)==[1000 500])
		figPos(3:4) = [1000 500];
		set(fig,'Position',figPos)
	end
end
[ax,H] = deal(zeros(1,2));
ax(1) = axes('position',[0.10 0.1 0.4 0.8]);	% subplot(121);
	H(1) = patch('Vertices',VL,'Faces',D.msh.data.triangles([3 2 1],kL)'+1,'FaceVertexCData',cL);
	title('Left','FontWeight','bold')
	zlabel(subjid,'FontWeight','bold','FontSize',16)
ax(2) = axes('position',[0.55 0.1 0.4 0.8]);	% subplot(122);
	H(2) = patch('Vertices',VR,'Faces',D.msh.data.triangles([3 2 1],kR)'+(1-10242),'FaceVertexCData',cR);
	title('Right','FontWeight','bold')
set(ax,'DataAspectRatio',[1 1 1],'View',[0 0],'Box','on')
if isempty(strfind(surf,'sphere'))
	yzMin = min([VL(:,2:3);VR(:,2:3)]);
	yzMax = max([VL(:,2:3);VR(:,2:3)]);
	set(ax,'YLim',[yzMin(1)-5 yzMax(1)+5],'ZLim',[yzMin(2)-5 yzMax(2)+5])
	set(ax(1),'XLim',[min(VL(:,1))-5 max(VL(:,1))+5])
	set(ax(2),'XLim',[min(VR(:,1))-5 max(VR(:,1))+5])
else
	set(ax,'XLim',[-110 110],'YLim',[-110 110],'ZLim',[-110 110])
	set(ax,'XTick',[],'YTick',[],'ZTick',[])
end
set(ax(1),'Color',bgColor(1,:)/(1+badColor(1)))
set(ax(2),'Color',bgColor(2,:)/(1+badColor(2)))

set(H,'FaceColor','interp','EdgeColor',repmat(0.25,1,3))
if false
	axes(ax(1)),light('Style','local','Position',[ 100 -1000 0],'Color',[1 1 1])
	axes(ax(2)),light('Style','local','Position',[-100 -1000 0],'Color',[1 1 1])
	set(H,'FaceLighting','gouraud','EdgeLighting','none',...
		'SpecularExponent',20,'SpecularStrength',0.5,'DiffuseStrength',0.75,'AmbientStrength',0.25,'BackFaceLighting','lit')
end

set(fig,'Color','w')
imgDir = fullfile(mriDir,'anatomy','jpegs','sphereROIs');
if writeJPG && isdir(imgDir)
	F = getframe(fig);
	imgFile = fullfile(imgDir,['meshROIs_',subjid,'.jpg']);
	fprintf('writing %s ...',imgFile)
	imwrite(F.cdata,imgFile,'jpg','Quality',100)
	fprintf('done\n')
end

return

%% complete head model list
% [1,3:5,9,17,35:37,39,44,47:59,62:64,66,69,71,73:79,81:82,84,93:97,99:103,112,116,122,125,127:129,131]
for i = [122]
	ViewMeshROIs(i,true)
end