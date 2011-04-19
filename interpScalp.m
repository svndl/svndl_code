%%worthless script

%%
Vreg = [V ones(length(V),1)];
Vreg = Vreg*regMtx';
Vreg = Vreg(:,1:3);



figure(10);
clf
sens = patch('vertices',Vreg(1:128,:),'faces',F,'facevertexcdata',simTopo(14).data,'facecolor','interp');
hold on;
%ctxH  = patch('vertices',ctx.vertices(:,[3 1 2]),'faces',ctx.faces,'facevertexcdata',ctxColor','facecolor','interp')
axis equal

%scalp = patch('faces',surf.tris,'vertices',surf.rr*1000,'linestyle','none','facecolor',[.7 .7 .7]);

scalp = patch('faces',scalpLo.faces(:,[3 2 1]),'vertices',scalpLo.vertices,'linestyle','none','facecolor',[.7 .7 .7]);


%%
[indices]= nearpoints(Vreg(1:128,:)',scalpLo.vertices');


scalpColor = NaN*ones(length(scalpLo.vertices),1);

scalpColor(indices) = simTopo(14).data;

set(scalp,'facevertexcdata',scalpColor,'facecolor','interp');



%%

scalpHi.vertices = surf.rr*1000;
scalpHi.faces = surf.tris;
scalpLo = scalpHi;
%scalpLo = reducepatch(scalpHi,.01);