function [varargout] = applyFilters(filters,C)
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

Cy = (C);

traceOut = zeros(length(filters)/3,1);
lamOut = zeros(size(traceOut));

if ~exist('sourceCorrelation','var')
    sourceCorrelation = [];
end


idx=1;
for i=1:3:length(filters),
    


    filt = ctranspose(filters(:,i:i+2));
    
    if sum(abs(filt(:)))==0;
        traceOut(idx) = 0;
        if nargin > 1

            lamOut(idx) = 0;
        end
        
        idx = idx+1;
        continue;
    end
    
    if ~isempty(sourceCorrelation)
        %index into a priori determined correlated sources
        %combine all three orientations 
        [corrIdx row] = find(sourceCorrelation(:,i:i+2));
        
        corrIdx = setdiff(corrIdx,i:i+2);
        if sum(corrIdx)>=1
            corrlf = thisFwd(:,corrIdx);
            
            %taken the first 3 eigen vectors of the correlated source.
            [u s v] = svd(corrlf,'econ');
            corrlf = u(:,1:3);%*s(1:6,1:6)*v(:,1:6)';
    
            %New set of sources to pass is the combined activity at
            %this source and the correlated sources.
            lf = [lf corrlf];
        end
    end

    
    
%     


    
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
