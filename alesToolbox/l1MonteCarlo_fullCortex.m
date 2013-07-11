
%% Set up forward

dataRoot ='/Users/ales/data/';
subject = 'wade';


fwdFile = [dataRoot 'arw_mocoloco20080108dat/Forward/arw_mocoloc_010909_sph_025skull.fwd'];
EMSEfwd = emseReadForward(fwdFile);
A = EMSEfwd.matrix(1:128,:);
load([dataRoot  'anatomy/' subject '/Standard/meshes/defaultCortex'])
ctx.vertices = msh.data.vertices';
ctx.faces = [msh.data.triangles+1]';
nTotalVert = length(ctx.vertices);


roiDir = [dataRoot  'anatomy/' subject '/Standard/meshes/ROIs/']
[funcChunker] = createChunkerFromMeshRoi(roiDir,nTotalVert);


Afunc = A*funcChunker;

for i=1:size(Afunc,2)
    scaleFac(i) = norm(Afunc(:,i));
    Afunc(:,i) = Afunc(:,i)./norm(Afunc(:,i));
end






%% Make geometry chunk
geoChunk = geometryChunk(ctx,400);

Ageo = A*geoChunk;

for i=1:size(Ageo,2)
    scaleFac(i) = norm(Ageo(:,i));
    Ageo(:,i) = Ageo(:,i)./norm(Ageo(:,i));
end



%%
clear l1Results l2Results l1PolishResults l1X l1Xp l2X trueX

denseList = [.05:.1:1];

for iDensity = 1:length(denseList),

    density = denseList(iDensity);

    for iRep = 1:50,


        % Setup data
        Adata = Afunc;
        thisChunk = funcChunker;
        %Adata = Ageo;

        activeSources = sprandn(size(Adata,2),1,density);
        thisAngle = 2*pi*rand(size(Adata,2),1);
        
        realPart = activeSources.*cos(thisAngle);
        imagPart = activeSources.*sin(thisAngle);
%        imagPart = randn(size(realPart));
%        imagPart(activeSources==0) = 0;
 
        x_true=complex(full(realPart),full(imagPart));
        
        x_true = x_true./norm(x_true);
        signal = Adata*x_true;

        xTrueFull = thisChunk*x_true;

        sigma = .01;
        noise = sigma*randn(size(signal));
        y=signal+noise;



        %

        % run l1_ls

        lam_max = find_lambdamax_l1_ls(Adata',y);
        lambda = lam_max*.01; % regularization parameter
        rel_tol = 0.001; % relative target duality gap
        n = size(Adata,2);
        
        cvx_begin
          variable x(n) complex
          minimize(norm(y-Adata*x,2)+lambda*norm(x,1))
        cvx_end

%        [x,status]=l1_ls(Adata,y,lambda,rel_tol);

        xList = abs(x)>max(abs(x))*.01;

        xPolished = zeros(size(x));

        xPolished(xList) = y.'/Adata(:,xList)';

        % ySub = y-Adata*xPolished;
        %
        % lam_max = find_lambdamax_l1_ls(Adata(:,~xList)',ySub);
        % lambda = lam_max*.2; % regularization parameter
        %
        % [xSub] = l1_ls(Adata(:,~xList),ySub,lambda,rel_tol);
        %
        % xPolished(~xList) = xSub;

        % Get MN Inverse
        noiseCov = sigma*eye(128)/10;
        condNumber = 22;

        [MN] = normalizedMNE(Adata,noiseCov,condNumber);
        xl2 = MN'*y;


        % calculate fit

        xFull_l1 = thisChunk*x;
        xFull_l2 = thisChunk*xl2;
        xFull_p  = thisChunk*xPolished;

        norm(xFull_l1-xTrueFull)
        norm(xFull_l2-xTrueFull)
        norm(xFull_p-xTrueFull)

        figure(2)
        clf
        plot(xl2,'k')
        hold on
        plot(x_true)
        plot(x,'r')
        plot(xPolished,'g')

        
        l1Results(iDensity,iRep) = norm(x-x_true);
        l2Results(iDensity,iRep) = norm(xl2-x_true);
        l1PolishResults(iDensity,iRep) = norm(xPolished-x_true);
                

        l1X(iDensity,iRep,:) = x;
        l1Xp(iDensity,iRep,:) = xPolished;
        l2X(iDensity,iRep,:) = xl2;
        trueX(iDensity,iRep,:) = x_true;
        snr(iDensity,iRep) = norm(signal)/norm(noise);
        
    end

end
