
function filtData = pdFilter(data,fc2keep)

[nT nC] = size(data);

A=dftmtx(nT);
Ai = conj(dftmtx(nT))/nT;
%A(fc2keep,:)=0;
ftData = A*data;

fc2remove = setdiff(1:nT,[fc2keep+1 (nT+1)-fc2keep]);

Ai(:,fc2remove)=0;

filtData = real(Ai*ftData);
        
        
        
        
        
        
        
        
        
        
        %The following code was ripped out of mrCurrent, and used as a
        %model for the preceeding code.
        %{
        % Set tNT, tNRC, tH, tFBCos, and tFBSin used by enclosing function; read "FB" as "Fourier Basis".
			[ tNT, tNRC ] = RepeatCycle( 1, iCnd, tFilterName ); % these are for nested function SetIFTMat
			tIT = ( [ 1:( tNT * tNRC ) ] - 1 )'; % for math, we need zero-based time index vector
			tT = tIT / ( tNT * tNRC ); % normalize to make time points
			tFBCos = cos( 2 * pi * tT ); % fundamental Fourier basis functions
			tFBSin = sin( 2 * pi * tT );
			tH = GetFilter( tFilterName, tVEPFS )'; % a row vector of harmonic coefficients passed by tFilterName,
													% this will be used by enclosing function as well.
			% Build nT x nHarm matrix of indices into tFB for each harmonic
			% and time point by computing outer product of harmonic
			% coefficient vector with the time index vector. E.g., the
			% the column for 1F simply iterates through each time point, 2F
			% iterates through every other time point, 3F through
			% every third point, &c. modulus by number of time points makes
			% the indices in tIT * tH  greater than nT wrap around properly
			% adding 1 returns indices to 1-based matlab indexing
			tIH = mod( tIT * tH, ( tNT * tNRC ) ) + 1;
			tFBCos = tFBCos( tIH ); % now subscript and repmat to produce full set of harmonic basis functions
			tFBSin = tFBSin( tIH );
			% make forward transform matrix... nFr x nT
			tIFS = mod( [ 1:tVEPFS.nFr ]' * tIT', ( tNT * tNRC ) ) + 1; % indices of full spectrum
			tFBComplex = tFBCos( tIFS ) + tFBSin( tIFS ) * i;
		end
        
        %}