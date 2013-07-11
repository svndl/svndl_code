function setSubject_visual_areas_correlation( subj_num )
% setSubject_visual_areas_correlation( subj_num )
%
% this stuff is originally from &'s also located in
% X:\toolbox\matlab_toolboxes\Benoit_toolbox\Inverse
%
% this version's rewritten a little, but function is identical 
% I'm not quite following the plot...

if ispref('mrCurrent','AnatomyFolder')
	anatDir = getpref('mrCurrent','AnatomyFolder');
elseif ispref('VISTA','defaultAnatomyPath')
	anatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),'anatomy');
elseif isunix
	anatDir = '/raid/MRI/anatomy';
elseif ispc
	anatDir = 'X:\anatomy';
elseif ismac
	error('debug for Mac paths')
	anatDir = '/Volumes/MRI';		% ????
end

subj_str = sprintf( 'skeri%04d', subj_num );
meshDir = fullfile( anatDir, subj_str, 'Standard', 'meshes' );

if ~isdir( meshDir )
	error( 'Subject %s has no /Standard/meshes directory.', subj_str )
end

ROIcorrFile = fullfile( meshDir, 'ROIs_correlation.mat' );
if exist( ROIcorrFile, 'file' )
	warning('ROIs_correlation.mat exists.  Not overwriting.')
	return
end

subj_cortex = load( fullfile( meshDir, 'defaultCortex.mat' ) );
[C, VertConn] = tess_vertices_connectivity( struct( 'faces',subj_cortex.msh.data.triangles' + 1, 'vertices',subj_cortex.msh.data.vertices' ) );
nVert = numel(VertConn);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the correlation within each of the ROIs
ROIlist = {'V1','V2v','V2d','V3v','V3d','V4','V3A','LOC','MT'};
% ROIlist = upper(ROIlist);
nROIs = numel(ROIlist) * 2;
ROIs = struct( 'ndx',{cell(1,nROIs)}, 'corr',{cell(1,nROIs)}, 'name',{reshape([strcat(ROIlist,'-L');strcat(ROIlist,'-R')],1,nROIs)} );
max_value = 30;
for iROI = 1:nROIs

	try
		load( fullfile( meshDir, 'ROIs', upper(ROIs.name{iROI}) ) );
	catch
		load( fullfile( meshDir, 'ROIs', ROIs.name{iROI} ) );
	end

	ROIs.ndx{iROI} = ROI.meshIndices;
	nInd = numel( ROI.meshIndices );

	dist = 0.5 * eye( nInd );      % Initialization of the distance matrix

	for iInd = 1:(nInd-1)

		kInd = (iInd+1):nInd;
		tmp = false( 1, nVert );
		tmp( ROI.meshIndices( iInd ) ) = true;
		
		distance = zeros( 1, nInd-iInd );
		
		i = 1;	% #dilation iterations
		j = 1;
		while any( distance == 0 )
			
% 			tmp = dilatation( tmp , VertConn , i );
			for iDil = 1:i
				k = find(tmp);
				for iSeed = 1:numel(k)
					tmp(VertConn{k(iSeed)}) = true;
				end
			end
			% don't dilate outside ROI
			tmp( setdiff( find(tmp) , ROI.meshIndices ) ) = false;
			
			distance = distance - tmp( ROI.meshIndices(kInd) );
			j = j + 1;
			if j == 30
				distance( distance == 0 ) = max_value;
				break;
			end
		end
		if any(distance ~= max_value)
			[dist(iInd,kInd),dist(kInd,iInd)] = deal( distance - min(distance) + 1 );
		else
			[dist(iInd,kInd),dist(kInd,iInd)] = deal( distance );
		end
	end

	ROIs.corr{iROI} = 0.5 ./ dist + eye(nInd);
	for iInd = 1 : nInd
		ROIs.corr{iROI}( iInd , ROIs.corr{iROI}(iInd,:) < 0.2 ) = 0;
	end
	
	[V,D] = eig( ROIs.corr{iROI} );
	D_tmp = diag( D );
	if any( D_tmp <= 0 )
		D_tmp( D_tmp < 0 ) = 0.0001;
		ROIs.corr{iROI} = ( V * diag( D_tmp ) * inv( V ) );
	end
	
	disp(iROI)
end
save( ROIcorrFile, 'ROIs' )



