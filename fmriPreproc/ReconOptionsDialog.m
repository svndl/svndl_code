function Opt = ReconOptionsDialog(Opt)

sty = {	'edit','edit','edit','edit','checkbox','checkbox',...
			'popupmenu','popupmenu','popupmenu','checkbox',...
			'popupmenu','checkbox',[],'checkbox','edit',...
			'edit','edit','edit','edit'	};
str = {	Opt.subjid,Opt.FSsubjid,int2str(Opt.skipVols),num2str(Opt.keepVols),'Correct Slice Time','Correct Motion',...
			{'SliceTime > Motion','Motion > SliceTime'},{'1,2,...,N','N,N-1,...,1'},{'Sequential','Odd, Even','Even, Odd'},'Reverse Slice File',...
			{'Don''t Replace Any','Ask','Replace All'},'Verbose',[],'Extract Brain',int2str(Opt.iRef),...
			Opt.mrVistaSession,Opt.mrVistaDescription,Opt.mrVistaComment,num2str(Opt.mrVistaCycles)	};
val = {	[],[],[],[],Opt.doSliceTimeCorr,Opt.doMotionCorr,...
			2-Opt.sliceTimeFirstFlag,2-Opt.sliceUpFlag,1+Opt.sliceInterleave,Opt.revSliceOrderFlag,...
			2+Opt.replaceAll,Opt.verbose,[],Opt.betFlag,[],...
			[],[],[],[]	};
lab = {	'Subject ID','Freesurfer ID','Skip Volumes','Keep Volumes','','',...
			'Processing Order','Slice Order','Interleave Order','',...
			'Overwrite Policy','',[],'','Ref. Scan Index',...
			'mrVista Session','mrVista Description','mrVista Comment','# Cycles'	};
ena = {	'off','on','on','on','on','on',...
			'on','on','on','on',...
			'on','on',[],'on','off',...
			'on','on','on','on'	};

u = userdlg2col(struct('Style',sty,'String',str,'Value',val,'Label',lab,'Enable',ena),'Recon Options');
if islogical(u)
	Opt = u;
	return
end

Opt.subjid                = u{1};
Opt.FSsubjid              = u{2};
Opt.skipVols(:)           = eval(u{3});
Opt.keepVols(:)           = eval(u{4});
Opt.doSliceTimeCorr(:)    = u{5};
Opt.doMotionCorr(:)       = u{6};

Opt.sliceTimeFirstFlag(:) = u{7} == 1;
Opt.sliceUpFlag(:)        = u{8} == 1;
Opt.sliceInterleave(:)    = u{9} - 1;
Opt.revSliceOrderFlag(:)  = u{10};

Opt.replaceAll(:)         = u{11} - 2;
Opt.verbose(:)            = u{12};
Opt.betFlag(:)            = u{14};		% gap
Opt.iRef(:)               = eval(u{15});

Opt.mrVistaSession        = u{16};
Opt.mrVistaDescription    = u{17};
Opt.mrVistaComment        = u{18};
Opt.mrVistaCycles(:)      = eval(u{19});
