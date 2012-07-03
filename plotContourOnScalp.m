function [ H ] = plotContourOnScalp( data, subjId, mrcProjDir,cMapRange,myColormap )
%plotContourOnScalp Plot's contour maps on a realistic scalp surface.
%function [ H ] = plotContourOnScalp( data, subjId, mrcProjDir,cMapRange )
%   Detailed explanation goes here

h = 10;		% estimated sensor height (mm)
d2 = 30^2;	% distance threshold (mm^2)

%Makre sure data is a 1xn vector. 
data = squeeze(data);
dataSz = size(data);
if dataSz(2)<dataSz(1)
    data = data';
end

if all(dataSz>1)
    error('Matrix input detected. This function only plots vectors');
end


%TODO: ADD ERROR CHECKING.

fsDir = getpref('freesurfer','SUBJECTS_DIR')
scalpFile = fullfile(fsDir, [subjId '_fs4'],'bem',[ subjId '_fs4-head.fif']);

%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/AW_crf2_20090519.elp'];
%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/JA_ATTCont_20090225.elp'];

ELPname = dir(fullfile(mrcProjDir,subjId,'Polhemus','*Edited.elp'));

validNames = ~strncmp({ELPname(:).name},'.',1);
ELPname=ELPname(validNames);

if isempty(ELPname),
    
    ELPname = dir(fullfile(mrcProjDir,subjId,'Polhemus','*.elp'));
    
    validNames = ~strncmp({ELPname(:).name},'.',1);
    ELPname=ELPname(validNames);
    
    if isempty(ELPname),
        error(['\n Subject: ' subjId ' does not have Polhemus file']);
    else
        display(['Using file: ' ELPname(1).name]);
    end
    
else
    display(['Found edited ELP file, using file: ' ELPname(1).name ]);
end
    
elpFile = fullfile(mrcProjDir, subjId, 'Polhemus',ELPname(1).name);
regFile = fullfile(mrcProjDir, subjId, '_MNE_','elp2mri.tran');


S = mne_read_bem_surfaces(scalpFile);
S.rr = S.rr*1e3;					% convert to mm
S.tris = flipdim(S.tris,2);	% outward normals of matlab patch
S.np = double(S.np);

e = mrC_readELPfile(elpFile,true,true,[-2 1 3]);
xfm = load('-ascii',regFile);
ex = [e(1:128,:)*1e3,ones(128,1)]*(xfm(1:3,:)');

% eegStruct = load(eegFile);
% eeg = eegStruct.Wave(eegIndex,:);

bgc = [0 0 0]+0.75;		% scalp background color

%%

colormap([bgc;jet(255)])

P = patch('vertices',S.rr,'faces',S.tris(:,[1 2 3]),'edgecolor','none','facecolor',bgc);
L = [ light('position',[1e3 1e3 1e3]), light('position',[-1e3 -1e3 1e3]) ];
set(L,'color','w','style','local');
material([ .4 .5 .1])

set(gca,'view',[0 40],'dataaspectratio',[1 1 1],'xcolor','r','ycolor',[0 0.5 0],'zcolor','b')
xlabel('right')
ylabel('anterior')
zlabel('superior')

%  E = patch('vertices',e,'faces',flipdim(mrC_EGInetFaces(false),2),'facecolor','none',...
%  	'facevertexcdata',2+round(127*(1+eeg(:)/max(abs(eeg)))),'edgecolor','interp');

% N = get(E,'vertexnormals');
% N = N ./ repmat(sqrt(sum(N.^2,2)),1,3);
% ex = ex - N*h;
% set(E,'vertices',ex)

%%
d2map = zeros(128,S.np);
for i = 1:128
	[junk,d2map(i,:)] = nearpoints( S.rr', ex(i,:)' );
end
dToo = min(d2map) > 30^2;
d2map = exp(-d2map/(20^2));
d2map = d2map ./ repmat(sum(d2map),128,1);
% toc

%% Plots smoothed data on scalp with no contours

cdata = ( data*d2map )';
% dog = zeros(1,128); dog(109) = 1; cdata = ( dog*d2map )';
%cdata = 2 + round( 127*( 1 + cdata/max(abs(cdata)) ) );
%cdata(dToo) = 1;

cdata = 2 + round( 127*( 1 + cdata./max(abs(cdata)) ) );
eegData = 2 + round( 127*( 1 + data./max(abs(data)) ) );

cdata(dToo) = 1;

set(P,'facevertexcdata',cdata,'facecolor','interp')

%For electrode helmet
%set(E,'facevertexcdata',eegData')



%% countour ify cdata


cdata = ( data*d2map )';

%cdata = (eeg*d2map)';

nContours = 9;


if exist('cMapRange') && ~isempty(cMapRange)
    
    %Scale cdata 0 -> 1
    cdata = min(cdata,cMapRange(2));
    cdata = max(cdata,cMapRange(1));
    
    cdata = (cdata-cMapRange(1));
    cdata = cdata/(range(cMapRange));

else
    minDat = min(data);
    maxDat = max(data);
    rangeDat = abs(maxDat-minDat);
    %Scale cdata -1 -> 1
    cdata =  (cdata/max(abs(cdata)));
    %Push -1:1 range to 0:1
    cdata = (cdata+1)/2;
    %scale data to be 3->nContours.
 
end

cdata = round(nContours*cdata)+3;
%Get values at each vertex of a face.
tV(:,1) = cdata(S.tris(:,1));
tV(:,2) = cdata(S.tris(:,2));
tV(:,3) = cdata(S.tris(:,3));

%Find faces that are at a contour boundary.
samFace = (tV(:,1)==tV(:,2)) & (tV(:,1) == tV(:,3)) & (tV(:,2) == tV(:,3));

%Find the vertices involved with contour boundary faces.
lV = S.tris(~samFace,:);
lV = unique(lV(:));

%set contour boundary vertices to 2;
cdata(lV) = 2;

%Set non cap points to 1;
cdata(dToo)=1;

if exist('myColormap','var') && ischar(myColormap)
    cmap = jmaColors(myColormap,[],nContours+1);
    cmap = [.6 .6 .6; 0 0 0; cmap];
else
    cmap = jmaColors('arizona',[],nContours+1);
    cmap = [.6 .6 .6; 0 0 0; cmap];
end

colormap(cmap);

rgbCdata = cmap(cdata,:);
set(P,'facevertexcdata',rgbCdata,'cdatamapping','direct')

%caxis([1 nContours+3])
%saveas(gcf,['contourCortex_cnd95' num2str(iC) '.png'],'png');
%pause


%%
%E = patch('vertices',ex,'faces',flipdim(mrC_EGInetFaces(false),2),'facecolor','none','edgecolor','k');



