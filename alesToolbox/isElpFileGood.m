function isGood = isElpFileGood(elpfile)
%function isGood = isElpFileGood(elpfile)

V = mrC_readELPfile(elpfile,true,[-2 1 3]);

F = mrC_EGInetFaces(false);

V(:,1:2) = flattenZ(V);
V(:,3) = 0;

[isIntersect badPoint ua ub] = findMeshSelfIntersections(V(1:128,1:2),F);

isGood = ~isIntersect;
