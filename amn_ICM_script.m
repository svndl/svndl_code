%% Load things

probeFile='~/Desktop/HCN_128.sfp'
%probeFile = '/raid/MRI/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Polhemus/spm_MOCOFields_112707.elp'
invFile = '/Volumes/MRI-1/data/4dImaging/Projects/JMA/ICM/AMN_ICMadd/FFTs/3ShellMinNorm_n=10-20Hz0.0042S.inv'
fwdFile = '/Volumes/MRI-1/data/4dImaging/Projects/JMA/ICM/AMN_ICMadd/Forward_models/amn_3shell_sc0042.fwd'

%probe = emse_read_elp(probeFile);
[eloc] = readlocs(probeFile)
eloc = eloc(4:end);

EMSEinv = emseReadInverse(invFile)
EMSEfwd = emseReadForward(fwdFile);
A=EMSEfwd.matrix(1:128,:);

load('/Volumes/MRI/anatomy/norcia/Standard/meshes/defaultCortex')
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';



%%
roiDir = '/Volumes/MRI-1/anatomy/norcia/Standard/meshes/ROIs/';
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

funcAreas = (size(anatChunker,2)+1):nAreas;






%% Calculate inverses
A = EMSEfwd.matrix(1:128,:);
%A=mcpFwd.matrix(1:128,:);
AAt = A*A';

Ginv = pinv(AAt);
Ginv_sq = Ginv^2;
sloretaInv = zeros(size(EMSEfwd.matrix(1:128,:)));
dwMN = zeros(size(EMSEfwd.matrix(1:128,:)));
MN = zeros(size(EMSEfwd.matrix(1:128,:)));


%No weight
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    MN(:,i) = [Ginv*A(:,i)];
end



