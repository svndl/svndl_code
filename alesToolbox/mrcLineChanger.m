%%
colorChoice = 'k';

baseTs =606:648;220:432;
spacing = 5;
nPlots = 2;
offList = [0 0 0 0 0];
%offList = [0:spacing:nPlots*spacing; 0:spacing:nPlots*spacing] ;
offList = offList(:);

%lh = findobj(gcf,'type','line','color',colorChoice,'linewidth',2)
lh = findobj(gcf,'type','line','linewidth',2)

thisOff = [];

for i=1:length(lh);
    
    g = get(lh(i));
    
    tmp = g.YData;
    thisOff(i) = nanmean(tmp),
    
    
    try 
        tmp = tmp-nanmean(tmp(baseTs))+offList(i);
        set(lh(i),'YData',tmp);
    catch
        disp('bork')
        continue;
    end
end


%%
%ph = findobj(gcf,'type','patch','facecolor',colorChoice)

ph = findobj(gcf,'type','patch')

for i=1:length(ph);
    
    g = get(ph(i));
    
    tmp = g.YData;
    
    tmp = reshape(tmp,[],2);
    tmp(:,2) = flipud(tmp(:,2));
    
    tmp = mean(tmp,2);
    
    tmp(isnan(tmp))=offList(i);
    try 
        tmp = g.YData-nanmean(tmp(baseTs))+offList(i);
        tmp(isnan(tmp))=offList(i);
        
        set(ph(i),'YData',tmp);        
    catch
        continue;
    end
end
