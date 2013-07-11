function [x,y,z] = isoPoints(H,v)

V = get(H,'vertices');
F = get(H,'faces');
C = get(H,'facevertexcdata');		% has to be [nV x 1] indices into colormap, not rgb data

[nF,mF] = size(F);
k = false(nF,mF);
for i = 1:(mF-1)
	d1 = v - C(F(:,i));
	d2 = C(F(:,i+1)) - v;
	k(:,i) = sign(d1) == sign(d2);
end
	d1 = v - C(F(:,mF));
	d2 = C(F(:,1)) - v;
	k(:,mF) = sign(d1) == sign(d2);

sumk = sum(k);
x = zeros(sum(sumk),1);
y = x;
z = x;
for i = 1:(mF-1)
	f = ( v - C(F(k(:,i),i)) ) ./ ( C(F(k(:,i),i+1)) - C(F(k(:,i),i)) );
	if i == 1
		kk = 1:sumk(i);
	else
		kk = sum(sumk(1:(i-1))) + (1:sumk(i));
	end
	x(kk) = V(F(k(:,i),i),1) + f .* ( V(F(k(:,i),i+1),1) - V(F(k(:,i),i),1) );
	y(kk) = V(F(k(:,i),i),2) + f .* ( V(F(k(:,i),i+1),2) - V(F(k(:,i),i),2) );
	z(kk) = V(F(k(:,i),i),3) + f .* ( V(F(k(:,i),i+1),3) - V(F(k(:,i),i),3) );
end
	f = ( v - C(F(k(:,mF),mF)) ) ./ ( C(F(k(:,mF),1)) - C(F(k(:,mF),mF)) );
	kk = sum(sumk(1:(mF-1))) + (1:sumk(mF));
	x(kk) = V(F(k(:,mF),mF),1) + f .* ( V(F(k(:,mF),1),1) - V(F(k(:,mF),mF),1) );
	y(kk) = V(F(k(:,mF),mF),2) + f .* ( V(F(k(:,mF),1),2) - V(F(k(:,mF),mF),2) );
	z(kk) = V(F(k(:,mF),mF),3) + f .* ( V(F(k(:,mF),1),3) - V(F(k(:,mF),mF),3) );
	


