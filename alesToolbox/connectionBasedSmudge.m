function smoothedVals=connectionBasedSmudge(connectionMatrix,inputVals)
% Performs neighborhood averaging of the values in inputVals.
%
% smoothedVals = connectionBasedSmooth(connectionMatrix,inputVals)
% 
% connectionMatrix specifies which nodes in inputVals are connected. 
% Each element in inputVals is replaced by the mean of itself and its neigbours.
% example : smoothedVals=connectionBasedSmooth(connectionMatrix,inputVals);

% $Log: connectionBasedSmudge.m,v $
% Revision 1.1  2010/08/31 22:03:46  SKI+ales
% Added all my random .m files
%

% AUTHOR: Wade
% Date written : 06-16-03
%
%

inputVals=inputVals(:);
nzData = (inputVals==0);

sum(nzData)

[sy sx]=size(connectionMatrix);

if (sx~=length(inputVals))
    error('Connection matrix and inputVal size mis-match: %d (cm) %d (input)',sx,length(inputVals));
end

connectionMatrix=(connectionMatrix~=0); % We do our own normalization
sumNeighbours = ones(sy,1);
%sumNeighbours(nzData)=sum(connectionMatrix(nzData,:),2); % Although it should be symmetric, we specify row-summation
sumNeighbours=sum(connectionMatrix(:,:),2); % Although it should be symmetric, we specify row-summation
%smoothedVals = double(inputVals);
%smoothedVals=double(connectionMatrix)*double(inputVals);
%sumNeighbours(~nzData)=1;
[i,j,s] = find(connectionMatrix);
spt = sparse(i,j,sumNeighbours(i).^-1,sy,sx);
%spt(nzData,nzData) = 1;

smoothedVals = spt;%connectionMatrix./spt;
%smoothedVals(~nzData)=inputVals(~nzData);
%smoothedVals=smoothedVals./sumNeighbours;

return;
