function S = makeInversesGui()
S = skeriDefaultInverseParameters;
S.SNR = [10 50 300]; 
f = fieldnames(S);
n = numel(f);
h = 0.8/n;
fig = figure('defaultuicontrolunits','normalized');
U = zeros(1,n);
for i = 1:n
	uicontrol('style','text','position',[0.1 0.95-i*h 0.4 h],'string',f{i});
    	U(i) = uicontrol('style','edit','position',[0.5 0.95-i*h 0.4 h],'string',num2str(S.(f{i})));
    %U(i) = uicontrol('style','edit','position',[0.5 0.95-i*h 0.4 h],'string',S.(f{i}));
end
uicontrol('style','pushbutton','position',[0.1 0.05 0.8 0.05],'string','Choose Project','callback','uiresume(gcf)');
uiwait(fig)
for i = 1:n
%	S.(f{i}) = eval(get(U(i),'string'));
	S.(f{i}) = str2num(get(U(i),'string'));
end
projectDir = uigetdir();
snrList = S.SNR;
close(fig)
%try
if S.gcvStyle == 1
    S.SNR = 0;
    computeManyMrcInverses(projectDir,S);
else
    for iSnr = 1:length(snrList);
        S.SNR = snrList(iSnr);
        computeManyMrcInverses(projectDir,S);
    end
end
%catch
 %   close(fig)
%end

