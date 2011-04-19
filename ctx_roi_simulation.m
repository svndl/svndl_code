%% Load things

probeFile='~/Desktop/GSN128.sfp'
%probeFile = '/raid/MRI/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Polhemus/spm_MOCOFields_112707.elp'
invFile = '/Volumes/MRI-1/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Inverses/spm_3shell_112707.inv';
fwdFile = '/Volumes/MRI-1/data/4dImaging/Projects/MTLocalizer/EEG_EMSE/MOCOFields/spm_MOCOField_112707Data/Forward/SPM_3SPHERE.fwd'

%probe = emse_read_elp(probeFile);
[eloc] = readlocs(probeFile)
eloc = eloc(4:end);

EMSEinv = emseReadInverse(invFile)
EMSEfwd = emseReadForward(fwdFile);
load('/Volumes/MRI/anatomy/mckee/Standard/meshes/defaultCortex')
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';


load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/MT-R')
MTR = ROI.meshIndices(find(ROI.meshIndices>0));

load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/MT-L')
MTL = ROI.meshIndices(find(ROI.meshIndices>0));


load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/V1-L')
V1L = ROI.meshIndices(find(ROI.meshIndices>0));

load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/V1-R')
V1R = ROI.meshIndices(find(ROI.meshIndices>0));

load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/V2D-R')
V2DR = ROI.meshIndices(find(ROI.meshIndices>0));
load('/Volumes/MRI/anatomy/mckee/Standard/meshes/ROIs/V2V-R')
V2VR = ROI.meshIndices(find(ROI.meshIndices>0));



%% Simulate source


activeV1 = [V1L V1R];
activeV2 = [V2DR];

activeMTL = [MTL];
activeMTR = [MTR];
activeMT = [activeMTR];



%activeList = [MTL MTR V1L V1R];
activeList = [V2DR MTR];

ctxSimulate = zeros(length(msh.data.vertices),1);
MTSimulate = zeros(length(msh.data.vertices),1);
V1Simulate = zeros(length(msh.data.vertices),1);


%ctxSimulate(activeList) = 1;

ctxSimulate(activeList) = 1;
%ctxSimulate(activeMT) = 1;
MTSimulate(activeMT) = 1;
V1Simulate(activeV1) = 1;


%ctxSimulate(10000) = 1;
offset=50;




%% Do Forward

%dataROI = sum(EMSEfwd.matrix(1:128,:).*ctxSimulate,2);
dataROI = EMSEfwd.matrix(1:128,:)*ctxSimulate;

dataMT = EMSEfwd.matrix(1:128,:)*MTSimulate;
dataV1 = EMSEfwd.matrix(1:128,:)*V1Simulate;


solution = EMSEinv.matrix*dataROI;
nrmFwd = zeros(size(EMSEfwd.matrix(1:128,:)));
%for i=1:length(EMSEfwd.matrix(1:128,:)), nrmFwd(:,i) = EMSEfwd.matrix(1:128,i)./norm(squeeze(EMSEfwd.matrix(1:128,i)));end
%A = EMSEfwd.matrix(1:128,:);
%pA = pinv(A*A',.01);
%for i=1:length(EMSEfwd.matrix(1:128,:)), nrmInv(:,i) = [pA*A(:,i)./sqrt(A(:,i)'*pA*A(:,i))];end


jmaSol = nrmInv'*dataROI;
prior = randn(size(solution));

%% Plot

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
title('JMA Solution')






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