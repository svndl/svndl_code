function [handle] = drawAnatomySurface(varargin)
%function [handle] = drawAnatomySurface(subjId,varargin)
%
%Calling syntax:
%drawAnatomySurface(drawOptions)
%drawOptions is a structure returned from setDrawOptions.
%
%drawAnatomySurface('skeri0001','inner skull',[advanced patch arguments])
%
%You can set options with optns = setDrawOptions
%
%see also: setDrawOptions

if nargin==0
    help drawAnatomySurface
end

if isstruct(varargin{1})
    p = varargin{1};
else
    
    if nargin==2
        argList = {'subjId',varargin{1},'surfName',varargin{2}};
    elseif nargin>2
        argList = {'subjId',varargin{1},'surfName',varargin{2},'patchOptions',{varargin{3:end}}};
    end

    p = setDrawOptions(argList{:});

end


anatDir = getpref('freesurfer','SUBJECTS_DIR');

if ~exist('fiff_define_constants','file')
    error('Please add MNE matlab toolbox to your path')
end

fiff = fiff_define_constants;


cortexLoaded = false;

strippedName = p.surfName(isstrprop(p.surfName,'alpha'));

switch lower(strippedName)   
    case {'skull','innerskull'} 
        surfId = fiff.FIFFV_BEM_SURF_ID_BRAIN;
        defaultColor = [.3 .3 .3];
        surfType = '-bem';
        tag = 'fslInnerSkull';
        
    case {'outerskull'} 
        surfId = fiff.FIFFV_BEM_SURF_ID_SKULL;
        defaultColor = [.6 .6 .6];
        surfType = '-bem';
        tag = 'fslOuterSkull';

    case {'scalp'}
        surfId = fiff.FIFFV_BEM_SURF_ID_HEAD;
        defaultColor = [.8 .6 .4];
        surfType = '-bem';
        tag = 'fslScalp';

    case {'scalphires'}
        surfId = fiff.FIFFV_BEM_SURF_ID_HEAD;
        defaultColor = [.8 .6 .4];
        surfType = '-head';
        tag = 'scalpHires';
        
    case {'cortex'}
        defaultColor = [.8 .8 .8];
        ctx = readDefaultCortex(p.subjId);
        surfType = 'cortex';
        surf2Render.rr = ctx.vertices;
        surf2Render.tris = ctx.faces;
        cortexLoaded = true;
        p.surfReflectance = [.6 .3 0 2];
        p.surfAlpha = 1;
        tag = 'defaultCortex';
    otherwise
        error(['Invalid anatomical surface name: ' p.surfName])

end


%If the surface has been loaded already don't try to load bem surfaces
if cortexLoaded == false

    %append fs4 if not there
    if ~(strncmp(p.subjId(end-2:end),'fs4',3)) && ~strcmp(p.subjId,'fsaverage')
        p.subjId = [p.subjId '_fs4'];
    end

    %Default bem file
    bemFilename=fullfile(anatDir,p.subjId,'bem',[p.subjId surfType '.fif']);

    
    if ~exist(bemFilename,'file')
        error(['Cannot find bem file containing boundaries: ' bemFilename]);
    end

    surfaces = mne_read_bem_surfaces(bemFilename);


    % Tricky use of [] to vectorize a structure
    % then uses logical indexing to pick out the correct surface.
    surfChoice = find([surfaces.id]==surfId);

    if isempty(surfChoice)
        error(['Cannot find specified surface: ' p.surfName ' in file: ' bemFilename])
    end

    surf2Render = surfaces(surfChoice);
end

if ~isempty(p.surfColor)
    color = p.surfColor;
else
    color = defaultColor;
end

ax = gca;
handle = patch('Vertices',surf2Render.rr,'faces',surf2Render.tris(:,[3 2 1]), ...
    'linestyle','none','facecolor',color,'facealpha',p.surfAlpha);

material(handle,p.surfReflectance);
axis tight
axis equal
axis vis3d

%Set id information
set(handle,'tag',tag);
set(gcf,'renderer','opengl');
camproj('perspective')

if ~isempty(p.patchOptions)
    set(handle,p.patchOptions{:});
end

%Turn on a light if none are there
if isempty(findobj(gcf,'type','light'))
    light('position',[0 .707 .707],'style','infinite')
    light('position',[0 -.707 .707],'style','infinite')
    light('position',[0 0 -1],'style','local')
    lighting(ax,'phong');
end




        
        



