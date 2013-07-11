function meshpro( inFilename, decimationFrac, outFilename, flags )
% [ NFV, hdr, p ] = meshpro( inFilename, [ decimationFrac, outFilename, flags ] )
% Converts Brainsuite .dfs 'duff' format files, MNE .fif format, 
% EMSE .wfr format, FreeSurfer .surf, .asc, and .tri format meshes 
% to '.tri' format. 
% Downsamples and checks for BEM acceptable topology 
% The tri format is an ascii file:
% nvertices
% i x1 y1 z1
% ...
% nfaces
% i i1 i2 i3
% ...
%

me = 'EEG:meshpro';

outflag = 1;
checkflag = 1;
writeflag = 1;
showflag = 1;
flipxflag = 0;
flipyflag = 0;
flipzflag = 0;

if( nargin == 1 )
    decimationFrac = 1;
    outflag = 0;
elseif( nargin == 2 )
    outflag = 0;
elseif( nargin == 4 )
    for i = 1 : size( flags, 2 )
        if(     strcmpi( flags{ i }, 'nochecks' ) )
            checkflag = 0;
        elseif( strcmpi( flags{ i }, 'nowrite' ) )
            writeflag = 0;
        elseif( strcmpi( flags{ i }, 'noshow' ) )
            showflag = 0;
        elseif( strcmpi( flags{ i }, 'flipx' ) )
            flipxflag = 1;
        elseif( strcmpi( flags{ i }, 'flipy' ) )
            flipyflag = 1;
        elseif( strcmpi( flags{ i }, 'flipz' ) )
            flipzflag = 1;
        else
            error( me, 'Unknown option %s', flags{ i } );
        end
    end
end

fprintf( '\nReading %s\n', inFilename );
[ path name ext ] = fileparts( inFilename );

format = 0;
if( strcmpi( ext, '.tri' ) )
    fid = fopen( inFilename, 'r' );
    if( fid == -1 )
        error( 'Can not open file for reading' );
    end
    nvert = fscanf( fid, '%d', 1 );
    data.vertices = fscanf( fid, '%f', [ 4 nvert ] );
    data.vertices = data.vertices( 2 : end, : )';
    nfaces = fscanf( fid, '%d', 1 );
    data.faces = fscanf( fid, '%d', [ 4 nfaces ] );
    data.faces = data.faces( 2 : end, : )';
elseif( strcmpi( ext, '.dfs' ) )
    format = 1;
    [ NFV, hdr ] = readdfs( inFilename );    
    % e.g. NFV =
    %
    %        faces: [589664x3 double]
    %     vertices: [294182x3 double]
    %      normals: [294182x3 double]
    data.vertices = NFV.vertices;
    data.faces    = NFV.faces;
elseif( strcmpi( ext, '.fif' ) || strcmpi( ext, '.fiff' ) )
    format = 2;
    D = mne_read_bem_surfaces( inFilename );
    % e.g. D =    
    %         id: 4
    %      sigma: 1
    %         np: 244691
    %       ntri: 490360
    %coord_frame: 5
    %         rr: [244691x3 double]
    %         nn: []
    %       tris: [490360x3 int32]
    data.vertices = 1000 * D.rr;
    data.faces    = D.tris;
elseif( strcmpi( ext, '.wfr' ) )
    format = 3;
    [ verts, faces ] = mesh_emse2matlab( inFilename, { 'vertex', 'face' } );
    data.vertices = [ verts.x; verts.y; verts.z ]';
    data.faces    = [ faces.vertex1; faces.vertex2; faces.vertex3 ]';
elseif( strcmpi( ext, '.asc' ) )
    format = 4;
    [ FV ] = mesh_freesurfer2matlab( inFilename );
    data.vertices = FV.vertices;
    data.faces    = FV.faces;
elseif( strcmpi( ext, '.surf' ) || strcmpi( name, 'lh' ) || strcmpi( name, 'rh' ) )
    format = 5;
    [ data.vertices data.faces ] = freesurfer_read_surf( inFilename );
else
    error( 'Can not import this mesh format' );
end

nvert = size( data.vertices, 1 );
nfaces = size( data.faces, 1 );
if( nvert ~= ( nfaces + 4 ) / 2 )
    fprintf( '\nWarning: the input surface topology is non-spherical\n' );
end

if( decimationFrac ~= 0 && decimationFrac ~= 1 )
    newStruct.vertices = data.vertices;
    newStruct.faces    = data.faces;
    if( decimationFrac <= 1 )
        fprintf( '\nDecimating by factor %.3f: This can take some time...\n', decimationFrac );
    else
        fprintf( '\nDecimating to %d faces: This can take some time...\n', decimationFrac );
    end
    
    tic;
    P = reducepatch( newStruct, decimationFrac );
    t = toc;
    fprintf( '...done in %5.2f sec.\n\n', t );

    data.faces    = P.faces;
    data.vertices = P.vertices;
