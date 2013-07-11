function [varargout] = lcmvBeamformExtendedSource(fwd,C,sourceGrouping)
%function [traceOut lamOut] = lcmvBeamform(fwd,C,sourceGrouping)
%
%fwd = nElec x (3*nSources) matrix of free orienation forward model
%C = data covariance matrix to find the sources of.
%sourceGrouping = nSourcesFull X nExtendedSources 
%                       of assumed source correlations
%
%OUTPUT:
%traceOut is the trace of all output power components.
%
%
%SILLYNESS: lcmvBeamform works for free orientation forward models
%           lcmvBeamformFixed works for fixed orientation forward models
%           lcmvBeamformExtenededSourc works for fixed orientation extended source forward models
% 
%           combine them in the future.
thisFwd = fwd;

Cy = (C);
invCy = pinv(C);

traceOut = zeros(length(thisFwd),1);
lamOut = zeros(size(traceOut));


idx=1;
for i=1:1:size(sourceGrouping,2),
    
    thisSourceSet = sourceGrouping(:,i)>0;
    
    lf = thisFwd(:,thisSourceSet);
    
    if sum(thisSourceSet)==0;
        continue;
    end
    
    [u s v] = svd(lf,'econ');
    
%     s = diag(s);
%     percentVar = s.^2./sum(s.^2);
%     
%     n2Keep = cumsum(percentVar)<.99;
% %     
%     if sum(n2Keep)>6;
%         keyboard
%     end
   
%    lf = u(:,1:n2Keep);%*s(1:6,1:6)*v(:,1:6)';
    
    n2keep =  6;max(6,size(u,2));
    lf = u(:,1:n2keep);%*s(1:6,1:6)*v(:,1:6)';
    
        %New set of sources to pass is the combined activity at 
        %this source and the correlated sources.

%     %Normalize the output gain.
%     for i=1:size(lf,2),
%         lf(:,i) = lf(:,i)./norm(lf(:,i));
%     end
%     
    
    try filt = pinv(lf' * invCy * lf) * lf' * invCy;  
    catch
        keyboard
    end    
    

    idx = thisSourceSet;
    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = filt * Cy * ctranspose(filt); 
    traceOut(idx) = traceOut(idx)+trace(filtOut)./sum(thisSourceSet)^1;

    tRoi(i) = trace(filtOut);
    
    if nargout > 1
        s = svd(filtOut);
        lamOut(idx) = lamOut(idx)+s(1)./sum(thisSourceSet).^1;
        lamRoi(i) = s(1);
    end
    
%    for iC=1:3,
%        figure(100+iC);

%    plotOnEgi(thisFwd(:,i+iC-1));
%    end
%    pause

%  plotOnEgi(thisFwd(:,i));
%     drawnow



end

varargout{1} = traceOut;
if nargout>1
    varargout{2} = lamOut;
end
if nargout>2
    varargout{3} = tRoi;
end
if nargout>3
    varargout{4} = lamRoi;
end

