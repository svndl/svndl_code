%% Load things

probeFile='~/Desktop/HCN_128.sfp'
%probeFile = '/raid/MRI/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Polhemus/spm_MOCOFields_112707.elp'


invFile = '/Volumes/MRI-1/data/4dImaging/Projects/Kernels/RBTX_9patch/VV_20070130_RBTX_9patch/EMSE_Inverses/EMSE_MN_3shell.inv'
fwdFile = '/Volumes/MRI-1/data/4dImaging/Projects/Kernels/RBTX_9patch/VV_20070130_RBTX_9patch/EMSE_Forward/VV_3shell_sc0042.fwd'


%probe = emse_read_elp(probeFile);
[eloc] = readlocs(probeFile)
eloc = eloc(4:end);

EMSEinv = emseReadInverse(invFile)
EMSEfwd = emseReadForward(fwdFile);
load('/Volumes/MRI/anatomy/vildavski/Standard/meshes/defaultCortex')
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';




%% Calculate inverses
A = EMSEfwd.matrix(1:128,:);
 
 %This normalize the lead field
 for i=1:length(A)
Anorms(i)=norm(A(:,i));
     A(:,i) = A(:,i)./norm(A(:,i));

 end
A=A*max(Anorms);
%A=mcpFwd.matrix(1:128,:);
AAt = A*A';
[u s v] = svd(AAt);
percentNeeded = .95;


invTolIdx = 11;sum(cumsum(diag(s).^2./trace(s.^2))<percentNeeded);
invTol = s(invTolIdx,invTolIdx)

Ginv = pinv(AAt,invTol);
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


%Do weight normalized
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    dwMN(:,i) = [Ginv*A(:,i)./sqrt(A(:,i)'*(Ginv_sq)*A(:,i))];
end



%Regularized forward
lambda = .1*mean(diag(AAt));
[u s v] = svd(AAt+noiseCov*lambda);
percentNeeded = 1-1e-4;


invTolIdx =10;sum(cumsum(diag(s).^2./trace(s.^2))<percentNeeded);
invTol = s(invTolIdx,invTolIdx)

Ginv_noisereg = pinv(AAt+noiseCov*lambda,invTol);
Ginv_reg = pinv(AAt+eye(size(AAt))*lambda,invTol);
Ginv = pinv(AAt,invTol);
%Ginv_reg_sq = pinv((AAt+eye(size(AAt))*lambda).^2);
Ginv_reg_sq = pinv( (AAt+noiseCov*lambda).^2,invTol);

%Regularized Min NOrm
regMN = zeros(size(EMSEfwd.matrix(1:128,:)));
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    regMN(:,i) = [Ginv_reg*A(:,i)];
end


%Noise Regularized Min NOrm
noiseRegMN = zeros(size(EMSEfwd.matrix(1:128,:)));
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    noiseRegMN(:,i) = [Ginv_noisereg*A(:,i)];
end

%Regularized weight normalized Min NOrm
regdwMN = zeros(size(EMSEfwd.matrix(1:128,:)));
for i=1:length(EMSEfwd.matrix(1:128,:)), 
    regdwMN(:,i) = [Ginv_noisereg*A(:,i)./sqrt(A(:,i)'*(Ginv_reg_sq)*A(:,i))];
end

%regsloretaInv = zeros(size(EMSEfwd.matrix(1:128,:)));
%Do Regularized sLoreta norm
%for i=1:length(EMSEfwd.matrix(1:128,:)), 
%    regsloretaInv(:,i) = [Ginv_reg*A(:,i)./sqrt(A(:,i)'*Ginv_reg*A(:,i))];
%end


%% Make a geometrically chunking matrix
nTiles = 800;

geomChunker = geometryChunk(ctx,nTiles);

Ageom = A*geomChunker;
for i=1:nTiles,
       Ageom(:,i) = Ageom(:,i)/norm(Ageom(:,i));
end

%% Enforce Source Covariance
roiDir = '/Volumes/MRI-1/anatomy/vildavski/Standard/meshes/ROIs/';
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

%%
%spSourceList = sparse(ctxSimulate);
%spCov = spSourceList*spSourceList';

%Make covariance matrix

chunker2use = geomChunker;
spCov = .1*speye(length(A));


for iArea=1:size(chunker2use,2),
    
    ctxList = sparse(chunker2use(:,iArea));
    spCov=spCov + ctxList*ctxList';
end


R=spCov;

ARAt = A*R*A';
RA = R*A';
RA = RA';
lambda = .1*mean(diag(ARAt));
%Regularized, source covariance weighted, forward
Ginv_reg = pinv(ARAt+lambda*noiseCov,.01);



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






%% This stuff for testing various optimization methods, requires CVX
%% toolbox


%{

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
gamma = 
cvx_begin
    variable xr(n)
    minimize(norm(dataROI-A*xr,2)+gamma*norm(xr,1))
cvx_end
disp('done');
toc



%}