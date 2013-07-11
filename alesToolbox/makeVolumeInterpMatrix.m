function [interpMatrix p nearestMatrix tri validLocs] = makeVolumeInterpMatrix(x,y,z,xi,yi,zi,dimSize);
%makeVolumeInterpMatrix            - Makes a sparse trlinear interpolaion matrix
%function [interpMatrix] = makeVolumeInterpMatrix(x,y,z,xi,yi,zi);
% 
% x,y,z = column vectors of coordinates to interpolate from
% x,y,z = column vectors of coordinates to interpolate onto
%

fromLocs = [x y z];


if ~exist('dimSize','var') | isempty(dimSize)

    %guess data cube
    sX = length(xi).^1/3;
    if sX ~= round(sX);
        error('Cannot determine datacube dimensions')
    end
    
    sY = sX;
    sZ = sY;
    
else
sX = dimSize(1);
sY = dimSize(2);
sZ = dimSize(3);
end

%find subvolume to interpolate onto
%use a bounding box around the extent of x
minX = min(x);
maxX = max(x);

minY = min(y);
maxY = max(y);

minZ = min(z);
maxZ = max(z);

validXi = (xi<=maxX ) & (xi>=minX);
validYi = (yi<=maxY ) & (yi>=minY);
validZi = (zi<=maxZ ) & (zi>=minZ);

validLocs = validXi & validYi & validZi;

% size(validLocs);
% sum(validLocs);
totalLocs = length(xi);
%length(xi)/sum(validLocs);



%Add points to the bounding box for the tessalation;
% boundPoints = [minX minY minZ; ...
%     minX minY maxZ; ...
%     minX maxY minZ; ...
%     minX maxY maxZ; ...
%     maxX minY minZ; ...
%     maxX minY maxZ; ...
%     maxX maxY minZ; ...
%     maxX maxY maxZ];



outputIndex = find(validLocs);
tmpIndx = 1:sum(validLocs);
inputIndex = zeros(size(validLocs));
inputIndex(validLocs) = tmpIndx;

toLocs = [xi(validLocs) yi(validLocs) zi(validLocs)];
%toLocs = [xi yi zi];

meshX = ones(sX,sY,sZ)*NaN;
meshY = ones(sX,sY,sZ)*NaN;
meshZ = ones(sX,sY,sZ)*NaN;

% meshX(validLocs) = x(:);
% meshY(validLocs) = y(:);
% meshZ(validLocs) = z(:);

meshX(:) = xi(:);
meshY(:) = yi(:);
meshZ(:) = zi(:);

%number source points
npS = size(fromLocs,1);
%Number of destination points 
npD = size(toLocs,1);


newPointInd = (npS+1):(npS+1+8);

% fromLocs = [fromLocs;boundPoints];

% t = nan(npD,1); % Simplex containing corresponding input point
% p = ones(npt,ndim+1); % Barycentric coordinates for corresponding input point

validInterpMatrix = spalloc(npD,npS,4*npD);


%LINEAR Triangle-based linear interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
% if isempty(opt)
tic
tri = delaunayn(fromLocs);
%options test: ,{'Qt' 'Qbb', 'Qc', 'Qx'}
toc

% badSimplices = any(ismember(tri,newPointInd),2);
% 
% %Remove simplices that include the bounding box
% tri = tri(~badSimplices,:);
% fromLocs = fromLocs(1:end-8,:);


% dt= DelaunayTri(fromLocs);
% else
%   tri = delaunayn(x,opt);
% end
if isempty(tri),
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  interpV = NaN*zeros(size(toLocs));
  return
end

triCenter = zeros(size(tri,1),size(fromLocs,2));


