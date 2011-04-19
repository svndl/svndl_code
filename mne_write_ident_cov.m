function [ cov ] = mne_write_ident_cov( covfile,nchannels )

% eeg_raw2fiff converts raw covariance matrix file to the Neuromag FIFF format.
%
% Use as
%   cov_raw2fiff( covfile, nchannels, nsamples, [options] )
%
% - covfile is an ascii file with nchannels rows and nchannels columns
%

me = 'EEG:cov_raw2fiff';

writeflag = 1;

fprintf( '\n' ); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write FIFF file in interactive mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FIFF = fiff_define_constants();

cov.kind = 1;     % 1 for noise cov. matrix, 2 for source covariance matrix
cov.diag = false; % but source cov. matrices are usually diagonal
cov.dim = nchannels;
for ch = 1 : nchannels;
    cov.names{ ch } = [ 'EEG ' sprintf( '%0.3d', ch ) ];   % channel names
end

cov.data = eye(cov.dim);

% write projections structure
cov.projs.kind = FIFF.FIFFV_MNE_PROJ_ITEM_EEG_AVREF; % assume average reference
cov.projs.active = 1;  % active
cov.projs.desc = 'Average EEG reference';
cov.projs.data.nrow = 1;
cov.projs.data.ncol = cov.dim;
cov.projs.data.row_names = [];
cov.projs.data.col_names = cov.names;
cov.projs.data.data = zeros( 1, cov.dim );

cov.bads = {}; % no bad channels
cov.nfree = 1;%nsamples;

cov.eig    = [];  % eigenvalues
cov.eigvec = [];  % eigenvectors

% finally, write the whole datastructure into the FIFF formated file
if( writeflag == 1 )
    [ path, name ] = fileparts( covfile );
    fname = strcat( name, '-cov.fif' );  % use datafile name as output name
    try
        mne_write_cov_file( fname, cov );
        fprintf( 'Wrote %s\n', fname);
    catch
        error( me, '%s', mne_omit_first_line( lasterr ) );
    end
end

return;




