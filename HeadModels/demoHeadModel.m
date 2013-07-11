%%
clear
clf

subjid = 'skeri0048';
ix = 120;	% zero voxels(1:ix,:,iz:end) in RAS coords
iz = 140;
c1 = 20;		% skin  intensity threshold
c2 = 7+5;		% slice intensity threhold

 skinColor = [1 0.8 0.6];
brainColor = [0.8 0.8 0.6];	%[0 1 0];
skullColor = [1 0 0];

%%
% elpFile = '/raid/MRI/data/4D2/Joon/SpaProf/SpaProf5deg/skeri0128/Polhemus/JK_SpaProf_20110116_1.elp';
% xfmFile = '/raid/MRI/data/4D2/Joon/SpaProf/SpaProf5deg/skeri0128/_MNE_/elp2mri.tran';


%%
try
	A  = readFileNifti( fullfile(SKERIanatDir,subjid,'nifti',[subjid,'_FS4_nu.nii.gz']) );
% 	A  = readFileNifti( fullfile(SKERIanatDir,subjid,'nifti',[subjid,'_nose.nii.gz']) );		c1=200; c2=100;
% 	S  = readFileNifti( fullfile(SKERIanatDir,subjid,'nifti','betsurf_outskull_mask.nii.gz') );
% 	IS = readFileNifti( fullfile(SKERIanatDir,subjid,'nifti','betsurf_inskull_mask.nii.gz') );
catch
	A  = readFileNifti_stable( fullfile(SKERIanatDir,subjid,'nifti',[subjid,'_FS4_orig.nii.gz']) );
% 	S  = readFileNifti_stable( fullfile(SKERIanatDir,subjid,'nifti','headmodel_outskull_mask.nii.gz') );
% 	IS = readFileNifti_stable( fullfile(SKERIanatDir,subjid,'nifti','headmodel_inskull_mask.nii.gz') );
end

% S.data = S.data - IS.data;
% clear IS

% flip LR to RAS
A.data(:) = flipdim(A.data,1);
% S.data(:) = flipdim(S.data,1);
d = size(A.data);

%%
	% put my nose back on
% 	A.data = cat(2,A.data(:,14:238,:),A.data(:,19:32,:));
% 	d(2) = d(2) + 35;
	crop = [ 43-10, 19-0, 18; 216+10, 238+0, 226+10 ];
% 	crop = [ 41-0, 10-0, 42; 217+0, 242+0, 222+10 ];
	A.data = A.data(crop(1,1):crop(2,1),crop(1,2):crop(2,2),crop(1,3):crop(2,3));
	d = size(A.data);
	iz = 115;	% 110...?

%%
A.data(:) = smooth3(A.data,'gaussian',5,2/norminv(0.9));
	
% crop out quadrant of anatomy
% A.data(1:ix,:,iz:d(3)) = 0;
A.data(:,:,iz:d(3)) = 0;

% permute volumes to ARS, so isosurface will output RAS vertices
p = [2 1 3];
% A.data(:) = permute(A.data,p);
% S.data(:) = permute(S.data,p);
A.data = permute(A.data,p);
d = d(p);


%% get patch surfaces
FV1 = isosurface(A.data,c1);

% paint skull solid
% 	A.data = min(A.data,254);
% 	A.data(S.data==1) = 255;

% new colormap for skull
% 	A.data = A.data/2;
% 	A.data(S.data==1) = 128 + A.data(S.data==1);

% FV2 = isocaps(A.data(:,ix+[1 2],iz:d(3)),c2);
% FV3 = isocaps(A.data(:,1:ix,iz-[2 1]),c2);
FV3 = isocaps(A.data(:,:,iz-[2 1]),c2);
% FV2.vertices(:,1) = FV2.vertices(:,1) + (ix - 1);			% shift left 1 so you can see it
% FV2.vertices(:,3) = FV2.vertices(:,3) + (iz - 1);
FV3.vertices(:,3) = FV3.vertices(:,3) + (iz - 3 + 1);		% shift up 1 so you can see it

