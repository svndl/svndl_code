%rigidRotate - performs a rigid body transformation
%movedPoints = rigidRotate(params,movablePoints)
%
%
%function that performs a rigid body transformation specified in params:
%	xShift = params(1);
%	yShift = params(2);
%	zShift = params(3);
%	Rx   = params(4); rotation around x axis
%	Ry   = params(5); rotation around y
%	Rz   = params(6); rotation around z

function movedPoints = rigidRotate(params,movablePoints)
%rigidRotate - performs a rigid body transformation
%movedPoints = rigidRotate(params,movablePoints)
%
%
%This function that performs a rigid body transformation on movablePoints
%that is specified as follows:
%   
%   movablePoints - Nx3 matrix
%
%	xShift = params(1);
%	yShift = params(2);
%	zShift = params(3);
%	Rx   = params(4); rotation around x axis
%	Ry   = params(5); rotation around y
%	Rz   = params(6); rotation around z

	xShift = params(1);
	yShift = params(2);
	zShift = params(3);
	ang1   = params(4);
	ang2   = params(5);
	ang3   = params(6);
	

	movedPoints =  Rx(movablePoints,ang1);
 	movedPoints =  Ry(movedPoints,ang2);
 	movedPoints =  Rz(movedPoints,ang3);

    movedPoints = 	[movedPoints(:,1)+xShift, ...
 					 movedPoints(:,2)+yShift, ...
					 movedPoints(:,3)+zShift];
                 