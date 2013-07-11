function [sol] = jmaDoL1(fname_fwd,lambda2,srcSpace,srcCor)
%
% An example on how to compute an L1-norm inverse solution
%
% fname_inv  - Name of the inverse file
%
% lambda2    - The regularization factor. lambda^2 ~ 1/SNR (POWER!)
%              ex. 10/1 Power SNR -> lambda2 = .1;
%              ex. 10/1 Amplitude SNR -> lambda2 = .01;
%
% srcSpace   - MNE source space structure that corresponds to the source
%              space that was used to create the defaultCortex.mat
% [srcCor]   - Optional srcCorrelation matrix. NOT COVARIANCE.
%              The reason is that this matrix gets rescaled to the variance
%              computed in the MNE src variance vector

%   $Log: jmaDoL1.m,v $
%   Revision 1.1  2009/02/13 23:52:22  ales
%   Begun the L1
%

me='JMA:makeInv';
FIFF=fiff_define_constants;

fwd = mne_read_forward_solution(fname_fwd);

options.lambda2 = lambda2;

options.nave = 1;

%lambda2 = options.lambda2;
%dSPM = options.dSPM;
nave = options.nave;

%Calculating transformations to the total src space stored in default

newDx = [];
oriLeft = [];
idx=1;
for iHi=fwd.src(1).vertno,
    newDx(idx) = find(srcSpace(1).vertno == iHi);
    oriLeft(idx,:) = fwd.src(1).nn(iHi,:);
    idx=idx+1;
    
end

newDxLeft =newDx;

newDx = [];
idx=1;
for iHi=fwd.src(2).vertno,
    newDx(idx) = find(srcSpace(2).vertno == iHi);
    oriRight(idx,:) = fwd.src(2).nn(iHi,:);
    idx=idx+1;
    
end

newDxRight =newDx;

totalDx = [newDxLeft (newDxRight+double(srcSpace(1).nuse))];


%
%   Pick the correct channels from the data
%
% data = fiff_pick_channels_evoked(data,inv.noise_cov.names);
% fprintf(1,'Picked %d channels from the data\n',data.info.nchan);
% fprintf(1,'Computing inverse...');
%
%   Simple matrix multiplication followed by combination of the 
%   three current components
%
%   This does all the data transformations to compute the weights for the
%   eigenleads
%   
%trans = diag(sparse(inv.reginv))*inv.eigen_fields.data*inv.whitener*inv.proj*double(data.evoked(1).epochs);


%A = inv.eigen_fields.data'*diag(inv.sing)*inv.eigen_leads.data';


%   Transformation into current distributions by weighting the eigenleads
%   with the weights computed above
%
%   JMA: I'm not sure if I'm doing this right, this step is tricky
% if ~exist('srcCor','var')
%     srcCov=diag(sparse(sqrt(inv.source_cov.data)));
% elseif isempty(srcCor)
%     srcCov=diag(sparse(sqrt(inv.source_cov.data)));
% else
%     srcVar = mean(inv.source_cov.data(3:3:end));
%     %Nead to map the srcCor to the set of valid vertices in this inverse:
%     %       
%     srcCor = srcCor(totalDx,totalDx);
%     
%     
%     
%     
%     %Next construct the sparse covariance matrix, in a form that allows the
%     %kludged loose orientation constraint format to get the fixed orient.
%     %we need to triple the size for the colomns that refer to the 3
%     %orientations.
%     nSrcs = length(totalDx);
%     [i,j,s] = find(srcCor);
% 
%     
%     srcCovDiag = inv.source_cov.data;
%     srcCovDiag(i) = 0;
%     
%     %scaling the src cov is important for keeping the regularizer to have
%     %the same meaning. Basically we want to keep the sources projecting to the same
%     %power on the scalp relative to the noise
%         
%     s = sqrt(srcVar*s);%<- Scaling step, THIS IS TRICKY, important scaling, and it's probably wrong here
%     
%     srcCov = sparse(3*i,3*j,s,3*nSrcs,3*nSrcs);   %This reconstructs the full
%                                                   %cov as a sparse matrix
%     srcCov = srcCov + diag(sparse(sqrt(srcCovDiag)));
%     
%     
%     oldDiagPow = sum(inv.source_cov.data)
%     newDiagPow = sum(diag(srcCov).^2)
%     
%     scaler = sqrt(oldDiagPow/newDiagPow);
%     srcCov = scaler*srcCov;
%     
%     
%     
% end


%fprintf(1,'combining the current components...');



%sol1 = zeros(inv.src.np,size(sol,2));

%idx = 1;
%for iX = 1:3: size(sol,1),
    
%    iVert = inv.src.vertno(idx);
%    sol1(iVert,:) = (inv.src.nn(iVert,:)*sol(iX:iX+2,:));

%    This line depth weights the inverse:
%    sol1(iVert,:) = (inv.src.nn(iVert,:)*sol(iX:iX+2,:))*inv.depth_prior.data(iX);
%    idx = idx+1;
%end
%sol = sol1;


Gfree = fwd.sol.data;
Gfree = Gfree - repmat(mean(Gfree),128,[]);

G = zeros(size(Gfree,1),size(Gfree,2)/3);
srcOri = [oriLeft; oriRight];

idx=1;
for i=1:3:length(Gfree);

    G(:,idx) = Gfree(:,i:i+2)*srcOri(idx,:)';

    idx=idx+1;
end

origSensPow = trace(G*G');

%This line is compeletely inscrutable
%Basically I am reducing the number of srcs by summing up a bunch of
%sources in a chunk (G*srcCor), then I am expanding that back to the
%orignal size of the matrix putting the summed source into it's place by
%remultiplying by srcCor
if ~isempty(srcCor),
    srcCor = srcCor(totalDx,:);
    G = (G*srcCor)';
 %   [non G] = colnorm(G);
    G = (srcCor*G)';
end


%[non G] = colnorm(G);

%newSensPow = trace(G*G');

%scaleFac = origSensPow/newSensPow;

%G = scaleFac*G; 

[u,w,v] = svd(G,'econ');

w = diag( w);	% Extract diagonal, always real, non-negative.
maxW = max( w);
varianceAccountedFor = cumsum(w.^2)/sum(w.^2);

comps2keep =1;

for i=1:length(varianceAccountedFor),

    if (varianceAccountedFor(i) > (1-lambda2)  )
        break;
    end

    comps2keep = comps2keep+1;

end

comps2keep

wInv = 1 ./ w;
wInv(comps2keep+1:end) = 0;

wInv = diag( wInv);	% Re-embed diagonal in a full zeros matrix.
% swi= size( wInv)

gInv = v * wInv * u';

%trans = diag(sparse(inv.reginv))*inv.eigen_fields.data*inv.whitener*inv.proj;
%sol   = srcCov*inv.eigen_leads.data*trans;

% if inv.source_ori == FIFF.FIFFV_MNE_FREE_ORI
%     fprintf(1,'combining the current components...');
%     sol1 = zeros(size(sol,1)/3,size(sol,2));
%     for k = 1:size(sol,2)
%         sol1(:,k) = sqrt(mne_combine_xyz(sol(:,k)));
%     end
%     sol = sol1;
%    
% end

%sol = sol(3:3:end,:);
sol = gInv;

totalVerts = srcSpace(1).nuse + srcSpace(2).nuse;
totalVerts,size(sol,2)
sol1 = zeros(totalVerts,size(sol,2));

sol1(totalDx,:) = sol;

sol = sol1;