%Do sLoreta norm
%for i=1:length(EMSEfwd.matrix(1:128,:)), 
%    sloretaInv(:,i) = [Ginv*A(:,i)./sqrt(A(:,i)'*Ginv*A(:,i))];
%end


%%Do weight normalized
%for i=1:length(EMSEfwd.matrix(1:128,:)), 
%    dwMN(:,i) = [Ginv*A(:,i)./sqrt(A(:,i)'*(Ginv_sq)*A(:,i))];
%end


tic
lambda = 1e6;
%Regularized forward
Ginv_reg = pinv(AAt+eye(size(AAt))*lambda,.01);
%Ginv_reg_sq = pinv((AAt+eye(size(AAt))*lambda).^2);
Ginv_reg_sq = pinv( (AAt+eye(size(AAt))*lambda)^2,.01);

%Regularized Min NOrm
regMN = zeros(size(EMSEfwd.matrix(1:128,:)));
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    regMN(:,i) = [Ginv_reg*A(:,i)];
end
toc

%Regularized weight normalized Min NOrm
regdwMN = zeros(size(EMSEfwd.matrix(1:128,:)));
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    regdwMN(:,i) = [Ginv_reg*A(:,i)./sqrt(A(:,i)'*(Ginv_reg_sq)*A(:,i))];
end

%regsloretaInv = zeros(size(EMSEfwd.matrix(1:128,:)));
%Do Regularized sLoreta norm
%for i=1:length(EMSEfwd.matrix(1:128,:)), 
%    regsloretaInv(:,i) = [Ginv_reg*A(:,i)./sqrt(A(:,i)'*Ginv_reg*A(:,i))];
%end



%% Enforce Source Covariance

spSourceList = sparse(ctxSimulate);
spCov = spSourceList*spSourceList';

%Make covariance matrix

areas2Lump = {V1R V1L V2DR V2VR V2DL V2VL V3AR V3AL V4R V4L MTR MTL LOCR LOCL};
spCov = .1*speye(length(A));


for iArea=1:length(areas2Lump),
    
    thisArea = areas2Lump{iArea};
    ctxList = sparse(zeros(length(msh.data.vertices),1));
    ctxList(thisArea) = 1;
    spCov=spCov + ctxList*ctxList';
end


R=spCov;

ARAt = A*R*A';
RA = R*A';
RA = RA';
lambda = 1e7;
%noiseEst = eye(size(AAt))*lambda
noiseEst = noiseCov*3e5;
%Regularized, covariance weighted, forward
Ginv_reg = pinv(ARAt+noiseEst,.01);



covWeight = zeros(size(EMSEfwd.matrix(1:128,:)));

for i=1:length(EMSEfwd.matrix(1:128,:)), 
    covWeight(:,i) = [Ginv_reg*RA(:,i)];
end



%% Do Forward

%dataROI = sum(EMSEfwd.matrix(1:128,:).*ctxSimulate,2);
dataROI = EMSEfwd.matrix(1:128,:)*ctxSimulate;

dataMT = EMSEfwd.matrix(1:128,:)*MTSimulate;
dataV1 = EMSEfwd.matrix(1:128,:)*V1Simulate;


solution = EMSEinv.matrix*dataROI;
nrmFwd = zeros(size(EMSEfwd.matrix(1:128,:)));
%for i=1:length(EMSEfwd.matrix(1:128,:)), nrmFwd(:,i) = EMSEfwd.matrix(1:128,i)./norm(squeeze(EMSEfwd.matrix(1:128,i)));end



%jmaSol = pinv(A)*dataROI;
jmaSol = regMN'*dataROI;

%jmaSol = [dataROI\A]';
prior = randn(size(solution));

%% Plot
offset=160;
figure(1+offset);
clf
patch(ctx,'faceVertexCData',ctxSimulate,'facecolor','interp')
axis equal
title('Active Sources')


figure(2+offset);
clf
patch(ctx,'faceVertexCData',solution,'facecolor','interp')
axis equal
title('EMSE Solution')


figure(3+offset)
clf
topoplot(dataROI,eloc(:),'electrodes','on','style','map','conv','on','maplimits','maxmin')
title('electrode Data')

figure(4+offset);
clf
patch(ctx,'faceVertexCData',jmaSol,'facecolor','interp')
axis equal
title(['Regularized MN, lambda = ' num2str(lambda,2) ])




%% Make movie

mapl = [min(filtReal_RAF(:)) max(filtReal_RAF(:))];
for i=1:180,
    subplot(1,4,1);
    topoplot(filtReal_RAF(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Real')
    subplot(1,4,2);
    topoplot(filtMot_RAF(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl/2);
    title('Ill Mot');
    subplot(1,4,3);
    topoplot(filtFlic_RAF(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl/2);
    title('Flicker')
    subplot(1,4,4);
    topoplot(filtAdd_RAF(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl/2);
    title('Additive')

    drawnow
    
end


%% Make REB movie 

mapl = [min(filtMot_REB(:)) max(filtMot_REB(:))];
for i=1:180,
    subplot(1,2,1);
    topoplot(filtMot_REB(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl/2);
    title('Ill Mot');
    subplot(1,2,2);
    topoplot(filtFlic_REB(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl/2);
    title('Flicker')
  
    drawnow
    
end
    
    
%% Make RCS movie 

mapl = [min(filtReal_RCS(:)) max(filtReal_RCS(:))];
for i=1:180,
    subplot(1,4,1);
    topoplot(filtReal_RCS(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Real')
    subplot(1,4,2);
    topoplot(filtMot_RCS(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl*1e-6);
    title('Ill Mot');
    subplot(1,4,3);
    topoplot(filtFlic_RCS(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl*1e-6);
    title('Flicker')
    subplot(1,4,4);
    topoplot(filtAdd_RCS(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl*1e-6);
    title('Additive')

    drawnow
    
end

%% Make CHM movie

mapl = [min(filtReal_CHM(:)) max(filtReal_CHM(:))];
for i=1:180,
    subplot(1,4,1);
    topoplot(filtReal_CHM(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Real')
    subplot(1,4,2);
    topoplot(filtMot_CHM(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Ill Mot');
    subplot(1,4,3);
    topoplot(filtFlic_CHM(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Flicker')
    subplot(1,4,4);
    topoplot(filtAdd_CHM(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits',mapl);
    title('Additive')

    drawnow
    
end
      
%% load AMN data
cd /Users/ales/data/ICM/AMN/Exp_MATL_HCN_128_Avg_Btn/

c101AMN = load('Axx_c101.mat')
c104AMN = load('Axx_c104.mat')
c201AMN = load('Axx_c201.mat')
c202AMN = load('Axx_c202.mat')
c203AMN = load('Axx_c203.mat')
c204AMN = load('Axx_c204.mat')

%% Filter data

filtBin=[4];
filtReal_AMN = pdFilter(c104AMN.Wave(:,:),[ filtBin ]);
filtMot_AMN  = pdFilter(c101AMN.Wave(:,:),[ filtBin ]);
filtFlic_AMN = pdFilter(c201AMN.Wave(:,:),[ filtBin ]);
filt203_AMN  = pdFilter(c203AMN.Wave(:,:),[filtBin]);
filt202_AMN  = pdFilter(c202AMN.Wave(:,:),[filtBin]);

filtAdd_AMN = filt202_AMN+filt203_AMN;
%% Make AMN movie

mapl = [min(filtReal_AMN(:)) max(filtReal_AMN(:))];
mapl = [min(filtReal_AMN(:)) max(filtReal_AMN(:))];
for i=1:180,
    subplot(1,4,1);
    topoplot(filtReal_AMN(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits','absmax');
    title('Real')
    subplot(1,4,2);
    topoplot(filtMot_AMN(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits','absmax');
    title('Ill Mot');
    subplot(1,4,3);
    topoplot(filtFlic_AMN(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits','absmax');
    title('Flicker')
    subplot(1,4,4);
    topoplot(filtAdd_AMN(i,:),eloc(:),'electrodes','on','style','map','conv','on','maplimits','absmax');
    title('Additive')

    drawnow
    
end
%% Make AMN ctx movie

figure(10);
clf
ctxH1 = patch(ctx,'faceVertexCData',zeros(length(ctx.vertices),1),'facecolor','interp');

figure(11);
clf
ctxH2 = patch(ctx,'faceVertexCData',zeros(length(ctx.vertices),1),'facecolor','interp');


%%
%mapl=[-2e-9 2e-9];
thisTimeMot=MN'*filtReal_AMN(:,:)';
thisTimeFlic=600*EMSEinv.matrix*filtReal_AMN(:,:)';

mapl = [min(thisTimeMot(:)) max(thisTimeMot(:))];
mapl2 = [min(thisTimeFlic(:)) max(thisTimeFlic(:))];
for i=1:180,
    %thisTimeMot=EMSEinv.matrix*filtMot_AMN(i,:)';
    thisTimeMot=MN'*filtReal_AMN(i,:)';

    thisTimeFlic=600*EMSEinv.matrix*filtReal_AMN(i,:)';
    set(ctxH1,'faceVertexCData',thisTimeMot);
    set(ctxH2,'faceVertexCData',thisTimeFlic);
    caxis(get(ctxH1,'parent'),mapl);
    caxis(get(ctxH2,'parent'),mapl2);
    drawnow;
end


%% Make a geometrically chunking matrix
nTiles = 800;

[geomChunker vertInd apa] = geometryChunk(ctx,nTiles);

Ageom = A*geomChunker;
for i=1:nTiles,
       Ageom(:,i) = Ageom(:,i)/norm(Ageom(:,i));
end

%% Choose which chunker matrix to use

chunker = [functionalChunker(:,[5 6 9:20])];
nAreas = size(chunker,2);

%% Normalize power per area;


%Compute chunked matrix and normalize the power for each area
%this makes areas equally probably regardless of their area;

Achunk = A*chunker;

for i=1:nAreas,
       Achunk(:,i) = Achunk(:,i)/norm(Achunk(:,i));
       norm(Achunk(:,i));
end

AchunkFull = Achunk;
Anorm = A;

for i=1:length(A),
       Anorm(:,i) = A(:,i)/norm(A(:,i));
end


%% This stuff for testing various optimization methods, requires CVX
%% Calculate inverses%A=mcpFwd.matrix(1:128,:);
thisA = Anorm;
AAt = thisA*thisA';

[u s v] = svd(AAt);
tol = length(AAt)*s(1)*eps('single')
tol = s(50,50);

sum(diag(s)>tol)

Ginv = pinv(AAt,tol);
Ginv_sq = Ginv^2;

MN = zeros(size(thisA));
nAreas=size(thisA,2);


%No weight
for i=1:nAreas, 
    MN(:,i) = [Ginv*thisA(:,i)];
end
%MN = [chunker*MN']';
%%
data = 1e6*c201AMN.Wave(:,:)';
%10e12*filtReal_AMN';

n= nAreas;
nFreqs = 1;
nTimes = 180;
fullFreq = dftmtx(nTimes);
freqChunk = fullFreq(filtBin+1,:);


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


lambda =.1;
mu = 2*lambda*(1/n);
cvx_begin
    cvx_precision default
    variable x(nAreas,nFreqs) complex
    
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



%% L1 norm test

A=EMSEfwd.matrix(1:128,:);

n=length(A);
% 
% % cvx version
% cvx_begin
%     variable x(n);
%     minimize( norm(x,1));
%     subject to
%         dataROI==A*x;
%             
%     norm(A*x-dataROI,1) );
% cvx_end



% Solve the Basis Pursuit problem
disp('Solving Basis Pursuit problem...');
tic
cvx_begin
    variable x(n)
    minimize(sum_square(A*x-dataROI)+norm(x,1))
cvx_end
disp('done');
toc



%% Solve the minimum L2 norm
disp('Solving min-L2 problem...');
tic
SNR=.01;
cvx_begin
    variable x2(n)
    minimize(norm(x2,2))
    subject to
       dataROI-A*x2<=SNR;
cvx_end
disp('done');
toc


%% Solve the minimum L1 norm
disp('Solving min-L1 problem...');
tic
SNR=2e8;
cvx_begin
    variable x1(n)
    minimize(norm(x1,1))
    subject to
       norm(dataROI-A*x1,2)==0;
cvx_end
disp('done');
toc


%% Solve the minimum L1 norm
disp('Solving min-L1 problem...');
tic
SNR=2e8;
gamma = 3;
cvx_begin
    variable xr(n)
    minimize(norm(dataROI-A*xr,2)+gamma*norm(xr,1))
cvx_end
disp('done');
toc



%}