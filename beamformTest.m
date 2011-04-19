%% Set up forward


%mrcDir = '/Volumes/MRI-2/4D2/L1test';
mrcDir = '/Volumes/MRI-1/4D2/RBTX_GV_4D2/GRATING';
mrcDir = '/Volumes/MRI/data/4D2/SEP/mrcProj';
%mrcDir = '/Volumes/MRI/data/4D2/CPT/mrcProj/';
mrcDir = '/Volumes/MRI/data/4D2/JMA_PROJECTS/chopstix/chopstixMRC/';
mrcDir = '/Volumes/MRI/data/4D2/CPT/resolutionSimulations/';
mrcDir = '/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj';


subjId = 'skeri0037';

anatDir = getpref('mrCurrent','AnatomyFolder');
roiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');

fsDir = getpref('freesurfer','SUBJECTS_DIR');

fwdFile = fullfile(mrcDir,subjId,'_MNE_',[subjId '-fwd.fif']);
fwd = mne_read_forward_solution(fwdFile);

% srcFile = fullfile(fsDir,[subjId '_fs4'],'bem',[subjId '_fs4-ico-5p-src.fif']);
% src = mne_read_source_spaces(srcFile);

src = readDefaultSourceSpace(subjId);

[A Afree] = makeForwardMatrixFromMne(fwd,src);

Anrm = zeros(size(A));

for i=1:length(A);
    
    Anrm(:,i) = A(:,i)./norm(A(:,i));
end

[funcChunk roiList] = createChunkerFromMeshRoi(roiDir,length(A));
%[basisChunk] = multiResChunkSubject(subjId,[12 16 20]);
ctx = readDefaultCortex(subjId)

ctxH = drawAnatomySurface(subjId,'cortex');
set(ctxH,'facealpha',1,'facecolor','interp')

msh.uniqueFaceIndexList = get(ctxH,'faces')
msh.uniqueVertices = get(ctxH,'vertices')
conMat = findConnectionMatrix(msh);

%% setup signal

nT = 500;
dft = dftmtx(nT);
sourceIdx = [2001 3000];
%sourceIdx = [7 8 ];
sourceIdx = [5 10];

mtI = find(strncmp('MT',{roiList.name},2));
v3aI = find(strncmp('V3A',{roiList.name},3));

sourceIdx = [mtI v3aI];

noiseLevel = 300;


%Asim = A*basisChunk;

Asim = A*funcChunk;

%sigTime = randn(nT,length(sourceIdx));
%sigTime = [real(dft(:,2)) 1*imag(dft(:,2))+ 0*real(dft(:,2)) .707*imag(dft(:,2))+ .707*real(dft(:,2)) .8*imag(dft(:,2))- .6*real(dft(:,2))];

sigTime = [real(dft(:,2)) real(dft(:,2)) real(dft(:,3)) real(dft(:,3))  ];

%sigTime = [real(dft(:,2)) .707*real(dft(:,3))];

addNoise = noiseLevel*randn(128,length(sigTime));
simSignal = Asim(:,sourceIdx)*sigTime'+addNoise;

