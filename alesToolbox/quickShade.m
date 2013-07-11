function [ h ] = quickShade( x,yLo,yHi )
%quickShade hacked up function to added a shaded region to the graph
%   quick and dirty
%

%test comment

px = [x(:); flipud(x(:))];    % use px=[x1;x2(end:-1:1)]; if row vecs
py = [ yLo(:) ; flipud(yHi(:)) ];    % use ...

h=patch(px,py,[.85 .85 .85],'linestyle','none');

end

