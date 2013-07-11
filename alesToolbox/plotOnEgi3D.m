function varargout = plotOnEgi3D(data)
%plotOnEgi - Plots data on a standarized EGI net mesh
%function meshHandle = plotOnEgi(data)
%
%This function will plot data on the standardized EGI mesh with the
%arizona colormap.
%
%Data must be a 128 dimensional vector, but can have singleton dimensions,
%
%
data = squeeze(data);
datSz = size(data);

if datSz(1)<datSz(2)
    data = data';
end

tEpos = load('defaultSphereNet.mat');
tEpos = tEpos.xyz;

tEGIfaces = mrC_EGInetFaces( false );


patchList = findobj(gca,'type','patch');
netList   = findobj(patchList,'UserData','plotOnEgi');


if isempty(netList),    
    handle = patch( 'Vertices', tEpos, ...
        'Faces', tEGIfaces,'EdgeColor', [ 0.25 0.25 0.25 ], ...
        'FaceColor', 'interp');
    
    axis vis3d 
    axis equal
    axis tight
    camproj('perspective')
    view([-45 40])
else
    handle = netList;
end

set(handle,'facevertexCdata',data);
set(handle,'userdata','plotOnEgi');

colormap(jmaColors('arizona'));

if nargout >= 1
varargout{1} = handle;
end
