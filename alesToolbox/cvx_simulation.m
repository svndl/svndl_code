%% Prepare simulation for CVX, define various constants here



anatomicalRoiDir = '/Volumes/MRI/anatomy/ales/meshes/ROIs/anatomical/';
functionalRoiDir = '/Volumes/MRI/anatomy/ales/Standard/meshes/ROIs/';

load('/Volumes/MRI/anatomy/ales/Standard/meshes/defaultCortex')
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';


probeFile='~/Desktop/HCN_128.sfp'
%probeFile = '/raid/MRI/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Polhemus/spm_MOCOFields_112707.elp'
invFile = '/Volumes/MRI/data/4dImaging/Projects/Kernels/RBTX_9patch/JMA_20080116_RBTX9patch/EMSE_Inverses/ales_3shell_MinNorm_noconvo_skull_0042.inv';
fwdFile = '/Volumes/MRI/data/4dImaging/Projects/Kernels/RBTX_9patch/JMA_20080116_RBTX9patch/EMSE_forward/JMA_3shell_sc0042.fwd';



%probe = emse_read_elp(probeFile);
[eloc] = readlocs(probeFile)
eloc = eloc(4:end);

EMSEinv = emseReadInverse(invFile)
EMSEfwd = emseReadForward(fwdFile);

A=EMSEfwd.matrix(1:128,:);



%% Make anatomical chunking matrix:

roiDir = anatomicalRoiDir;
roiList = dir([roiDir '*.mat']);

%areas2Lump = {V1R V1L V2DR V2VR V2DL V2VL V3AR V3AL V4R V4L MTR MTL LOCR LOCL};

nAreas = length(roiList);
%length(areas2Lump);

%The chunker matrix maps the full A on 128x20k to 128xnAreas
anatChunker = zeros(length(A),nAreas);

for iArea=1:nAreas,
    thisROI = load([roiDir roiList(iArea).name]);
    thisROIvertices = thisROI.ROI.meshIndices(find(thisROI.ROI.meshIndices>0));
    thisArea = thisROIvertices;
    ctxList = sparse(zeros(length(ctx.vertices),1));
    ctxList(thisArea) = 1;
    anatChunker(:,iArea) = ctxList;
end

anatAreas = 1:nAreas;

%% Make functional chunking matrix:

roiDir = functionalRoiDir;
roiList = dir([roiDir '*.mat']);

%areas2Lump = {V1R V1L V2DR V2VR V2DL V2VL V3AR V3AL V4R V4L MTR MTL LOCR LOCL};

nAreas = length(roiList);
%length(areas2Lump);

%The chunker matrix maps the full A on 128x20k to 128xnAreas
functionalChunker = zeros(length(A),nAreas);

for iArea=1:nAreas,
    thisROI = load([roiDir roiList(iArea).name]);
    thisROI.ROI.comment
    thisROIvertices = thisROI.ROI.meshIndices(find(thisROI.ROI.meshIndices>0));
    thisArea = thisROIvertices;
    ctxList = sparse(zeros(length(ctx.vertices),1));
    ctxList(thisArea) = 1;
    functionalChunker(:,iArea) = ctxList;
end

funcAreas = (size(anatChunker,2)+1):nAreas;

%% Make a geometrically chunking matrix
nTiles = 800;

geomChunker = geometryChunk(ctx,nTiles);

Ageom = A*geomChunker;
for i=1:nTiles,
       Ageom(:,i) = Ageom(:,i)/norm(Ageom(:,i));
end


%% Choose which chunker matrix to use

chunker = geomChunker;%[anatChunker functionalChunker];
nAreas = size(chunker,2);

%% Normalize power per area;


%Compute chunked matrix and normalize the power for each area
%this makes areas equally probably regardless of their area;

Achunk = A*chunker;

for i=1:nAreas,
       Achunk(:,i) = Achunk(:,i)/norm(Achunk(:,i));
end

AchunkFull = Achunk;

%% Make the data
noiseLevel =0.01;
nTimes = 10;

