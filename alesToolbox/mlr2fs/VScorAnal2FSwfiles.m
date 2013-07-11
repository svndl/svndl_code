function Subj = VScorAnal2FSwfiles(Subj,FSdir,testOnly)
% convert retinotopic vistsoft corAnal to freesurfer w-files

% SCN - 8/23/07

FSsurf = 'smoothwm';			% freesurfer surface to map to vistasoft gray nodes
layer = 1;						% vistasoft gray node layer
d2tol = 5^2;					% tolerance for distance^2 (mm?)
badVal = 1e-3;					% used for amp, ph, & co?
fIS = 0.4;						% fractional distance in IS dimension of axial slice to plot


for iSubj = 1:numel(Subj)

	FSsubj = Subj(iSubj).FSname;
	flipLRflag = Subj(iSubj).FSflipLR;
	VSdir = Subj(iSubj).VSdir;
	iDT = Subj(iSubj).VSiDT;
	iScanWedge = Subj(iSubj).VSiScanWedge;
	iScanRing = Subj(iSubj).VSiScanRing;

	% load mrSESSION
	mrSESSION = load(fullfile(VSdir,'mrSESSION.mat'));

	% Check inputs =================================================================
	% get/check dataTYPES index
	if isempty(iDT)
		iDT = menu('Select data type:',{mrSESSION.dataTYPES.name});
		if iDT == 0
			return
		end
		Subj(iSubj).VSiDT = iDT;
	else
		try
			disp(['dataTYPE = ',mrSESSION.dataTYPES(iDT).name])
		catch
			error('bad dataTYPES index')
		end
	end
	% get/check scan indices
	if isempty(iScanWedge)
		iScanWedge = menu('Select wedge scan:',{mrSESSION.dataTYPES(iDT).scanParams.annotation});
		if iScanWedge == 0
			return
		end
		Subj(iSubj).VSiScanWedge = iScanWedge;
	else
		try
			disp(['Scan = ',mrSESSION.dataTYPES(iDT).scanParams(iScanWedge).annotation])
		catch
			error('bad wedge scan index')
		end
	end
	if isempty(iScanRing)
		iScanRing = menu('Select ring scan:',{mrSESSION.dataTYPES(iDT).scanParams.annotation});
		if iScanRing == 0
			return
		end
		Subj(iSubj).VSiScanRing = iScanRing;
	else
		try
			disp(['Scan = ',mrSESSION.dataTYPES(iDT).scanParams(iScanRing).annotation])
		catch
			error('bad wedge scan index')
		end
	end
	% default left/right flip flag
	if isempty(flipLRflag)
		flipLRflag = false;
	else
		flipLRflag = flipLRflag ~= 0;		% ensure boolean
	end
	Subj(iSubj).FSflipLR = flipLRflag;

	% Load Vistasoft gray coords.mat file ================================================
	% gray coords are [IPR], nodes are [PIR]
	% note: GrayCoords.coords = GrayCoords.nodes([2 1 3],:);
	GrayCoords  = load(fullfile(VSdir,'Gray','coords.mat'));

	% Load Freesurfer meshes [RAS], only need vertices ===================================
	if strcmpi(FSsurf,'tri')
		vL = freesurfer_read_tri(fullfile(FSdir,FSsubj,'surf',['lh.',FSsurf]));
		vR = freesurfer_read_tri(fullfile(FSdir,FSsubj,'surf',['rh.',FSsurf]));
	else
		vL = freesurfer_read_surf(fullfile(FSdir,FSsubj,'surf',['lh.',FSsurf]));
		vR = freesurfer_read_surf(fullfile(FSdir,FSsubj,'surf',['rh.',FSsurf]));
	end
	% Correct Freesurfer L/R flip
	% for older subjects, hemiphere's are misnamed and meshes are [LAS] instead of [RAS]
	if flipLRflag
		% swap hemispheres
		tmp = vL;
		vL = vR;
		vR = tmp;
		% flip L/R
		vL(:,1) = -vL(:,1);	
		vR(:,1) = -vR(:,1);
	end
	% Reorient vertices to [IPR] to match VistaSoft gray coords
	kPermute = [3 2 1];
	vL = vL(:,kPermute);				% now [SAR]
	vR = vR(:,kPermute);
	vL(:,1:2) = -vL(:,1:2);			% now [IPR]
	vR(:,1:2) = -vR(:,1:2);
	% Translate Freesurfer vertices to align with Vistasoft space?
	vL = vL + 128;
	vR = vR + 128;

	% build some layer selection vectors
	kLayer = GrayCoords.nodes(6,:) == layer;
	kLayerL = GrayCoords.allLeftNodes(6,:) == layer;
	kLayerR = GrayCoords.allRightNodes(6,:) == layer;
	subjid = strtok(FSsubj,'_');

	% plot functional coords atop full hemispheres as check for flips etc.
	% pick an axial slice (bounds of IS axis)
	xPlot = round(  (1-fIS)*max(GrayCoords.allLeftNodes(2,kLayerL)) + fIS*min(GrayCoords.allLeftNodes(2,kLayerL)) );
	xPlot = sort(xPlot + [0 2]);
	k = (GrayCoords.coords(1,:) > xPlot(1)) & (GrayCoords.coords(1,:) < xPlot(2)) & kLayer;
	figure('name',subjid)
	subplot(121)
		kL = (GrayCoords.allLeftNodes(2,:) > xPlot(1)) & (GrayCoords.allLeftNodes(2,:) < xPlot(2)) & kLayerL;
		kR = (GrayCoords.allRightNodes(2,:) > xPlot(1)) & (GrayCoords.allRightNodes(2,:) < xPlot(2)) & kLayerR;
		plot(	GrayCoords.allLeftNodes(3,kL) ,GrayCoords.allLeftNodes(1,kL) ,'.b',...
				GrayCoords.allRightNodes(3,kR),GrayCoords.allRightNodes(1,kR),'.r',...
				GrayCoords.coords(3,k),GrayCoords.coords(2,k),'.g')
		set(gca,'ydir','reverse')
		xlabel('L <---> R')
		ylabel('P <---> A')
		title(['Gray Nodes (layer ',int2str(layer),')'])
	subplot(122)
		kL = (vL(:,1) > xPlot(1)) & (vL(:,1) < xPlot(2));
		kR = (vR(:,1) > xPlot(1)) & (vR(:,1) < xPlot(2));
		plot(vL(kL,3),vL(kL,2),'.b',vR(kR,3),vR(kR,2),'.r',GrayCoords.coords(3,k),GrayCoords.coords(2,k),'.g')
		set(gca,'ydir','reverse')
		xlabel('L <---> R')%	ylabel('P <---> A')
		if flipLRflag
			title([FSsurf,' flipped L/R'])
		else
			title(FSsurf)
		end

	if ~testOnly
		% Load corAnal
		GrayCorAnal = load(fullfile(VSdir,'Gray',mrSESSION.dataTYPES(iDT).name,'corAnal.mat'));	% fields = co,amp,ph

		%   [indices, bestSqDist] = nearpoints(src, dest)
		%   For each point in one set, find the nearest point in another.
		%  - src is a 3xM array of points
		%  - dest is a 3xN array of points
		%  - indices is a 1xM vector, in which each element tells which point
		%    in dest is closest to the corresponding point in src.  For
		%    example, dest[indices[i]] is near src[i].
		%  - bestSqDist is a 1xM array of the squared distance between
		%    dest[indices[i]] and src[i].

		iLayer = find(kLayer);		% restrict mapping to specific gray layer


		% Left hemisphere
		[iV2G,d2] = nearpoints(vL',GrayCoords.coords(:,kLayer));		% GrayCoords.coords(:,iLayer(iV2G))' approximates vL
		kBadL= d2 > d2tol;
		% WEDGES
		% amplitude
		data = GrayCorAnal.amp{iScanWedge}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgeAmpL,data)
		% phase
		data = GrayCorAnal.ph{iScanWedge}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgePhL,data)
		% coherence
		data = GrayCorAnal.co{iScanWedge}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgeCoL,data)
		% RINGS
		% amplitude
		data = GrayCorAnal.amp{iScanRing}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringAmpL,data)
		% phase
		data = GrayCorAnal.ph{iScanRing}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringPhL,data)
		% coherence
		data = GrayCorAnal.co{iScanRing}(iLayer(iV2G));
		data(kBadL) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringCoL,data)

		% Right hemi
		[iV2G,d2] = nearpoints(vR',GrayCoords.coords(:,kLayer));
		kBadR = d2 > d2tol;
		% WEDGES
		% amplitude
		data = GrayCorAnal.amp{iScanWedge}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgeAmpR,data)
		% phase
		data = GrayCorAnal.ph{iScanWedge}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgePhR,data)
		% coherence
		data = GrayCorAnal.co{iScanWedge}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).wedgeCoR,data)
		% RINGS
		% amplitude
		data = GrayCorAnal.amp{iScanRing}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringAmpR,data)
		% phase
		data = GrayCorAnal.ph{iScanRing}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringPhR,data)
		% coherence
		data = GrayCorAnal.co{iScanRing}(iLayer(iV2G));
		data(kBadR) = badVal;
		freesurfer_write_wfileFast(Subj(iSubj).ringCoR,data)

		fprintf(1,'# Vertices outside %gmm tolerance: %d Left, %d Right\n',sqrt(d2tol),sum(kBadL),sum(kBadR))

		figure('name',[subjid,' valid coords'])
		plot(	vL(kL & kBadL(:),3),vL(kL & kBadL(:),2),'.k',vR(kR & kBadR(:),3),vR(kR & kBadR(:),2),'.k',...
				vL(kL & ~kBadL(:),3),vL(kL & ~kBadL(:),2),'.b',vR(kR & ~kBadR(:),3),vR(kR & ~kBadR(:),2),'.r')
		set(gca,'ydir','reverse')
		title(sprintf('distance^2 tolerance = %g',d2tol))
	end
end



