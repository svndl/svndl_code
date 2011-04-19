function varargout = plotOnEgi(data)
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

tEpos = load('defaultFlatNet.mat');
tEpos = [ tEpos.xy, zeros(128,1) ];

tEGIfaces = mrC_EGInetFaces( false );


patchList = findobj(gca,'type','patch');
netList   = findobj(patchList,'UserData','plotOnEgi');


if isempty(netList),    
    handle = patch( 'Vertices', [ tEpos(1:128,1:2), zeros(128,1) ], ...
        'Faces', tEGIfaces,'EdgeColor', [ 0.25 0.25 0.25 ], ...
        'FaceColor', 'interp');
else
    handle = netList;
end

set(handle,'facevertexCdata',data);
set(handle,'userdata','plotOnEgi');

colormap(jmaColors('arizona'));

if nargout >= 1
varargout{1} = handle;
end