end

if( format == 1 ) % .dfs file
    % shift the reference frame center by half-MRI frame along all dimensions
    data.vertices = data.vertices - 128;
    % invert axes (to get the correct order of face vertices)
    % and rotate by 90 deg wrt x-axis
    data.vertices( :, 1 ) = -data.vertices( :, 1 );
    tmp                   =  data.vertices( :, 2 );
    data.vertices( :, 2 ) =  data.vertices( :, 3 );
    data.vertices( :, 3 ) =  -tmp;
elseif( format == 3 ) % .wfr file
    % rotate by 90 deg around z axis for hSpace files
    %tmp                   =  data.vertices( :, 2 );
    %data.vertices( :, 2 ) =  data.vertices( :, 1 );
    %data.vertices( :, 1 ) =  -tmp;    
    % and convert to mm for hSpace files
    % data.vertices = 1000 * data.vertices;
    % rotate by 180 deg around z axis for vSpace meshes
    data.vertices( :, 1 ) =  -data.vertices( :, 1 );
    data.vertices( :, 2 ) =  -data.vertices( :, 2 );
    % and then also by 90 deg around y axis for vSpace meshes
    tmp                   =  data.vertices( :, 1 );
    data.vertices( :, 1 ) =  data.vertices( :, 3 );
    data.vertices( :, 3 ) = - tmp;
    % shift the reference frame center by half-MRI frame along all dimensions
    data.vertices = data.vertices - 128;
    data.vertices( :, 2 ) = data.vertices( :, 2 ) + 256;
end

if( flipxflag == 1 )
    data.vertices( :, 1 ) = -data.vertices( :, 1 );
end
if( flipyflag == 1 )
    data.vertices( :, 2 ) = -data.vertices( :, 2 );
end
if( flipzflag == 1 )
    data.vertices( :, 3 ) = -data.vertices( :, 3 );
end
    
nvert = size( data.vertices, 1 );
nfaces = size( data.faces, 1 );
fprintf( 'Decimated to %d vertices and %d faces\n', nvert, nfaces );

if( checkflag == 1 )
    % check for vertices belonging to only one or two triangles
    fprintf( 'Checking for flaky faces...\n' );

    loose_faces = zeros( nfaces, 1 );
    loose_vertices = zeros( nvert, 1 );
    for i = 1 : nvert
        mask = i * ones( nfaces, 3 );
        md = ( data.faces == mask );
        nf = sum( sum( md ) );
        if( nf > 0 && nf < 3 ) % if the vertex belongs to any face and...
            [ r c ] = find( md ~= 0 );
            fprintf( '\tVertex %d belongs to faces [ ', i );
            fprintf( '%d ', r );
            fprintf( '] only\n' );
            loose_vertices( i, 1 ) = 1;
            for j = 1 : size( r );
                loose_faces( r, 1 ) = 1;
            end
        end
    end
   
    if( sum( loose_faces ) ~= 0 )
        fprintf( 'Removing flaky faces: ' );
        [ r c ] = find( loose_faces == 1 );
        for j = 1 : size( r )
            fprintf( '%d ', r( j ) );
            data.faces = [ data.faces( 1 : r( j ) - j, : ); data.faces( r( j ) - j + 2 : end, : ) ];
        end
    end

    if( sum( loose_vertices ) ~= 0 )
        fprintf( '\nRemoving flaky vertices: ' );
        [ r c ] = find( loose_vertices == 1 );
        for j = 1 : size( r )
            fprintf( '%d ', r( j ) );
            data.vertices = [ data.vertices( 1 : r( j ) - j, : ); data.vertices( r( j ) - j + 2 : end, : ) ];
            data.faces = data.faces - ( data.faces > r( j ) - j + 1 ); % shift down the larger vertex indices
        end
    end

    nvert = size( data.vertices, 1 );
    nfaces = size( data.faces, 1 );
    fprintf( '\nCorrected to %d vertices and %d faces\n', nvert, nfaces );
end

% Calculate mean edge length
msum = 0;
vsum = 0;
for i = 1 : 3
    j = i + 1;
    if( j == 4 )
        j = 1;
    end
    lth = ( data.vertices( data.faces( :, i ), 1 ) - data.vertices( data.faces( :, j ), 1 ) ).^2 + ...
          ( data.vertices( data.faces( :, i ), 2 ) - data.vertices( data.faces( :, j ), 2 ) ).^2 + ...
          ( data.vertices( data.faces( :, i ), 3 ) - data.vertices( data.faces( :, j ), 3 ) ).^2;
    lth = sqrt( lth );
    msum = msum + mean( lth );
    vsum = vsum + var(  lth );
