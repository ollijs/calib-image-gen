function plotScene(mesh, drawScale)
  
    ax = gca;
    if ( numel(mesh)>1)
       for m = mesh
            plotMesh(m, ax); hold on;
       end
    else
        plotMesh(mesh, ax); hold on;
    end
    
    view(3); colormap('gray');
    axis equal;
    plotCoordinateAxis(drawScale*5);
    ax = gca;
    ax.ZDir = 'reverse';
    ax.YDir = 'reverse';
end