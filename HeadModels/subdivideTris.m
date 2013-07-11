function [V,F] = subdivideTris(V,F)

nV = size(V,1);	% # vertices
nF = size(F,1);	% # faces

nFnew = 3*nF;			% # new faces
% nVnew = nFnew/2;	% # new vertices = existing # edges if closed surface
nVnew = 3*(nV-2);		% closed surface would have nF = (nV-2)*2 ?
nVe = nV + nVnew;

I = sparse([],[],[],nV,nV,nVnew);		% sparse is only Class double?

V = [ V; zeros(nVnew,3) ];
F = [ F; zeros(nFnew,3) ];
for f = 1:nF
	i = edgeCenters;
	F( (nF+3*f-2):(nF+3*f), : ) = [ F(f,1) i(1) i(3); i(1) F(f,2) i(2); i(3) i(2) F(f,3) ];
	F(f,:) = i;
end

if nV > nVe
	warning('%d extra vertices.',nV-nVe)
elseif nV < nVe
	V = V(1:nV,:);
end
return
%-------------------------------------------

	function iNew = edgeCenters
		k = sort(reshape(F(f,[1 2 2 3 3 1]),2,3));
		iNew = [ I(k(1,1),k(2,1)), I(k(1,2),k(2,2)), I(k(1,3),k(2,3)) ];
		for edge = 1:3
			if iNew(edge) == 0
				nV = nV + 1;
				V(nV,:) = mean(V(k(:,edge),:));
				[I(k(1,edge),k(2,edge)),iNew(edge)] = deal(nV);
			end
		end
	end

end