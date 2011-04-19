function ExportMat2EMSE( tMat, tFileName )
	% Export matrix tMat ( nSamp x nCh ) in a tab-delimited ascii file ('tFileName.asc') readable by EMSE
	% Table format in resulting file will be ( nCh x nSamp ).
	[ tNCh, tNS ] = size( tMat ); % number of channels and samples;
	[tFID, tMsg ] = fopen( [ tFileName '.asc' ], 'wt' ); % open for over-writing, text mode
	tFormSpec = [ '%.5e' repmat( '\t%.5e', 1, tNS - 1 ) '\015\012' ]; % CRLF-terminated format specifier string for a channel's worth of data samples
	tNBytes = fprintf( tFID, tFormSpec, tMat );	
	% vectorized fprintf will transpose and reshape; it iterates down
	% through rows of tMat, one column at a time, to fill in data samples
	% for each row (i.e., channel) in the file.
	% tNBytes is number of bytes written, for debugging, if you like that kind of thing..
	fclose( tFID );
end

