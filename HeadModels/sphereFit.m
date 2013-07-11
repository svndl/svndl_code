function [o,r] = sphereFit(p,oInit)
% Spherical fit to a matrix of Cartesian data points
%
% [origin,radius] = sphereFit(p,oInit)
% p     = n x 3 matrix of cartesian data points [x y z]
% oInit = initial coords of origin for optimization.  (optional, defaults to median)

if ~exist('oInit','var') || isempty(oInit)
	oInit = median(p);
end

n = size(p,1);
% 	opts = optimset;
% 	o = fminunc(@objFcn,oInit,opts);
% 	o = fminsearch(@objFcn,oInit,opts);
o = fminsearch(@objFcn,oInit);
[f,r] = objFcn(o);

	function [F,r] = objFcn(x)
		dp = p - repmat(x,n,1);
		u = dp ./ repmat( hypot( hypot( dp(:,1), dp(:,2) ), dp(:,3) ), 1, 3 );
		r = u(:) \ dp(:);
		F = norm(u*r-dp,'fro');
	end
end