% ind = zeros(25*size(tri,1),1);
% toInd = ind;
% 
% startIdx = 1;
% for iFrom = 1:size(tri,1),
%     %for all triangles 
% 
%     triCenter(iFrom,:) = mean(fromLocs(tri(iFrom,:),:));
%     
%     %Vertices for this simplex
%     simpVert = fromLocs(tri(iFrom,:),:);
%     simpX = simpVert(:,1);
%     simpY = simpVert(:,2);
%     simpZ = simpVert(:,3);
%     
%     sMinX = min(simpX);
%     sMaxX = max(simpX);
% 
%     sMinY = min(simpY);
%     sMaxY = max(simpY);
%     
%     sMinZ = min(simpZ);
%     sMaxZ = max(simpZ);
%     
%     validXi = find((meshX(:,1,1)<=sMaxX ) & (meshX(:,1,1)>=sMinX));
%     validYi = find((meshY(1,:,1)<=sMaxY ) & (meshY(1,:,1)>=sMinY));
%     validZi = find((meshZ(1,1,:)<=sMaxZ ) & (meshZ(1,1,:)>=sMinZ));
%     
%     
%  
%     [vx vy vz] = ndgrid(validXi,validYi,validZi);
%     simplexBoundBox = sub2ind([sX sY sZ],vx(:),vy(:),vz(:))';
%     
% %    simplexBoundBoxBinary = validXi & validYi & validZi;
% %    simplexBoundBox = find(simplexBoundBoxBinary(:))';
%     theseIdx = startIdx:(startIdx+length(simplexBoundBox)-1);
%     
%     toInd(theseIdx) = simplexBoundBox;
%     ind(theseIdx) = iFrom*ones(size(simplexBoundBox));
%     startIdx = startIdx+length(simplexBoundBox);
% end
% 
% toInd = toInd(1:(startIdx-1));
% ind   = ind(1:(startIdx-1));

%From every point in the hires space find the nearest simplex center 
%This should be sufficient for determining which points are within the
%simplex, but it doesn't seem to be.
% [indC  dist] = nearpoints(toLocs',triCenter');

%Add the points nearest every simplex vertex as well
%further on we will detemine which points are actually inside the simplex
% [ind1  dist] = nearpoints(toLocs',fromLocs(tri(:,1),:)');
% [ind2  dist] = nearpoints(toLocs',fromLocs(tri(:,2),:)');
% [ind3  dist] = nearpoints(toLocs',fromLocs(tri(:,3),:)');
% [ind4  dist] = nearpoints(toLocs',fromLocs(tri(:,4),:)');

%ind = [indC ind1 ind2 ind3 ind4 ];
% ind = [indC];
% toInd = repmat(1:size(toLocs,1),1,1);

%nearestMatrix = sparse(toInd,ind,ones(size(ind)),size(toLocs,1),size(triCenter,1));

myeps = -sqrt(eps);
[npt ndim] = size(toLocs); % Number of points
ntri = size(tri,1); % Number of simplexes


%x = fromLocs;
%xi = toLocs;

t = nan(npt,1); % Simplex containing corresponding input point
p = nan(npt,ndim+1); % Barycentric coordinates for corresponding input point
X = [ones(size(fromLocs,1),1) fromLocs]; % Append 1s to vertex matrix
%    b = [ones(npt,1) xi]; % Append 1s to point matrix
totalLoops = ntri;
idx=1;
tic
count = 0;
myeps = -sqrt(eps(single(1)));
for i = 1:ntri
    % For each simplex
    %Vertices for this simplex
    simpVert = fromLocs(tri(i,:),:);
    simpX = simpVert(:,1);
    simpY = simpVert(:,2);
    simpZ = simpVert(:,3);
    
    sMinX = min(simpX);
    sMaxX = max(simpX);

    sMinY = min(simpY);
    sMaxY = max(simpY);
    
    sMinZ = min(simpZ);
    sMaxZ = max(simpZ);
    
    validXi = find((meshX(:,1,1)<=sMaxX ) & (meshX(:,1,1)>=sMinX));
    validYi = find((meshY(1,:,1)<=sMaxY ) & (meshY(1,:,1)>=sMinY));
    validZi = find((meshZ(1,1,:)<=sMaxZ ) & (meshZ(1,1,:)>=sMinZ));
    
    
 
    [vx vy vz] = ndgrid(validXi,validYi,validZi);
    simplexBoundBox = sub2ind([sX sY sZ],vx(:),vy(:),vz(:))';
  %  tmp = false(size(validLocs));
 %   tmp(simplexBoundBox) = true;
