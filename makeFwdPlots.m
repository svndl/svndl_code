%% harvest data, inverse, & elp-file from mrC project
%clear
% mrCproj = 'Y:\projects\nicholas\mrCurrent\MNEstyle';
% mrCproj = 'Z:\data\4D2\STER_CentSur';
%mrCproj = '/Volumes/MRI/data/4D2/RBTX_GV_4D2/RBTX1011';
mrCproj = '/Volumes/MRI-1/4D2/RBTX_GV_4D2/VRN';

%mrCproj = '/Volumes/MRI/data/4D2/L1test';

condList = {'Axx_c005.mat','Axx_c006.mat'};
stackedData = [];

subjList = {'skeri0001'}

freesurfDir = uigetdir('PICK FREESURFER SUBJECTS DIRECTORY');

idx = 0;
for iSubj = 1:length(subjList)
    
%subjid = 'skeri0047';
subjid = subjList{iSubj}

 
roiDir = fullfile('/Volumes/MRI/anatomy',subjid,'Standard/meshes/ROIs/');
[roiInfo] = getRoisByType(roiDir,'func')

srcFile = ['/Volumes/MRI/anatomy/FREESURFER_SUBS/' subjid '_fs4/bem/' subjid '_fs4-ico-5p-src.fif'];
fwdFile = fullfile(mrCproj,subjid,'_MNE_',[subjid '-fwd.fif']);

fwd = mne_read_forward_solution(fwdFile);
srcSpace = mne_read_source_spaces(srcFile);
fwdMatrix = makeForwardMatrixFromMne(fwd,srcSpace);

for iRoi = 1:length(roiInfo)
    simTopo(iSubj,iRoi).name = roiInfo(iRoi).name;
    simTopo(iSubj,iRoi).data = sum(fwdMatrix(:,[roiInfo(iRoi).meshIndices]),2);
end

end


%%

V = dir(fullfile(mrCproj,subjid,'Polhemus','*.elp'));
if numel(V)==1
	V = mrC_readELPfile(fullfile(mrCproj,subjid,'Polhemus',V(1).name),true,[-2 1 3]);
else
	V = mrC_readELPfile(fullfile(mrCproj,subjid,'Polhemus',V(menu('Pick elp-file',{V.name})).name),true,[-2 1 3]);
end
V=V*1000;

flatten = true;
if flatten
	Vflat = flattenz(V);
end
F = mrC_EGInetFaces(false);
kROI = false(1,20484);

figure(4)
clf;

scalpColor = simTopo(14).data;
ctxColor = zeros(1,20484);
ctxColor(roiInfo(14).meshIndices)=1;

scalp = patch('vertices',V(1:128,:)/1000,'faces',F,'facevertexcdata',scalpColor,'facecolor','interp');
ctxH = patch('vertices',ctx.vertices(:,[3 1 2]),'faces',ctx.faces,'facevertexcdata',ctxColor','facecolor','interp')
axis equal

set(renderer,'opengl')

%%

%% pick a time point for topo map
% 	k = ginput(1);
% 	[junk,k] = min(abs(t-k(1)));
%     if loadSpec
%     set(H(1),'facevertexcdata',abs(E(k,:))')
%     set(H(1),'CDataMapping','scaled')
%    % set(ax(2),'CLim',[min(E(k,:)) max(E(k,:))]);
%     
%     else
%     set(H(1),'facevertexcdata',mapFcn(E(k,:)',k,1))
%     end
%     set(get(ax(2),'title'),'string',sprintf('%g ms',t(k)))
% % set(H,'CDataMapping','scaled')

%% plot ROI reconstructions
gain = 2;	% amplify color changes on mesh
kROI(:) = false;
%kROI(:) = true;

ROIlist = {'V1-L','V2D-L','V2V-L','V3D-L','V3V-L','V3A-L','V4-L','MT-L','LOC-L',...
	'V1-R','V2D-R','V2V-R','V3D-R','V3V-R','V3A-R','V4-R','MT-R','LOC-R'};

% ROIlist = ROIlist(logical([ 1 1 0 1 0 1 0 0 0, 1 1 0 1 0 1 0 0 0 ]));
% ROIlist = ROIlist([1 2 4 9 10 11 13 18]);
% ROIlist = ROIlist([1 10])
% ROIlist = ROIlist([7 7+9])

% ROIlist = ROIlist([9 18])
% ROIlist = ROIlist([8 17 ])
 %ROIlist = ROIlist([1 10 8 17 ])
% ROIlist = ROIlist([1 10 ])


for i = 1:numel(ROIlist)
	ROI = getfield(load(fullfile('/Volumes/MRI/anatomy',subjid,'Standard','meshes','ROIs',[ROIlist{i},'.mat'])),'ROI');
	kROI(ROI.meshIndices) = true;
	if i>1
		ROIlist{i} = [', ',ROIlist{i}];
	end
end

% X = X2;
% kROI(:) = ~kROI;
% kROI(:) = true;
    if loadSpec
        set(H(2),'facevertexcdata',gain*abs((E(k,:)*I(:,kROI)*X(kROI,:)))')
        set(H(2),'CDataMapping','scaled')
        fitError = 100*(norm(abs(E(k,:))-abs(E(k,:)*I(:,kROI)*X(kROI,:)),2)/norm(abs(E(k,:)),2))
        
        set(ax(4),'CLim',get(ax(2),'CLim'))
    else
        set(H(2),'facevertexcdata',mapFcn((E(k,:)*I(:,kROI)*X(kROI,:))',k,gain))
        fitError = 100*(norm((E-E*I(:,kROI)*X(kROI,:)),'fro')/norm(E,'fro'))
    end
% set(get(ax(4),'title'),'string',[ROIlist{:}],'fontsize',7)
set(get(ax(4),'title'),'string',sprintf('amplified = %g x',gain))
axes(ax(3))


modelTotal = 100*(norm(E*I(:,kROI),'fro')/norm(E*I,'fro'))

	plot(t,E*I(:,kROI)*X(kROI,:)),grid
	ylim(get(ax(1),'ylim')/gain)
	title(sprintf('ROIs = %0.1f%% of CCD power, fit to data  = %0.1f%% ERROR',modelTotal, fitError));
	text('units','normalized','position',[0 1.15 0],'string',[ROIlist{:}])

    
% [norm(E*I(:,kROI),'fro')^2 norm(E*I(:,~kROI),'fro')^2]/norm(E*I,'fro')^2



end

%% Animate
cmplXRecon = gain*((E(k,:)*I(:,kROI)*X(kROI,:))).';
for i=0:.1:2*pi,
    set(H(1),'facevertexcdata',(cos(i)*real(E(k,:))+sin(i)*imag(E(k,:))).');
    set(H(2),'facevertexcdata',(cos(i)*real(cmplXRecon)+sin(i)*imag(cmplXRecon)));
    pause(.1);
    drawnow;
end

