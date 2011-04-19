function [] = bet2emse(iskullFile,oskullFile,scalpFile);


filenames = {iskullFile oskullFile scalpFile};

meshtype={'inner_skull' 'outer_skull' 'scalp'};


for i=1:3,

    thisFile = filenames{i};
    [path,name,ext,ver]=fileparts(thisFile);

    [ vertices faces] = geomview_read_off(thisFile);
    size(faces)
    p.mesh.path=path;
    p.mesh.file=[name,ext];

    p.mesh.data.meshtype={meshtype{i}};
    p.mesh.data.vertices={vertices(:,[2 3 1])-128};
  %  p.mesh.data.faces={faces(:,[3 2 1])};
  p.mesh.data.faces={faces(:,:)};

    p.mesh.fileName=mesh_write_emse(p);
    
end

