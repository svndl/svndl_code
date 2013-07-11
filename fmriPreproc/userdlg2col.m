function vals = userdlg2col(uiStruct,dlgName,dlgPos,uiWH)
% Alternative to inputdlg that allows uicontrol options besides edit, and control of position.
%
% USAGE:
% Values = userdlg2col( uiStructure [,dialogName] [,dialogPosition] [,uiDim] )
%
% Inputs:
% uiStructure = structure with fields Style, String, Value, Label, [Enable]
%               valid Styles for this function are text, edit, popupmenu, checkbox
% dialogName  = string dialog title, optional
% dialogPos   = 1x4 dialog position, optional
% uiDim       = 1x2 uicontrol [width height] (pixels), optional
%
% Output:
% Values      = numel(uiStruct)x1 cell array of uicontrol values
%               text will be [], edit will be char, popupmenu numeric, checkbox logical
%             = false when dialog closed without hitting "Continue"

narg = nargin;
error(nargchk(1,4,narg))

if ~isstruct(uiStruct) || ~all(isfield(uiStruct,{'Style','String','Value','Label'}))
	help(mfilename)
	error('Invalid input to %s',mfilename)
end
if ~isfield(uiStruct,'Enable')
	[uiStruct(:).Enable] = deal('on');
end

n = numel(uiStruct);

if ~exist('uiWH','var') ||  isempty(uiWH)
	uiWH = [200 20];		% uicontrol width,height (pixels)
end
if ~exist('dlgPos','var') ||  isempty(dlgPos)
	w = round(2*uiWH(1)/0.9);
	h = round((n+2)*uiWH(2)/0.9);
	monPos = get(0,'MonitorPositions');
	dlgPos = [ round([ mean(monPos(1,[1 3]))-w/2, mean(monPos(1,[2 4]))-h/2 ]) w h ];
end
if ~exist('dlgName','var') % ||  isempty(dlgName)
	dlgName = '';
end

hn = 0.9 / (n+2);			% uicontrol height (normalized)

Hdlg = dialog('ReSize','on','Position',dlgPos,'Name',dlgName);
Hui = zeros(1,n);
for i = 1:n
	if ~isempty(uiStruct(i).Style)
					uicontrol(Hdlg,'Units','normalized','Position',[0.05 0.95-i*hn 0.45 hn],'Style','text',                  'String',uiStruct(i).Label);
		Hui(i) = uicontrol(Hdlg,'Units','normalized','Position',[0.50 0.95-i*hn 0.45 hn],'Style',lower(uiStruct(i).Style),'String',uiStruct(i).String,'Enable',uiStruct(i).Enable);
 		if ~any(strcmpi(uiStruct(i).Style,{'text','edit'}))		% just set these anyway, even if not used?
			set(Hui(i),'Value',uiStruct(i).Value)
 		end
	end
end
uicontrol(Hdlg,'Units','normalized','Position',[0.05 0.05 0.9 hn],'Style','pushbutton','String','Continue','Callback',@returnVals);

vals = false;

uiwait(Hdlg)

return

	function returnVals(varargin)
		vals = cell(n,1);
		for ii = find( Hui ~= 0 )
			switch get(Hui(ii),'Style')
			case 'edit'
				vals{ii} = get(Hui(ii),'String');
			case 'popupmenu'
%				vals{ii} = uiStruct(ii).String{ get(Hui(ii),'Value') };
				vals{ii} = get(Hui(ii),'Value');
			case 'checkbox'
				vals{ii} = get(Hui(ii),'Value') == get(Hui(ii),'Max');
			end
		end
		close(Hdlg)
	end

end