%make the temporal structure of the data. 
%For ease of use I'm using the fourier transform matrix based on frequencies that are integer
%multiples of nTimes
timeComps = dftmtx(nTimes);


rand('state',0);
%define the signal areas
%trueX = sprandn(nAreas,1,.05);
trueX = [zeros(size(anatChunker,2),1); sprandn(size(functionalChunker,2),1,.2)];


numSources = sum(abs(trueX)>0);

trueXmat = zeros(nAreas,nTimes);

timeIdx =2;
phaseList = zeros(numSources,1);
nSources = length([find(abs(trueX)>0)]');

for i=[find(abs(trueX)>0)]',
    
    
%trueXmat(i,:) = real(.7071*real(timeComps(timeIdx,:))+.7071*imag(timeComps(timeIdx,:)));

trueXmat(i,:) = real(timeComps(timeIdx,:));

timeIdx = timeIdx +1;

end

%trueX([1 2 11 12],:) =1;
%trueX(3:6,:) =-1;


signal = Achunk*trueXmat;


%define the noise
noise = noiseLevel*randn(size(signal));


data = signal+noise;



%% Mis specify forward model.
Achunk = AchunkFull;
%Achunk = Achunk(:,anatAreas);


nAreas = size(Achunk,2);


%% Do optimization

%Note, when extending to time domain, try modeling each ROI chunk as a
%min phase causal filter, i.e. dphase/dfreq <0;

n= nAreas;
idx=1;

lambda =.02;
mu = 0.002;
cvx_begin
    variable x(nAreas,nTimes)
    minimize(norm(Achunk*x-data,'fro')+lambda*norm(x,1)+mu*sum(norms(x(:,1:nTimes-1)-x(:,2:nTimes),2,2)))
    subject to
      abs(x)<1
      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end


%%
n= nAreas;
idx=1;

lambda =1/14;
mu = 2*lambda*(1/n);
cvx_begin
    variable x(nAreas,nTimes)
    cvx_precision medium
    minimize( norm(Achunk*x-data,'fro')+lambda*norm(x,1) +mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
%minimize(norm(x,1))
    
subject to
      abs(x)<=1.2
%      norm(Achunk*x-data,'fro')<=1.2
%      norm(Achunk*x-data,'fro')>=1.13
      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end


%% Fourier constrained

n= nAreas;
nFreqs = 10;
fullFreq = dftmtx(nTimes);
freqChunk = fullFreq(1:10,:);


%reshape(freqChunk,1,:)

%freqAreaChunk = [];
%for iArea=1:nAreas,
%    for iFreq=1:nFreqs,
%    
%        thisFreqAreaChunk = Achunk(:,iArea)*freqChunk(iFreq,:);
%     freqAreaChunk = [freqAreaChunk thisFreqAreaChunk;];
%    end
%end

 %I do NOT want a complex conjugate transpose here, using .' for a good old
 % simple dimension change
fData = data*freqChunk.';
    
idx=1;


lambda =1/14;
mu = 2*lambda*(1/n);
cvx_begin
    variable x(nAreas,nFreqs) complex
    cvx_precision medium
    
    minimize( norm(Achunk*x-fData,'fro')+lambda*norm(x,1)); 
    %+mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
%minimize(norm(x,1))
    
%subject to
%      abs(x)<=1.2
%      norm(Achunk*x-data,'fro')<=1.2
%      norm(Achunk*x-data,'fro')>=1.13
%      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
%      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end

%% Fourier constrained, Tiled Cortex, 

n=size(Ageom,2);
nFreqs = 10;
fullFreq = dftmtx(nTimes);
freqChunk = real(fullFreq(1:10,:));


%reshape(freqChunk,1,:)

%freqAreaChunk = [];
%for iArea=1:nAreas,
%    for iFreq=1:nFreqs,
%    
%        thisFreqAreaChunk = Achunk(:,iArea)*freqChunk(iFreq,:);
%     freqAreaChunk = [freqAreaChunk thisFreqAreaChunk;];
%    end
%end

 %I do NOT want a complex conjugate transpose here, using .' for a good old
 % simple dimension change
fData = (data*freqChunk.')/50;
    
idx=1;


lambda =1;
mu = 2*lambda*(1/n);
cvx_begin
    variable x(n,nFreqs)
    cvx_precision medium
    
    minimize( norm(Ageom*x-fData,'fro')+lambda*norm(x,1)); 
    %+mu*sum(norms(x(:,1:end-1)-x(:,2:end),2,2)))
%minimize(norm(x,1))
    
%subject to
 %     abs(x)<=1.2
%      norm(Achunk*x-data,'fro')<=1.2
%      norm(Achunk*x-data,'fro')>=1.13
%      x(:,1:nTimes-1)-x(:,2:nTimes)>=-.3;
%      x(:,1:nTimes-1)-x(:,2:nTimes)<=.3;
cvx_end


%%



%{
n= nAreas;
idx=1;
for lambda=0:.01:.05;
%lambda =.01;
cvx_begin
    variable x(n)
    minimize(norm(Achunk*x-data)+lambda*norm(x,1))
   % subject to 
   %abs(x)<.5
    
cvx_end

   l1norm = sum(abs(x));
%   nonzero = sum(x>0.01);
   l2norm = norm(Achunk*x-data);

L1(idx)= l1norm;
F(idx) = l2norm;;
%cardi(idx) = nonzero;
idx = idx+1;
end
%}

tic
%Regularized forward
AAt= Achunk*Achunk';

lambda = 0*max(AAt(:));
Ginv_reg = pinv(AAt+eye(size(AAt))*lambda);
%Ginv_reg_sq = pinv((AAt+eye(size(AAt))*lambda).^2);
%Ginv_reg_sq = pinv( (AAt+eye(size(AAt))*lambda)^2,.01);

%Regularized Min NOrm
regMN = zeros(size(Achunk));
for i=1:nAreas; 
    regMN(:,i) = [Ginv_reg*A(:,i)];
end
toc

%l2x = [regMN'*data];
l2x = Achunk\data;
emseSol = EMSEinv.matrix*data;


%% Plot stuff

figure(1)
clf;
plot(trueX, 'r:','linewidth',2);
hold on
plot(x);
plot(l2x,'k');
plot(chunker'*emseSol/norm(chunker'*emseSol),'g')

legend('trueX','L1 Solution','L2 solution','EMSE');

figure(2)
clf;
plot(data,'r:','linewidth',2);
hold on;
plot(Achunk*x)
plot(Achunk*l2x,'k')

plot(A*emseSol,'g')

legend('data','L1 model','L2 model','EMSE model')



figure(3)

clf
patch(ctx,'faceVertexCData',chunker*x,'facecolor','interp')
axis equal
title('L1 solution')


figure(4)

clf
patch(ctx,'faceVertexCData',chunker*l2x,'facecolor','interp')
axis equal
title('L2 solution')



figure(5)

clf
patch(ctx,'faceVertexCData',chunker*trueX,'facecolor','interp')
axis equal
title('True solution')

figure(6)
clf
patch(ctx,'faceVertexCData',emseSol,'facecolor','interp')
axis equal
title('EMSE solution')



%% movies
figure(10)
clf
realSol = chunker*trueXmat;
cvxSol  = geomChunker*real(x*iDft);
%cvxSol = EMSEinv.matrix*data;
cvxSol = regMN'*data;
%%
subplot(1,2,1);
ctx1H = patch('faces',ctx.faces,'vertices',ctx.vertices,'faceVertexCData',realSol(:,1),'facecolor','interp')
caxis([min(realSol(:)) max(realSol(:))]);
axis equal

title('Real Activity')
subplot(1,2,2);
ctx2H = patch('faces',ctx.faces,'vertices',ctx.vertices,'faceVertexCData',cvxSol(:,1),'facecolor','interp')
title('Inverse Solution')
caxis([min(cvxSol(:)) max(cvxSol(:))]);
axis equal

%%    
for i=1:100, 
    set(ctx1H,'faceVertexCData',realSol(:,i));

    set(ctx2H,'faceVertexCData',cvxSol(:,i));
    
    drawnow;
end
