function [mesh] = createCircularPatternMesh(points, circleDiameter)
%CREATECUSTOMCIRCULARPATTERN Creates a mesh representing circles 
%   points: 2D or 3D points where to place circular markers
%   squareSize: diameter of circles (scalar for all / vector for each)
%   Returns struct with vertices, faces and colors


if ( size(points, 1) == 2)
   points(3, :) = 0; 
end

% Create a points for a unit circle
numSegments = 50;
r = 1;
thetas = linspace(0, pi*2, numSegments);

[x, y] = pol2cart(thetas, r, 0);
circleIndices = [ 1:numSegments 1];
unitCircle = [x; y];
unitCircle(3, :) = 0;

vertices = [];
allFaces = [];
colors = [];

% Scale and shift the unit circle 
for ptInd = 1:size(points, 2)

    pt = points(:, ptInd);
    circle = unitCircle*circleDiameter + pt;
   
    vertices = cat(2, vertices, circle);
    allFaces = cat(1, allFaces, (ptInd-1)*numSegments + circleIndices);
    colors = cat(1, colors, [255 255 255]);
end




mesh.vertices = vertices';
mesh.faces = allFaces;
mesh.colors = colors;
% The points that are extracted from the created image when 
% used for analysis. Same as input points in this case
mesh.worldPoints = points;

end