end
fprintf( 'Mean triangulation edge length is %.2f +/- %.2f\n', msum / 3, sqrt( vsum / 3 ) );

topcheck = nvert - ( nfaces + 4 ) / 2;
if( topcheck ~= 0 )
    fprintf( 'Warning: surface topology is still non-spherical\n' );
    if( topcheck < 0 )
        fprintf( 'The surface is likely to have %d holes\n', round( -topcheck / 2 )  );
    end
else
    fprintf( 'Surface has spherical topology now\n' );
end

nvertstr = sprintf( '-%d', nvert );

if( writeflag == 1 )
    if( outflag == 0 || strcmpi( ext, '.tri' ) )  % Write output file
        [ path, name ] = fileparts( inFilename );
        file = fullfile( path, [ name nvertstr '.tri' ] );

        fid = fopen( file, 'w' );
        if( fid == -1 ),
            fprintf( 'Could not open file: %s', file );
            return;
        end

        fprintf( '\nWriting %s\n', file );

        % vertices
        fprintf( fid,'%d\n', nvert );
        fprintf( '\tvertices...\n' );
        for i = 1 : nvert
            fprintf( fid, '%d %8.6f %8.6f %8.6f\n', i, ...
                data.vertices( i, 1 ), ...
                data.vertices( i, 2 ), ...
                data.vertices( i, 3 ) );
        end

        % faces
        fprintf( fid,'%d\n', nfaces );
        fprintf( '\tfaces...\n' );
        for i = 1 : nfaces
            fprintf( fid, '%d %d %d %d\n', i, ...
                data.faces( i, 1 ), ...
                data.faces( i, 2 ), ...
                data.faces( i, 3 ) );
        end

        fclose( fid );
    else
        file = outFilename;
        [ path name ext ] = fileparts( file );
        if( strcmpi( ext, '.surf' ) || strcmpi( name, 'lh' ) || strcmpi( name, 'rh' ) )
            freesurfer_write_surf( file, data.vertices, data.faces );
        end
    end
end

if( showflag == 1 )
    % show the surface
    fig = figure( 'NumberTitle', 'off', 'Name', [ name nvertstr ], 'Position', [ 100,100, 512,512 ], 'Color', [ 0.1 0.1 0.1 ] );
    p = trisurf( data.faces, data.vertices( :, 1 ), data.vertices( :, 2 ), data.vertices( :, 3 ) );
    axis image,
    axis vis3d,
    axis off,
    grid off,
    set( p,'facecolor', 'b', 'EdgeColor', [ 1 0.7 0.3 ] );
    view( -161, 20 );
    zoom( 1.5 );
    rotate3d on;

    % add some gui functionality
    dcm_obj = datacursormode( fig ); % data cursor object
    set( dcm_obj, 'DisplayStyle', 'datatip', 'Enable', 'on' );
    %c_info = getCursorInfo( dcm_obj );
    %c_info.Target
    %set( c_info.Target, 'LineWidth', 2 ) % Make selected line wider
    set( dcm_obj, 'UpdateFcn', { @myupdatefcn, data.vertices, data.faces } );

    return;
end

%%%%%%%%%%%%%%%%%%%%%%% local functions %%%%%%%%%%%%%%%%%%%%%%%%%

function txt = myupdatefcn( empt, event_obj, vertices, faces )
pos = get( event_obj, 'Position' );
diff = ( vertices( :, 1 ) - pos( 1 ) ).^2 + ...
       ( vertices( :, 2 ) - pos( 2 ) ).^2 + ...
       ( vertices( :, 3 ) - pos( 3 ) ).^2;
el_ind = find( diff < 1e-6 );
[ r c ] = find( faces == el_ind );
ps = sprintf( '%.3f ', pos );
fs = sprintf( '%d ', r );
txt = { [ 'Vertex ' num2str( el_ind ) ': ' ps ], [ 'Faces: ' fs ] };
%v = zeros( 1, 3 );
%for i = 1 : 3
%    v( i ) = find( diff == min( diff ) );
%    diff( v( i ) ) = 10000000; % max it
%end

%difs = sum( faces - kron( v( 1, 1 : 3 ), ones( size( faces, 1 ) ) ) );
%face_ind = find( difs == 0 );
%txt = { [ 'Face: ', num2str( face_ind ) ], };
