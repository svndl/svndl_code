function []= brainstorm2tri(bstFile,outputPrefix);


surfaces = load(bstFile);



for iSurf = 1:length(surfaces.Comment),

    thisSurfName = [outputPrefix surfaces.Comment{iSurf} '.tri']
    
    [fid,msg] = fopen(thisSurfName,'w')
    
    nVertices = length(surfaces.Vertices{iSurf});
    nFaces = length(surfaces.Faces{iSurf});

    theseVertices = surfaces.Vertices{iSurf};
    theseVertices(1,:) = 1000*surfaces.Vertices{iSurf}(2,:);  
    theseVertices(2,:) = 1000*surfaces.Vertices{iSurf}(1,:);
    theseVertices(3,:) = 1000*(surfaces.Vertices{iSurf}(3,:))+50;

    
    fprintf(fid,'%i\n',nVertices);
    
    for i=1:nVertices,
        fprintf(fid,'%d %d %d\n',theseVertices(:,i));
    end
    
    fprintf(fid,'%i\n',nFaces);
    
    for i=1:nFaces,
        fprintf(fid,'%i %i %i\n',surfaces.Faces{iSurf}(i,:));
    end
    
end

