function [rotationMtx, movedPoints] = fitScatteredPoints(stationaryPoints,movablePoints,initialThreshold)

%fitScatteredPoints  - Find a rigid transformation the best fits 2 sets of points
%function [rotationMtx, movedPoints] = fitScatteredPoints(stationaryPoints,movablePoints)
%
% Uses function: rigidRotate
% stationaryPoints - Nx3 matrix of point locations to fit 
% movablePoints    - Nx3 matrix of points that will be transformed
%
% rotationMtx - The best fit set of params used by rigidRotate() 
% movedPoints - movablePoints with the transformation applied
%
 optns = optimset(@fmincon);
 optns = optimset('display', 'iter', 'maxfunevals', 10000, 'MaxIter', 1000,'LargeScale','off');

 

[K,D] = nearpoints(movablePoints', stationaryPoints'); 


%throw out points farther than 2 cm from scalp
movablePoints = movablePoints(sqrt(D)<30,:);


stationaryCenter = mean(stationaryPoints);
movableCenter    = mean(movablePoints);

initialTranslation = [movableCenter - stationaryCenter];
  
 lowlim = [ -inf -inf -inf -pi/2 -pi/2 -pi/2];
 uplim  = [  inf  inf  inf  pi/2  pi/2  pi/2];

% T = delaunay3(stationaryPoints(:,1),stationaryPoints(:,2),stationaryPoints(:,3))
 initial = [initialTranslation 0 0 0];
 %[params fval] = fminsearch(@translate,[0 0 0 0],optns,v1fMRI,VEP);
 [params fval] = fmincon(@rotcostfunc,initial,[],[],[],[],lowlim,uplim,[],optns, ...
						 stationaryPoints,movablePoints);
                     
                     
 movedPoints = rigidRotate(params,movablePoints);
 
 params
 
 xShift = params(1);
 yShift = params(2);
 zShift = params(3);
 a   = params(4);
 b   = params(5);
 g   = params(6);

 Rx = [1 0 0; 0 cos(a) -sin(a); 0 sin(a) cos(a) ];
 Ry = [ cos(b) 0 sin(b); 0 1 0; -sin(b) 0 cos(b) ];
 Rz = [ cos(g) -sin(g) 0;  sin(g) cos(g) 0;  0 0 1 ];


 newR = Rx*Ry*Rz;


 newtrans = [newR, [xShift yShift zShift]'; 0 0 0 1];

 rotationMtx = newtrans;

 %rotationMtx = params;
%{
xShift = params(1);
yShift = params(2);
zShift = params(3);



clf;
scatter3(fMRI(:,1)+xShift,fMRI(:,2)+yShift,fMRI(:,3)+zShift,'r')
hold on;

scatter3(VEP(:,1),VEP(:,2),VEP(:,3),'b')
%}



function dist = rotcostfunc(params,stationaryPoints,movablePoints)

	movedPoints = rigidRotate(params,movablePoints);
    %[K,D] = nearpoints(src, dest) 
    
    [K,D] = nearpoints(movedPoints', stationaryPoints'); 
  % [K,D] = nearpoints(stationaryPoints',movedPoints'); 
  
 
  %[K,D] = dsearchn(stationaryPoints,movedPoints);
    
    
    %dist = sum(D(sqrt(D)<20));
    dist = sum(D);
    
	%dist = sum(sum((stationaryPoints - movedPoints).^2));
	
	
%{
	hold off;
	clf;
    scatter3(stationaryPoints(:,1),stationaryPoints(:,2),stationaryPoints(:,3),'r')
	hold on
	scatter3(movedPoints(:,1),movedPoints(:,2),movedPoints(:,3),'k')
	scatter3(movablePoints(:,1),movablePoints(:,2),movablePoints(:,3),'b')
	drawnow;
pause

%}