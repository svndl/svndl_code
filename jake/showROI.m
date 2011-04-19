%% harvest data, inverse, & elp-file from mrC project
clear all
% mrCproj = 'Y:\projects\nicholas\mrCurrent\MNEstyle';
mrCproj = 'I:\data\4D2\STER_CentSur';
% mrCproj = '/Volumes/MRI/data/4D2/RBTX_GV_4D2/VRN';

subjid = 'skeri0003';
%E = load(fullfile(mrCproj,subjid,'Exp_MATL_HCN_128_Avg','Axx_c007.mat'),'Wave','nT','dTms');
E = load(fullfile(mrCproj,subjid,'Exp_MATL_HCN_128_Avg','Axx_c005.mat'));

loadSpec = false;
if (loadSpec)
    t = (1:E.nFr)*E.dFHz;
    E = complex( E.Cos, E.Sin); 
else
    t = (1:E.nT)*E.dTms;
    E = E.Wave;
end


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
	V(:,1:2) = flattenZ(V);
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
	k = ginput(1);
	[junk,k] = min(abs(t-k(1)));
    if loadSpec
    set(H(1),'facevertexcdata',abs(E(k,:))')
    set(H(1),'CDataMapping','scaled')
    set(ax(2),'CLim',[min(E(k,:)) max(E(k,:))]);
    
    else
    set(H(1),'facevertexcdata',mapFcn(E(k,:)',k,1))
    end
    set(get(ax(2),'title'),'string',sprintf('%g ms',t(k)))
% set(H,'CDataMapping','scaled')


%% plot ROI reconstructions
gain = 100;	% amplify color changes on mesh
kROI(:) = false;
%kROI(:) = true;

ROIlist = {'V1-L','V2D-L','V2V-L','V3D-L','V3V-L','V3A-L','V4-L','MT-L','LOC-L',...
	'V1-R','V2D-R','V2V-R','V3D-R','V3V-R','V3A-R','V4-R','MT-R','LOC-R'};

% ROIlist = ROIlist(logical([ 1 1 0 1 0 1 0 0 0, 1 1 0 1 0 1 0 0 0 ]));
% ROIlist = ROIlist([1 2 4 9 10 11 13 18]);
 ROIlist = ROIlist([2 3]);
% ROIlist = ROIlist([7 7+9])

for i = 1:numel(ROIlist)
%	ROI = getfield(load(fullfile('/Volumes/MRI/anatomy',subjid,'Standard','meshes','ROIs',[ROIlist{i},'.mat'])),'ROI');
	ROI = getfield(load(fullfile('I:\anatomy',subjid,'Standard','meshes','ROIs',[ROIlist{i},'.mat'])),'ROI');
	kROI(ROI.meshIndices) = true;
	if i>1
		ROIlist{i} = [', ',ROIlist{i}];
	end
end

% X = X2;
% kROI(:) = ~kROI;
% kROI(:) = true;
    if loadSpec
        set(H(2),'facevertexcdata',abs((E(k,:)*I(:,kROI)*X(kROI,:)))')
        set(H(2),'CDataMapping','scaled')
        fitError = 100*(norm(abs(E(k,:))-abs(E(k,:)*I(:,kROI)*X(kROI,:)),2)/norm(abs(E(k,:)),2));
        
        set(ax(2),'CLim',get(ax(2),'CLim'))
    else
        set(H(2),'facevertexcdata',sum(X(kROI,:))');
        fitError = 100*(norm((E-E*I(:,kROI)*X(kROI,:)),'fro')/norm(E,'fro'));
    end
% set(get(ax(4),'title'),'string',[ROIlist{:}],'fontsize',7)
set(get(ax(2),'title'),'string',sprintf('amplified = %g x',gain))
axes(ax(3))


modelTotal = 100*(norm(E*I(:,kROI),'fro')/norm(E*I,'fro'));

	plot(t,E*I(:,kROI)*X(kROI,:)),grid
	ylim(get(ax(1),'ylim')/gain)
	title(sprintf('ROIs = %0.1f%% of CCD power, fit to data  = %0.1f%% ERROR',modelTotal, fitError));
	text('units','normalized','position',[0 1.15 0],'string',[ROIlist{:}])

    
% [norm(E*I(:,kROI),'fro')^2 norm(E*I(:,~kROI),'fro')^2]/norm(E*I,'fro')^2
