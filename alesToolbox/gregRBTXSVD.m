%% harvest data, inverse, & elp-file from mrC project
%clear
% mrCproj = 'Y:\projects\nicholas\mrCurrent\MNEstyle';
% mrCproj = 'Z:\data\4D2\STER_CentSur';
%mrCproj = '/Volumes/MRI/data/4D2/RBTX_GV_4D2/RBTX1011';
%mrCproj = '/Volumes/MRI-1/4D2/RBTX_GV_4D2/VRN';

%Not really mrCurrent, but whatever
mrCproj = '/Volumes/Babylab Backup HD/Greg/RBTX1/_matFiles_forGratingVernier'


for iCond = 1:8,
    condList{iCond} = ['Axx_c00' num2str(iCond) '.mat'];
end

%condList = {'Axx_c005.mat' 'Axx_c006.mat'};

stackedData = [];

idx = 0;

firstTime = true;
for iSubj = 1:length(subjList)
    
%subjid = 'skeri0047';
subjid = subjList(iSubj).name

for iCond = 1:length(condList),
    
    thisCond = condList{iCond};
    
%E = load(fullfile(mrCproj,subjid,'Exp_MATL_HCN_128_Avg','Axx_c007.mat'),'Wave','nT','dTms');
datFile = fullfile(mrCproj,subjid,'Export_mtg1.mat',thisCond);

if ~exist(datFile,'file')
    disp(['Missing condition: ' thisCond ' in subject: ' subjid ])
    continue;
end


E = load(datFile);

nElec =  E.nCh;


harmList = [E.i1F1 2*E.i1F1 E.i1F2 2*E.i1F2  (E.i1F1+E.i1F2)]+1;

loadSpec = true;
if (loadSpec)
    t = (0:E.nFr-1)*E.dFHz;
    E = complex( E.Cos, E.Sin);
else  
    t = (1:E.nT)*E.dTms;
    E = E.Wave;
end

for iHarm = 1:length(harmList),
    
k=harmList(iHarm);


if firstTime == true,
    
    u = nan(length(subjList),length(condList),length(harmList),2,2);
    s = nan(length(subjList),length(condList),length(harmList),2,2);
    v = nan(length(subjList),length(condList),length(harmList),nElec,2);
 firstTime = false;
end




[u(iSubj,iCond,iHarm,:,:) s(iSubj,iCond,iHarm,:,:) v(iSubj,iCond,iHarm,:,:)] = svd([real(E(k,:)); imag(E(k,:))],'econ');


if iSubj>1,

    for iComp = 1:2,
        if sign(dot(squeeze(v(1,iCond,iHarm,:,iComp)),squeeze(v(iSubj,iCond,iHarm,:,iComp))))<0;
            v(iSubj,iCond,iHarm,:,iComp) = -v(iSubj,iCond,iHarm,:,iComp);
            u(iSubj,iCond,iHarm,:,iComp) = -u(iSubj,iCond,iHarm,:,iComp);
            disp(['Flipping ' thisCond ' ' num2str(iHarm)])
        end
    end

end


% fullData(iSubj,iCond,:,:) = [real(E(k,:)); imag(E(k,:))];
% 
% theseIdx = [1:128] + (idx)*128;
% dataT(:,theseIdx) = E(k,:)'*E(k,:);
% dataCmplx(iSubj,iCond,:,:) = E(:,:);
% idx = idx+1;


% roiDir = fullfile('/Volumes/MRI/anatomy',subjid,'Standard/meshes/ROIs/');
% [roiInfo] = getRoisByType(roiDir,'func')
% 
% srcFile = ['/Volumes/MRI/anatomy/FREESURFER_SUBS/' subjid '_fs4/bem/' subjid '_fs4-ico-5p-src.fif'];
% fwdFile = fullfile(mrCproj,subjid,'_MNE_',[subjid '-fwd.fif']);
% 
% fwd = mne_read_forward_solution(fwdFile);
% srcSpace = mne_read_source_spaces(srcFile);
% fwdMatrix = makeForwardMatrixFromMne(fwd,srcSpace);
% 
% for iRoi = 1:length(roiInfo)
%     simTopo(iSubj,iRoi).name = roiInfo(iRoi).name;
%     simTopo(iSubj,iRoi).data = sum(fwdMatrix(:,[roiInfo(iRoi).meshIndices]),2);
% end

end

end
end


%%
clf
theseTopos = squeeze(mean(vG(:,1,:,:),1));

for i=1:2,
subplot(2,1,i)
idx = idx+1;
x(idx) = patch('vertices',V(1:128,:),'faces',F,'facecolor','interp');
set(x(idx),'facevertexcdata',theseTopos(:,i));
axis tight
axis off
end

subplot(2,1,1);
title('2f1 c007 PC1');
subplot(2,1,2);
title('2f1 c007 PC2');


%%
I = dir(fullfile(mrCproj,subjid,'Inverses','*.inv'));
if numel(I)==1
	I = mrC_readEMSEinvFile(fullfile(mrCproj,subjid,'Inverses',I(1).name));
else
	I = mrC_readEMSEinvFile(fullfile(mrCproj,subjid,'Inverses',I(menu('Pick inverse',{I.name})).name));
end
V = dir(fullfile(mrCproj,subjid,'Polhemus','*.elp'));
if numel(V)==1
	V = mrC_readELPfile(fullfile(mrCproj,subjid,'Polhemus',V(1).name),true,[-2 1 3]);
else
	V = mrC_readELPfile(fullfile(mrCproj,subjid,'Polhemus',V(menu('Pick elp-file',{V.name})).name),true,[-2 1 3]);
end
flatten = true;
if flatten
	V(:,1:2) = flattenz(V);
	V(:,3) = 0;
end
F = mrC_EGInetFaces(false);
kROI = false(1,20484);


disp('calculating inverse inverses...')
tic
% X1 = (E*I) \ E;					% fewest non-zero components (~32s)
% X2 = pinv(E*I) * E;				% minimum norm (~49s) - looks better
X = pinv(I);						% Justin's choice
toc


mapFcn = @(x,k,g) (x/max(abs(E(k,:)))*g+1)*255/2+1;

ax = zeros(1,4);
H = zeros(1,2);
clf
colormap(jet(256))
for i = [4 2]
	ax(i) = subplot(2,2,i);
	H(i/2) = patch('vertices',V(1:128,:),'faces',F,'facevertexcdata',ones(128,1),'facecolor','interp','CDataMapping','scaled');
end
set(ax([2 4]),'dataaspectratio',[1 1 1],'view',[0 90*flatten])
ax(3) = subplot(223);
ax(1) = subplot(221);
	plot(t,E),grid
	title('Data')
	
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





%% Animate
cmplXRecon = gain*((E(k,:)*I(:,kROI)*X(kROI,:))).';
for i=0:.1:2*pi,
    set(H(1),'facevertexcdata',(cos(i)*real(E(k,:))+sin(i)*imag(E(k,:))).');
    set(H(2),'facevertexcdata',(cos(i)*real(cmplXRecon)+sin(i)*imag(cmplXRecon)));
    pause(.1);
    drawnow;
end

