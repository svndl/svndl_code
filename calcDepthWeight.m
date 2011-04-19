function [w] = calcDepthWeight(A,exp,limit)
%function [w] = calcDepthWeight(A,exp,limit)
%
%Calculates depth weighting according to the MNE manual section 6.2.10


%Set MNE default values
if ~exist('exp','var') || isempty(exp)
    exp = .8;
end

if ~exist('limit','var') || isempty(limit)
    limit = 10;
end

w = ones(size(A,2),1);
for iSource = 1:3:size(A,2),
    
    srcIdx = iSource:iSource+2;
    sourceNorm = sum(diag(A(:,srcIdx)'*A(:,srcIdx)));
        
    thisSourceWeight = sourceNorm^-exp; %Equation from 6.2.10
    w(srcIdx) = thisSourceWeight;
end

wMin = min(w);
threshold = limit * wMin;
w(w>threshold) = threshold;

