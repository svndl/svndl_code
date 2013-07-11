function [varargout] = makeBilatAnatSrcCor(subjId)
%function [srcCor srcCorFree] = makeBilatAnatSrcCor(subjId)



ctx = readDefaultCortex(subjId);


srcSize = length(ctx.vertices);

ctxLeft.vertices = ctx.vertices(1:10242,:);
ctxLeft.vertices(:,2) = -ctxLeft.vertices(:,2);

ctxRight.vertices = ctx.vertices(10243:end,:);

[indexR2L] = nearpoints(ctxRight.vertices',ctxLeft.vertices');

ctxLeft.vertices = ctx.vertices(1:10242,:);

ctxRight.vertices = ctx.vertices(10243:end,:);
ctxRight.vertices(:,2) = -ctxRight.vertices(:,2);



[indexL2R] = nearpoints(ctxLeft.vertices',ctxRight.vertices');


%Build up the anatomical connect matrix
%This is a sparse identity matrix with 1 off diagonal element corresponding
%to a source in the opposite hemisphere.
i= [[1:srcSize]'; [1:srcSize]' ];
j=[[1:srcSize]'; indexL2R'+10242; indexR2L'];
s=[ones(size(i))];
srcCor = sparse(i,j,s,srcSize,srcSize);
% srcCor = srcCor+srcCor';
% srcCor = srcCor~=0;
varargout{1} = srcCor;

if nargout >1
    
    iNew = [i*3-2; i*3-1; i*3];
    jNew = [j*3-2; j*3-1; j*3];
    sNew = ones(size(iNew));
    varargout{2} = sparse(iNew,jNew,sNew,srcSize*3,srcSize*3);
end
                             

