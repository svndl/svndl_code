function [trans, rot, alinpts] = alignFiducials(inpts, volpts)
%[trans, rot] = alignFiducials(inpts, volpts)	
%	returns alignment matrix given inpts and volpts as corresponding points
%	rot rotates inpts into volpts coordinate frame.
%	scaleFac is a vector containing scalings of the x,y,and z axes 
%		such that inpts*scalefac is at the same scale as volpts

%nuinpts = inpts ./ (ones(length(inpts),1)*scaleFac(1,:));
%nuvolpts = volpts ./ (ones(length(volpts),1)*scaleFac(2,:));
%nuvolpts = nuvolpts - (mean(nuvolpts)'*ones(1,length(nuvolpts)))';
%nuinpts = nuinpts - (mean(nuinpts)'*ones(1,length(nuinpts)))';

nuinpts = inpts;
nuvolpts = volpts;
nuvolpts = nuvolpts - (mean(nuvolpts)'*ones(1,length(nuvolpts)))';
nuinpts = nuinpts - (mean(nuinpts)'*ones(1,length(nuinpts)))';


H = zeros(3,3);
for i = 1:length(nuvolpts)
	H = H + (nuinpts(i,:)')*(nuvolpts(i,:));
end

%= H./length(nuvolpts);

[U,S,V] = svd(H);


mirrorFixer = [ 1 0 0; 0 1 0; 0 0 det(U*V);];

%rot = V*(U');



rot = [V*mirrorFixer*(U')];


if det(rot)< 0
	disp('Warning: rotation matrix has -1 determinant, This should not have happened. Hmmm.');
end

%alinpts = (rot*(inpts'./(ones(length(inpts),1)*scaleFac(1,:))'))';
%nuvolpts = volpts ./ (ones(length(volpts),1)*scaleFac(2,:));

alinpts = [(rot*(inpts'))]';



nuvolpts = volpts;

trans = mean(nuvolpts) - mean(alinpts);

 