%% load cortex
decCortex = ~true;
if decCortex
	C = load(fullfile(SKERIanatDir,subjid,'Standard','meshes','defaultCortex.mat'));		% PIR
	C.msh.data.vertices(1:2,:) = 257 - C.msh.data.vertices(1:2,:);
	C.msh.data.vertices(:) = C.msh.data.vertices([3 1 2],:);

	C.msh.data.vertices(1,:) = C.msh.data.vertices(1,:) - (crop(1,1)-1);
	C.msh.data.vertices(2,:) = C.msh.data.vertices(2,:) - (crop(1,2)-1);
	C.msh.data.vertices(3,:) = C.msh.data.vertices(3,:) - (crop(1,3)-1);
else
	surf = 'pial';
	[VL,FL] = freesurfer_read_surf(fullfile(SKERIanatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf',['lh.',surf]));
	[VR,FR] = freesurfer_read_surf(fullfile(SKERIanatDir,'FREESURFER_SUBS',[subjid,'_fs4'],'surf',['rh.',surf]));
	VL = VL + 128;
	VR = VR + 128;
	
	VL(:,1) = VL(:,1) - (crop(1,1)-1);
	VL(:,2) = VL(:,2) - (crop(1,2)-1);
	VL(:,3) = VL(:,3) - (crop(1,3)-1);
	VR(:,1) = VR(:,1) - (crop(1,1)-1);
	VR(:,2) = VR(:,2) - (crop(1,2)-1);
	VR(:,3) = VR(:,3) - (crop(1,3)-1);

end

%%
clf
% colormap([gray(255);skullColor])
% colormap([gray(128);linspace(0,skullColor(1),128)',linspace(0,skullColor(2),128)',linspace(0,skullColor(3),128)'])
colormap([linspace(0.15,1,256)',zeros(256,2)])

H1 = patch(FV1,'FaceColor',skinColor,'EdgeColor','none','FaceLighting','gouraud');
% H2 = patch(FV2,'FaceColor','interp','EdgeColor','none','FaceLighting','none');
H3 = patch(FV3,'FaceColor','interp','EdgeColor','none','FaceLighting','none');
if decCortex
	H4 = patch('Vertices',C.msh.data.vertices','Faces',C.msh.data.triangles([3 2 1],:)'+1);
else
	H4 = [ patch('Vertices',VL,'Faces',FL), patch('Vertices',VR,'Faces',FR) ];
end
set(H4,'FaceColor',brainColor,'EdgeColor','none','FaceLighting','gouraud')

HL = light('Position',[-300 500 600],'Style','infinite','Color',[1 1 1]);

set(gca,'View',[-140 15],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'ZTick',[],...
	'Position',[0 0 1 1],'Color','none','Visible','off')
set(gcf,'color','w')

axis tight

% xlabel('Right'),ylabel('Anterior'),zlabel('Superior')
% title(subjid)


isonormals(A.data,H1)		% slow, marginal improvement?

%%
% xfm = load('-ascii',xfmFile)';
% Ep = mrC_readELPfile(elpFile,true,true,[-2 1 3]);
% Ep = [ Ep*1e3, ones(size(Ep,1),1) ] * xfm(:,1:3);
% H5 = patch('Vertices',Ep+128,'Faces',mrC_EGInetFaces(true),'FaceColor','none','EdgeColor','none',...
% 	'Marker','.','MarkerSize',16,'MarkerEdgeColor','m');

%%
% set(H1,'AmbientStrength',0.3,'DiffuseStrength',0.6,'SpecularStrength',0.9,'SpecularExponent',10)
% set(H1,'AmbientStrength',0.3,'DiffuseStrength',0.6,'SpecularStrength',0.9,'SpecularExponent',10)
set(H1,'AmbientStrength',0.35,'DiffuseStrength',0.65,'SpecularStrength',0.4,'SpecularExponent',8)
set(H4,'AmbientStrength',0.05,'DiffuseStrength',0.90,'SpecularStrength',0.8,'SpecularExponent',6)

%%
disp(datestr(now))