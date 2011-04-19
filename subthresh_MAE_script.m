%% Load things

%probeFile = '/Volumes/MRI-1/data/4dImaging/Projects/Kernels/RBTX_9patch/JMA_20080116_RBTX9patch/Polhemus_and_Registration/JMA_01162008_RBTXm&s9patches_snapped.elp'
probeFile = '~/Desktop/HCN_128.sfp';
%probeFile = '/raid/MRI/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Polhemus/spm_MOCOFields_112707.elp'
invFile   = '/Volumes/MRI/data/4dImaging/Projects/JMA/subthreshMAE/JMA/Inverses/jma_subthresh_3shell_MN.inv'
       

%'/Volumes/MRI/data/4dImaging/Projects/Kernels/RBTX_9patch/JMA_20080116_RBTX9patch/EMSE_Inverses/ales_3shell_MinNorm_noconvo_skull_0042.inv';

fwdFile   = '/Volumes/MRI/data/4dImaging/Projects/JMA/subthreshMAE/JMA/forward_model/jma_subthresh_3shell.fwd'


%probe = emse_read_elp(probeFile);
[eloc] = readlocs(probeFile)
eloc = eloc(4:end);

EMSEinv = emseReadInverse(invFile)
EMSEfwd = emseReadForward(fwdFile);
A=EMSEfwd.matrix(1:128,:);

load('/Volumes/MRI/anatomy/ales/Standard/meshes/defaultCortex')
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';

%% Load data
c003 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c003.mat');
c004 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c004.mat');
c005 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c005.mat');
c006 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c006.mat');

c007 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c007.mat');
c008 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c008.mat');
c009 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c009.mat');
c010 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c010.mat');

%c003 = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c003.mat');


%jitterData = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg/Axx_c004.mat');
%otherAdaptData = load('/Users/ales/data/MAE/subthreshold/Exp_MATL_HCN_128_Avg_adapt2/Axx_c003.mat');

%%
roiDir = '/Volumes/MRI/anatomy/ales/Standard/meshes/ROIs/';
roiList = dir([roiDir '*.mat']);

%areas2Lump = {V1R V1L V2DR V2VR V2DL V2VL V3AR V3AL V4R V4L MTR MTL LOCR LOCL};

nAreas = length(roiList);
%length(areas2Lump);

%The chunker matrix maps the full A on 128x20k to 128xnAreas
functionalChunker = zeros(length(A),nAreas);

for iArea=1:nAreas,
    thisROI = load([roiDir roiList(iArea).name]);
    thisROI.ROI.comment;
    thisROIvertices = thisROI.ROI.meshIndices(find(thisROI.ROI.meshIndices>0));
    thisArea = thisROIvertices;
    ctxList = sparse(zeros(length(ctx.vertices),1));
    ctxList(thisArea) = 1;
    functionalChunker(:,iArea) = ctxList;
end

%funcAreas = (size(anatChunker,2)+1):nAreas;


%%

MN60 = normalizedMNE(A,0,60);


MN30 = normalizedMNE(A,0,30);

MN20 = normalizedMNE(A,0,20);

MN15 = normalizedMNE(A,0,15);

MN10 = normalizedMNE(A,0,10);

%% Make a geometrically chunking matrix
nTiles = 1600;

geomChunker = geometryChunk(ctx,nTiles);

Ageom = A*geomChunker;
for i=1:nTiles,
       Ageom(:,i) = Ageom(:,i)/norm(Ageom(:,i));
end

gMN = normalizedMNE(A*geomChunker,0,30);

%% Choose which chunker matrix to use

chunker = geomChunker;%functionalChunker;%[anatChunker functionalChunker];
nAreas = size(chunker,2);

%% Normalize power per area;


%Compute chunked matrix and normalize the power for each area
%this makes areas equally probably regardless of their area;

Achunk = A*chunker;

for i=1:nAreas,
       Achunk(:,i) = Achunk(:,i)/norm(Achunk(:,i));
end

AchunkFull = Achunk;

%%
nTimes = 48;
n = size(Achunk,2);
freqs2keep = 2;
nFreqs=length(freqs2keep);

fullFreq = dftmtx(nTimes);
freqChunk = fullFreq(freqs2keep+1,:);

iDFT = conj(freqChunk)/nTimes/2;

data =jitterData.Wave';


fData = (data*freqChunk.')/nTimes/2;
    
idx=1;


lambda =.25;
mu = 2*lambda*(1/n);
cvx_begin
    variable x(n,nFreqs) complex
    cvx_precision default
    
    minimize( norm(Achunk*x-fData,'fro')+lambda*norm(x,1)); 
    %+mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
%minimize(norm(x,1))
    
%subject to
 %     abs(x)<=1.2
%      norm(Achunk*x-data,'fro')<=1.2
%      norm(Achunk*x-data,'fro')>=1.13
%      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
%      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end










%% Plot Stuff


figure(10)
topoplot(jitterData.Amp(37,:),eloc(1:128),'maplimits',[0 1.25],'electrodes','on','emarker',{'o','k',20,2});
colormap(tmap)
colorbar
ylabel('Spectral Amplitude (uV)');
title('Test alone, Second Harmonic, No adaptation');

figure(11)
topoplot(adaptData.Amp(37,:),eloc(1:128),'maplimits',[0 1.25],'electrodes','on','emarker',{'o','k',20,2});
colormap(tmap)
colorbar
ylabel('Spectral Amplitude (uV)');
title('Test alone, Second Harmonic, After adaptation');

figure(20)
topoplot(jitterData.Amp(19,:),eloc(1:128),'maplimits',[0 .8],'electrodes','on','emarker',{'o','k',20,2});
colormap(tmap)
colorbar
ylabel('Spectral Amplitude (uV)');
title('Test alone, First Harmonic, No adaptation');

figure(21)
topoplot(adaptData.Amp(19,:),eloc(1:128),'maplimits',[0 .8],'electrodes','on','emarker',{'o','k',20,2});
colormap(tmap)
colorbar
ylabel('Spectral Amplitude (uV)');
title('First Harmonic, After adaptation');

%%
flist = 0:.5:53.5;

figure(30)
bar(flist,jitterData.Amp(:,75),.5);
axis([-.50 53.5 0 1.5]);
shading flat

figure(31)
bar(flist,adaptData.Amp(:,75),.5);
axis([-.50 53.5 0 1.5]);
shading flat




%%

flist = 0:.5:53.5;
elec = 75;
sigList = [37 73];


figure(40)
clf
bar(flist,c003.Amp(:,elec),.5,'w');
axis([-.50 53.5 0 1.0]);
hold on;
bar(flist(sigList),c003.Amp(sigList,elec),.02,'k');
axis([-.50 53.5 0 1.0]);

figure(41)
clf
bar(flist,c007.Amp(:,elec),.5,'w');
axis([-.50 53.5 0 1.0]);
hold on;
bar(flist(sigList),c007.Amp(sigList,elec),.02,'k');
axis([-.50 53.5 0 1.0]);