%C = cov(simSignal');
C = simSignal*simSignal';

%C= cov(addNoise');

%% setup single trial signals
nTrials = 100;

simTrials = [];
for iTr=1:nTrials,
    addNoise = sqrt(nTrials)*noiseLevel*randn(128,length(sigTime));
    simTrials = [simTrials Asim(:,sourceIdx)*sigTime'+addNoise];
end

%% Do beamformer
thisFwd = A;

%lambda = trace(C)*0.00;
lambda = 22*10*mean(diag(cov(addNoise')));
invCy = pinv(C + lambda * eye(size(C)));

%invCy = pinv(C,10e7);

Cy = (C + lambda * eye(size(C)));

[u s v] = svd(C);

uD = u(:,1:4);

fixOut = zeros(length(thisFwd),1);
mxrFiltOut = zeros(length(thisFwd),128);
caponOut = zeros(length(thisFwd),1);

musicOut = zeros(size(caponOut));

for i=1:length(thisFwd),
    
    
    lf = thisFwd(:,i);
    
    aRa=lf' * invCy * lf;
    capon = pinv(aRa);

    filt = capon * lf' * invCy;  
    
    U = mean(filt*simSignal);
    
    U2 = U^2;   
    betamxr = (U2*aRa)/(1+U2*aRa);
    
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    
    musicOut(i) = subspace(lf,uD);

    
    fixOut(i) = trace(filtOut);
    caponOut(i) = capon;
    betaVal(i) = betamxr;
    mxrFiltOut(i,:) = betamxr*filt;
    
%     s = svd(filtOut);
%     lamOut(i) = s(1);
    
    
end


%%
%% Do free ori beamformer
thisFwd = Afree;

%lambda = .3;
%lambda = trace(C)*0.05;
%lambda = 10*30*mean(diag(cov(addNoise')));
%lambda = 0.05*mean(diag(sep01.Cov));
lambda = 0.05*mean(diag(C));

%lambda = 1.8493e-04;
invCy = pinv(C + lambda * eye(size(C)));
%invCy = pinv(C,9e7);

%noiseC = eye(128)*mean(diag(cov(addNoise')));

Cy = (C + lambda * eye(size(C)));
[u s v] = svd(C);

uC = orth(C);
uC = uC(:,1:10);
uD = u(:,1:2);
uN = u(:,10:end);

PN = u*u';

%Cy = (u(:,1:2)*s(1:2,1:2)*v(:,1:2)');


traceOut = zeros(length(thisFwd)/3,1);
traceOut2 = traceOut;
lamOut = zeros(size(traceOut));
musicOut = zeros(size(traceOut));

betammx = zeros(size(traceOut));

maxFiltOut = zeros(length(traceOut),128);
allFilt = zeros(length(traceOut),3,128);

%timeOut = zeros(length(traceOut),size(simSignal,2));
idx=1;
for i=1:3:length(thisFwd),
    

    lf = thisFwd(:,i:i+2);
    
    aRa = lf' * invCy * lf;
           
    capon = pinv(aRa);

    filt = capon * lf' * invCy;  

    
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    allFilt(idx,:,:) = filt;
    filtOut = filt * Cy * ctranspose(filt); 
    
    B = orth(lf);
    
    [Ur Cr Vr] = svd(uC'*B);
    
    musicOut(idx) = Cr(1);
    
%    pMusic(idx) =  max(lf'*lf/(lf'*PN*lf));
    
    
    traceOut(idx) = trace(filtOut);
    traceOut2(idx) = trace(capon);
%    dipScan(idx ) = trace(lf'*Cy*lf);
     [u s v] = svd(filtOut);
     
     maxFiltOut(idx,:) = (u(:,1)'*filt)';
% 
%      U = mean(maxFiltOut(idx,:)*simSignal);     
%      U2 = U^2;
%      
%      a = (u(:,1)'*lf')';
%      aRa = a'*invCy*a;
%      
%      betammx(idx) = (U2*aRa)/(1+U2*aRa);

     lamOut(idx) = s(1);
     
%      for t=1:size(simSignal,2),
%      
%          num = trace(filt*simSignal(:,t)*simSignal(:,t)'*filt');
%          timeOut(idx,t) = num;
%      end
     
   idx = idx+1; 
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow
end


%% Do free ori, full cortex with BILAT ROI beamformer.

thisFwd = Afree;

%lambda =0;
invCy = pinv(C + lambda * eye(size(C)));

Cy = (C + lambda * eye(size(C)));

roiTraceOut = zeros(length(Afree)/3,1);
roiLamOut = zeros(size(traceOut));

idx=1;

for iRoi=1:2:length(roiChoice),
    
    thisRoi = roiChoice(iRoi:iRoi+1);
    thisRoiVerts = find( sum(funcChunk(:,thisRoi),2));
    
    idx = thisRoiVerts;
    allVerts = [thisRoiVerts*3-2; thisRoiVerts*3-1; thisRoiVerts*3];

    lf = thisFwd(:,allVerts);
    
    [u s v] = svd(lf);
    lf = u(:,1:6);%*s(1:6,1:6)*v(:,1:6)';
    
    filt = pinv(lf' * invCy * lf) * lf' * invCy;  
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    roiTraceOut(idx) = trace(filtOut);
    s = svd(filtOut);
    roiLamOut(idx) = s(1);
    
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow
end


%% Do free ori BILAT ROI beamformer.

thisFwd = Afree;

%lambda =0;
invCy = pinv(C + lambda * eye(size(C)));

Cy = (C + lambda * eye(size(C)));

roiTraceOut = zeros(length(Afree)/3,1);
roiLamOut = zeros(size(traceOut));

idx=1;
for iRoi=1:2:length(roiChoice),
    
    thisRoi = roiChoice(iRoi:iRoi+1);
    thisRoiVerts = find( sum(funcChunk(:,thisRoi),2));
    
    idx = thisRoiVerts;
    allVerts = [thisRoiVerts*3-2; thisRoiVerts*3-1; thisRoiVerts*3];

    lf = thisFwd(:,allVerts);
    
    [u s v] = svd(lf);
    lf = u(:,1:6);%*s(1:6,1:6)*v(:,1:6)';
    
    filt = pinv(lf' * invCy * lf) * lf' * invCy;  
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    roiTraceOut(idx) = trace(filtOut);
    s = svd(filtOut);
    roiLamOut(idx) = s(1);
    
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow
end


%% Do free ori uniLAT ROI beamformer.

thisFwd = Afree;

%lambda =0;
invCy = pinv(C + lambda * eye(size(C)));

Cy = (C + lambda * eye(size(C)));

roiTraceOut = zeros(length(Afree)/3,1);
roiLamOut = zeros(size(traceOut));

idx=1;
for iRoi=1:1:length(roiChoice),
    
    thisRoi = roiChoice(iRoi);
    thisRoiVerts = find( sum(funcChunk(:,thisRoi),2));
    
    idx = thisRoiVerts;
    allVerts = [thisRoiVerts*3-2; thisRoiVerts*3-1; thisRoiVerts*3];

    lf = thisFwd(:,allVerts);
    
    [u s v] = svd(lf);
    lf = u(:,1:6);%*s(1:6,1:6)*v(:,1:6)';
    
    filt = pinv(lf' * invCy * lf) * lf' * invCy;  
    filtSave(iRoi,:,:) = filt;
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    roiTraceOut(idx) = trace(filtOut);
    s = svd(filtOut);
    roiLamOut(idx) = s(1);
    
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow
end


%% DO free ori MN

thisFwd = Afree;

[u s v]  = svd(thisFwd,'econ');

thisInv = pinv(thisFwd);

s = diag(s);
s = s+.05*max(s);

s = diag(s);

thisInv = v*s*u';

idx=1;
for i=1:3:length(thisFwd),
    

    lf = thisInv(i:i+2,:);
    
    
    thisPowOut = lf*simSignal;
    mnFreeOut(idx) = trace(thisPowOut*thisPowOut');
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    
%     
%     [u s v] = svd(filtOut);
%      
%      maxFiltOut(idx,:) = (u(:,1)'*filt)';
%      
%      lamOut(idx) = s(1);
    
   idx = idx+1; 
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow
end

%% Try CVX

n = 128;


cvx_begin
  variable w(n)
  minimize(w'*Cy*w+norm(w,2))
  subject to
  (lfMt*w) == 1
  (lfLOC*w) ==0
cvx_end


%% CVX test


n1 = size(A,2);
%n2 = size(simSignal,2)

%tstA = sum(Asim(:,sourceIdx),2);


lam_max =  norm(2*tstA,inf);
lambda = lam_max*.001; % regularization parameter
lambda2 = .001*lambda;

cvx_begin

  variable x(n1)
  minimize( norm(tstA-A*x,2) + lambda2*norm(D*x,2)+lambda*norm(x,1))
  
cvx_end


%%

n1 = size(A,2);
%n2 = size(simSignal,2)
nT = size(tstA,2);
%tstA = sum(Asim(:,sourceIdx),2);


lam_max =  norm(2*tstA,inf);
lambda = lam_max*.001; % regularization parameter
lambda2 = .1*lambda;

cvx_begin
  variable x(n1,nT) 
  minimize(  norm(tstA-A*x,2)+lambda2*norm(D*x,1))
  %lambda2*norm(Dg*x,2)
  %+lambda*norm(x,1)
  
cvx_end



%%

%%

n1 = size(A,2);
%n2 = size(simSignal,2)
nT = size(tstA,2);
%tstA = sum(Asim(:,sourceIdx),2);


lam_max =  norm(2*tstA,inf);
lambda = lam_max*.001; % regularization parameter
lambda2 = 1*lambda;

cvx_begin

  variable x(n1,nT) complex
  minimize(  lambda*norm(x,1) )
  subject to
  norm(tstA-A*x,2) <= 6e4;
  
cvx_end



%% TV

n1 = size(A,2);
%n2 = size(simSignal,2)
nT = size(tstA,2);
%tstA = sum(Asim(:,sourceIdx),2);


lam_max =  norm(2*tstA,inf);
lambda = lam_max*.001; % regularization parameter
lambda2 = 1*lambda;

cvx_begin

  variable x(n1,nT)
  minimize( norm(tstA-A*x,2) )
  
  subject to
  norm(D*x,1) <= 100
  
cvx_end


%%
x0 = sim.J_MN';

N = length(x0);
x = x0;
b = tstA;

Dx = D*x;

epsilon = 5e-3;
lbtol = 1e-3;
mu = 10; 
cgtol = 1e-8; 
cgmaxiter = 200; 

newtontol = lbtol;
newtonmaxiter = 50;

%t = (0.95)*sqrt(Dhx.^2 + Dvx.^2) + (0.1)*max(sqrt(Dhx.^2 + Dvx.^2));
t = (0.95)*sqrt(Dx.^2) + (0.1)*max(sqrt(Dx.^2));

% choose initial value of tau so that the duality gap after the first
% step will be about the origial TV
%tau = (N+1)/sum(sqrt(Dhx.^2+Dvx.^2));
tau = (N+1)/sum(sqrt(Dx.^2));

lbiter = ceil((log((N+1))-log(lbtol)-log(tau))/log(mu));

disp(sprintf('Number of log barrier iterations = %d\n', lbiter));
totaliter = 0;
for ii = 1:lbiter
  
  [xp, tp, ntiter] = tvqc_newton(x, t, A, At, b, epsilon, tau, newtontol, newtonmaxiter, cgtol, cgmaxiter);
  totaliter = totaliter + ntiter;
  
  %tvxp = sum(sqrt((Dh*xp).^2 + (Dv*xp).^2));
  tvxp = sum(sqrt((D*xp).^2));
  disp(sprintf('\nLog barrier iter = %d, TV = %.3f, functional = %8.3f, tau = %8.3e, total newton iter = %d\n', ...
    ii, tvxp, sum(tp), tau, totaliter));
  
  x = xp;
  t = tp;
  
  tau = mu*tau;
  
end



%% setup 1st derivative matrix;
nV = sum(conMat,2);

conMatNrm = double(conMat);

for i=1:size(conMat,2),

    conMatNrm(:,i) = conMat(:,i)./sum(conMat(:,i));
end

D = -speye(size(conMat)) + conMatNrm;

%% l1_ls


nT = size(tstA,2);

B = sparse([repmat(Anrm,1,1); lambda2*D]);

y = real([tstA(:); zeros(length(D),1)]);

% B = sparse(blkdiag(Anrm,Anrm));
% y = real(tstA(:));

size(y)
size(B)


lam_max =  norm(2*(B'*y),inf);
lambda = lam_max*.1;
lambda2 = 10*lambda;
lambda./lam_max
lambda2./lam_max

[xl1ls,status] = l1_ls(B,y,lambda,5e-2);



