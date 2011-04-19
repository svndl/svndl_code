function [MN] = normalizedMNE(fwd,noiseCov,condNumber);
%function [MN] = normalizedMNE(fwd,noiseCov,condNumber);

% Calculate inverses
A = fwd;

%This normalize the lead field
for i=1:size(A,2)
    Anorms(i)=norm(A(:,i));
    A(:,i) = A(:,i)./norm(A(:,i));
    
end

A=A*max(Anorms);

%A=mcpFwd.matrix(1:128,:);
AAt = A*A';
[u s v] = svd(AAt);
percentNeeded = .95;


invTolIdx = condNumber;
%sum(cumsum(diag(s).^2./trace(s.^2))<percentNeeded);
invTol = s(invTolIdx,invTolIdx)

%Ginv = pinv(AAt,invTol);
%Ginv_sq = Ginv^2;


% %No weight
% for i=1:length(EMSEfwd.matrix(1:128,:)), 
%     MN(:,i) = [Ginv*A(:,i)];
% end
% 
% 
% 
% %Do sLoreta norm
% %for i=1:length(EMSEfwd.matrix(1:128,:)), 
% %    sloretaInv(:,i) = [Ginv*A(:,i)./sqrt(A(:,i)'*Ginv*A(:,i))];
% %end
% 
% 
% %Do weight normalized
% for i=1:length(EMSEfwd.matrix(1:128,:)), 
%     dwMN(:,i) = [Ginv*A(:,i)./sqrt(A(:,i)'*(Ginv_sq)*A(:,i))];
% end
% 
% 
% 
% %Regularized forward
% lambda = .1*mean(diag(AAt));
% [u s v] = svd(AAt+noiseCov*lambda);
% percentNeeded = 1-1e-4;
% 
% 
% invTolIdx =10;sum(cumsum(diag(s).^2./trace(s.^2))<percentNeeded);
% invTol = s(invTolIdx,invTolIdx)

Ginv_noisereg = pinv(AAt+noiseCov,invTol);
%Ginv_reg = pinv(AAt+eye(size(AAt))*lambda,invTol);
%Ginv = pinv(AAt,invTol);
%Ginv_reg_sq = pinv((AAt+eye(size(AAt))*lambda).^2);
%Ginv_reg_sq = pinv( (AAt+noiseCov*lambda).^2,invTol);


%Noise Regularized Min NOrm
MN = zeros(size(fwd));
for i=1:size(fwd,2), 
    MN(:,i) = [Ginv_noisereg*A(:,i)];
end

% %Regularized weight normalized Min NOrm
% regdwMN = zeros(size(EMSEfwd.matrix(1:128,:)));
% for i=1:length(EMSEfwd.matrix(1:128,:)), 
%     regdwMN(:,i) = [Ginv_noisereg*A(:,i)./sqrt(A(:,i)'*(Ginv_reg_sq)*A(:,i))];
% end

%regsloretaInv = zeros(size(EMSEfwd.matrix(1:128,:)));
%Do Regularized sLoreta norm
%for i=1:length(EMSEfwd.matrix(1:128,:)), 
%    regsloretaInv(:,i) = [Ginv_reg*A(:,i)./sqrt(A(:,i)'*Ginv_reg*A(:,i))];
%end
