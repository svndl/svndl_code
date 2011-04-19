function [ activated_sources ] = define_activated_source_space( Quads , source_nb , subjId )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to determine which sources are supposed to be activated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
anatDir = getpref('mrCurrent','AnatomyFolder');
tmp = fullfile(anatDir,subjId,'Standard','meshes','ROIs_correlation.mat');
load(tmp);

activated_sources = ones( 1 , source_nb );
inactivated_quads = setdiff( [ 1 2 3 4 ] , Quads );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if find( inactivated_quads == 1 )  
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2v-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3v-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2V-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3V-R') ) } ) = 0;
end
if find( inactivated_quads == 2 )  
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2v-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3v-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2V-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3V-L') ) } ) = 0;
end
if find( inactivated_quads == 3 )  
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2d-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3d-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2D-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3D-R') ) } ) = 0;
end
if find( inactivated_quads == 4 )  
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2d-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3d-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V2D-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3D-L') ) } ) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( find( inactivated_quads == 1 ) & find( inactivated_quads == 3 ) )
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V1-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3A-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V4-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'LOC-R') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'MT-R') ) } ) = 0;
end
if ( find( inactivated_quads == 2 ) & find( inactivated_quads == 4 ) )
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V1-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V3A-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'V4-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'LOC-L') ) } ) = 0;
    activated_sources( ROIs.ndx{ find( strcmp(ROIs.name,'MT-L') ) } ) = 0;
end

