function tPM = CombVec( aN, aM, aI )% function tPM = CombVec( aN )% Computes the aIth combination vector of aM elements grouped at the front of row vector aNtPM = zeros( 1, aM );tI = 0; % running indextN = aN; % current total number, decrements as we move through columnsiPM = 1; % current column index, increments as we move through columnstM = aM; % current number up front, will be decremented as we move through columnstV = 1; % current valuewhile( tN >= tM & tM > 1 )	tNextI = nchoosek( tN - 1, tM - 1 ); % = tN!/tM!/(tN-tM)!	while( tI + tNextI < aI )		tI = tI + tNextI;		tV = tV + 1;		tN = tN - 1;		tNextI = nchoosek( tN - 1, tM - 1 );	end	tPM( 1, iPM ) = tV; % assign current value	iPM = iPM + 1; % change index to next column	tV = tV + 1;	tN = tN - 1;	tM = tM - 1;endtPM( 1, iPM ) = tV-1 + aI-tI;tPMTail = 1:aN;tNPM = iPM;for iPM = 1:tNPM	tPMTail = tPMTail( tPMTail ~= tPM( iPM ) );endtPM = [ tPM tPMTail ];% What's next:% develop a higher function that determines the number of necessary combinations% if total number is 15 or less, use nchoosek, otherwise use CombVec% shoot for as many as possible up to 1000,% otherwise first 1000 elements from randperm( nchoosek );% if N = nchoosek is about 10000 to 1000000 do [1:(N/1001):N]+randperm(1000)% if N is larger than 1000000, then just pick 1000 N*rand() sort, and check for dupes.% e.g. round(sort(rand(100,1))); tX = tX( logical([ 1; tX( 1:99 ) ~= tX( 2:100 ) ]) );...