%    tmp = tmp(validLocs);
  
%validLocs(simplexBoundBox)
%    I = find(tmp);
    I=inputIndex(simplexBoundBox);%tmp(validLocs);
    %I = find(nearestMatrix(:,i));

    
    
    theseX = X(tri(i,:),:);
    %nearX = xi(I,:);
%    b = [ones(length(nearX),1) nearX ]; % Append 1s to point matrix
     b = [ones(length(I),1) toLocs(I,:) ]; % Append 1s to point matrix
    
%      if cond(theseX)>myeps
%          q = zeros(1,ndim+1);
%      end
      
     q = b / theseX; % Compute barycentric coordinate of each point
     I2 = all(q > myeps,2); % Find simplex where all coordinates are positive

%      I = I(I2);
%      q = q(I2,:);
     
% foundP = sum(I2&~I);
% if foundP>0
%     [i foundP]
% end

%  if sum(q,2)~1
%      [i sum(q)]
%      %q = zeros(size(q));
% %     count = count+1;
% % end

%     t(I) = i; % Set simplex
%I = find(I);
newI = I(I2);
 
    t(newI) = i;
%     p(I,:) = q(I,:); % Set barycentric coordinates
  p(newI,:) = q(I2,:); % Set barycentric coordinates
%   %         
    %time(idx) = toc;
    
%     if mod(i,100)==0
%         (totalLoops-i)
%         totalTime = toc*(totalLoops)/(100*60)
%         tic
%     end

end

count
size(p)
size(t)
size(tri)

m1 = size(t,1);



% for iTri = 1:m1
%     if ~isnan(t(iTri))
%         %interpV(i) = p(i,:)*v(tri(t(i),:));
%         fromList = tri(t(iTri),:);
%         validInterpMatrix(iTri,fromList) = p(iTri,:);
%     end
% end

sourceList = repmat([1:m1]',1,4);
goodt = ~isnan(t);
t = t(goodt);
sourceList = sourceList(goodt,:);
p = p(goodt,:);
triIndex = (tri(t,:));
%validInterpMatrix = sparse(sourceList(:),triIndex(:),p(:));
interpMatrix = sparse(outputIndex(sourceList(:)),triIndex(:),p(:),totalLocs,npS);
%groupSize = 1e4;

%Number of source points

% 
% totalLoops = (npD/groupSize)
% idx = 1;
% for iTo = 1:groupSize:npD,
% 
%     tic
%     
%     thisLoop = 1 + (iTo-1)/groupSize;
%     thesePoints = iTo:min(npD,(iTo+groupSize-1));
%     %Find the nearest triangle (t)
%     [t,p] = tsearchn(fromLocs,tri,toLocs(thesePoints,:));
% 
%     
%     
%     m1 = size(t,1);
% %     onev = ones(1,size(fromLocs,2)+1);
%     
%     
%     
%     for iTri = 1:m1
%         if ~isnan(t(iTri))
%             %interpV(i) = p(i,:)*v(tri(t(i),:));
%             fromList = tri(t(iTri),:);
%             validInterpMatrix(thesePoints(iTri),fromList) = p(iTri,:);
%         end
%     end
%     
%     
%     time(idx) = toc;
%     (totalLoops-thisLoop)
%     totalTime = mean(time)*totalLoops/60   
%     timeLeft = mean(time)*(totalLoops-thisLoop)/60
%     
%     idx=idx+1;
% end



%interpMatrix = spalloc(totalLocs,npS,4*npS);

%interpMatrix(outputIndex,:) = validInterpMatrix;

% 
% destinationPoints = [x y z];
% sourcePoints = [xi yi zi];
% 
% npD = length(x);
% 
% npS = length(xi);
% 
% 
% find(x(1)>=xi,1)
% find(x(1)<=xi,1)
% 
% d2map = sparse(npD,npS);
% 
% for i = 1:128
% 	[junk,d2map(i,:)] = nearpoints( S.rr', ex(i,:)' );
% end
% dToo = min(d2map) > 30^2;
% d2map = exp(-d2map/(20^2));
% d2map = d2map ./ repmat(sum(d2map),128,1);