function [v] = combineTriplet(vTrip)
%function [v] = combineTriplet(vTrip)
%
% this function is my version of a function that takes 3 columns of data
% organized in as: [x1 y1 z1 x1 y2 z2 x3 y3 z3]

%Remove any leading singleton dimensions
 [vTrip,n]  = shiftdim(vTrip);
 
 if ndims(vTrip) >2
     error('Cannot opereate on matrices with > 2 dimensions');
 end
 
 nR = size(vTrip,1)/3;
 nC = size(vTrip,2);
 
 v = zeros(nR,nC);
 for iC = 1:nC;
     
     %reorginze column into 3 columns, for ease of quadrature summing
     theseVals = reshape(vTrip(:,iC),3,[]);
 
 
     v(:,iC) = sqrt(sum(theseVals.^2));
 end
 
 