function [varargout] = lcmvBeamformFixed(fwd,C,sourceCorrelation)
%function [traceOut lamOut] = lcmvBeamform(fwd,C)
%
%fwd = nElec x (3*nSources) matrix of free orienation forward model
%C = data covariance matrix to find the sources of.
%[sourceCorrelation] = [OPTIONAL] SPARSE (3*nSources) X (3*nSources) 
%                       of assumed source correlations
%
%OUTPUT:
%traceOut is the trace of all output power components.
%
%
%SILLYNESS: lcmvBeamform works for free orientation forward models
%           lcmvBeamformFixed works for fixed orientation forward models
% 
%           combine them in the future.
thisFwd = fwd;

Cy = (C);
invCy = pinv(C);

traceOut = zeros(length(thisFwd)/3,1);
lamOut = zeros(size(traceOut));

if ~exist('sourceCorrelation','var')
    sourceCorrelation = [];
end


idx=1;
for i=1:1:length(thisFwd),
    

    lf = thisFwd(:,i);
    
    
    if ~isempty(sourceCorrelation)
        %index into a priori determined correlated sources
        corrIdx = sum(sourceCorrelation(i,:),1)>0;
        
        corrlf = thisFwd(:,corrIdx);
        
        %taken the first 3 eigen vectors of the correlated sources.
        [u s v] = svd(corrlf);
        corrlf = u(:,1:3);%*s(1:6,1:6)*v(:,1:6)';
    
        %New set of sources to pass is the combined activity at 
        %this source and the correlated sources.
        lf = [lf corrlf];

    end

%     %Normalize the output gain.
%     for i=1:size(lf,2),
%         lf(:,i) = lf(:,i)./norm(lf(:,i));
%     end
%     
    
    try filt = pinv(lf' * invCy * lf) * lf' * invCy;  
    catch keyboard;
    end    
    


    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    traceOut(idx) = trace(filtOut);

    if nargin > 1
        s = svd(filtOut);
        lamOut(idx) = s(1);
    end
    
    idx = idx+1;
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow



end

varargout{1} = traceOut;
if nargin>1
    varargout{2} = lamOut;
end
