function [] = setSubject_visual_areas_correlation( subj_id )


if subj_id < 10
    dir = sprintf( '%s%d%s' , 'X:\anatomy\skeri000' , subj_id , '\Standard\meshes' )
elseif subj_id < 100
    dir = sprintf( '%s%d%s' , 'X:\anatomy\skeri00' , subj_id , '\Standard\meshes' )
else
    dir = sprintf( '%s%d%s' , 'X:\anatomy\skeri0' , subj_id , '\Standard\meshes' )
end
if isdir( dir )

    % Go to the directory containing the subject informations
    cd(dir)

    if ~exist('ROIs_correlation.mat')

        subj_cortex = load( 'defaultCortex.mat' );
        fv.faces = [ subj_cortex.msh.data.triangles + 1 ]';
        fv.vertices = subj_cortex.msh.data.vertices';
        [C, VertConn] = tess_vertices_connectivity(fv);

        % Go to the directory containing the ROI sources
        cd ROIs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Definition of the different ROIs
        ROIs.ndx = cell( 1 , 18 );
        ROIs.corr = cell( 1 , 18 );
        ROIs.name = cell( 1 , 18 );
        ROIs.name{1} = 'V1-L';
        ROIs.name{2} = 'V1-R';
        ROIs.name{3} = 'V2v-L';
        ROIs.name{4} = 'V2v-R';
        ROIs.name{5} = 'V2d-L';
        ROIs.name{6} = 'V2d-R';
        ROIs.name{7} = 'V3v-L';
        ROIs.name{8} = 'V3v-R';
        ROIs.name{9} = 'V3d-L';
        ROIs.name{10} = 'V3d-R';
        ROIs.name{11} = 'V4-L';
        ROIs.name{12} = 'V4-R';
        ROIs.name{13} = 'V3A-L';
        ROIs.name{14} = 'V3A-R';
        ROIs.name{15} = 'LOC-L';
        ROIs.name{16} = 'LOC-R';
        ROIs.name{17} = 'MT-L';
        ROIs.name{18} = 'MT-R';
        max_value = 30;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Definition of the correlation within each of the ROIs
        for k = 1 : size( ROIs.name , 2 )

            load( ROIs.name{ k } );

            ROIs.ndx{ k } = ROI.meshIndices;

            dist = 0.5 * eye( length( ROI.meshIndices ) );      % Initialization of the distance matrix

            for l = 1 : length( ROI.meshIndices ) - 1
                tmp = zeros( 1 , length( VertConn ) );
                tmp( ROI.meshIndices( l ) ) = 1;
                distance = zeros( 1 , length( ROI.meshIndices ) - l );
                i = 1;
                j = 1;
                while find( distance == 0 )
                    tmp = dilatation( tmp , VertConn , i );
                    tmp( setdiff( find(tmp) , ROI.meshIndices ) ) = 0;
                    distance = distance - tmp( ROI.meshIndices( l + 1 : length( ROI.meshIndices ) ) );
                    j = j + 1;
                    if j == 30
                        distance( find( distance == 0 ) ) = max_value;
                        break;
                    end
                end
                if find(distance ~= max_value)
                    dist( l , l + 1 : length( ROI.meshIndices ) ) = distance - min(distance) + 1;
                    dist( l + 1 : length( ROI.meshIndices ) , l ) = distance - min(distance) + 1;
                else
                    dist( l , l + 1 : length( ROI.meshIndices ) ) = distance;
                    dist( l + 1 : length( ROI.meshIndices ) , l ) = distance;
                end
            end

            ROIs.corr{k} = 0.5 ./ dist;
            ROIs.corr{k} = ROIs.corr{k} + eye(length( dist ));

            for l = 1 : length( dist )
                ROIs.corr{k}( l , find( ROIs.corr{k}( l , : ) < 0.2 ) ) = 0;
            end
            [V,D] = eig( ROIs.corr{k} );
            D_tmp = diag( D );
            if find( diag(D <= 0) )
                D_tmp( find( D_tmp < 0 ) ) = 0.0001;
                ROIs.corr{k} = ( V * diag( D_tmp ) * inv( V ) );
            end
            k
        end
        cd ..
        save 'ROIs_correlation.mat' ROIs

    end

else

    sprintf('%s%d%s' , 'The subject ' , subj_id , ' doesn''t exist in the database.' )

end
