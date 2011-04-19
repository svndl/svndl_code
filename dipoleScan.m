function [varargout] = dipoleScan(fwd,data)
thisFwd = fwd;


traceOut = zeros(length(thisFwd)/3,1);
lamOut = zeros(size(traceOut));



if nargout>=3
    varargout{3} = zeros(size(fwd));
end



idx=1;
for i=1:3:length(thisFwd),
    

    lf = thisFwd(:,i:i+2);
    
    if sum(abs(lf(:)))==0;
        traceOut(idx) = 0;
        if nargin > 1

            lamOut(idx) = 0;
        end
        
        idx = idx+1;
        continue;
    end

    
    %Normalize the output gain.
    for j=1:size(lf,2),
        lf(:,j) = lf(:,j)./norm(lf(:,j));
    end
    

    
    %pow(i) = lambda1(filt * Cy * ctranspose(filt));
    filtOut = lf'*data;
    traceOut(idx) = sqrt(sum(filtOut.^2));

    %caponOut(idx) = trace(pinv(lf' * invCy * lf));

    
%     if nargin > 1
%  %       s = svd(filtOut);
%         lamOut(idx) = s(1);
%     end
    
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

