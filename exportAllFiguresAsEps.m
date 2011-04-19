function [] = exportAllFigures(format)

if ~exist('format','var') || isempty(format)   
    format = 'psc2';
end


figList = findobj('type','figure');

for iFig = figList';
    
    thisTag = get(iFig,'Tag')
    
    if strcmp(thisTag,'mrCG')
        continue;
    end
    
    if ~isempty(get(iFig,'filename'))
        [dir name ext] = fileparts(get(iFig,'filename'));
    else

        
        name = ['Figure_' num2str(iFig)];
    
    end
    
 
    if strcmp(format,'psc2')
        saveas(iFig,[name '.eps'],'psc2')
    else
        saveas(iFig,[name '.' format],format)
    end
    
    
end
