function [mesh] = createChessMesh(patternDim, squareSize)
%GENERATECHESSBOARDMESH Creates a quad mesh depicting a chessboard
%   patternDim: dimensions of the chessboard
%   squareSize: size of one square on the chessboard
%   Returns struct with vertices, faces and colors


[X, Y, Z] = meshgrid(squareSize*(-1:patternDim(1)-1), squareSize*(-1:patternDim(2)-1), 0);

% Connectivity for one square
face = [1 1; 1 2; 2 2; 2 1]';
allFaces = [];
colors = [];

worldPoints = [X(:), Y(:), Z(:)];

for i = 0:patternDim(1)-1
    for j = 0:patternDim(2)-1
        
        % Shift the one square indices along the pattern
        newFace = face + [j; i];
       % [face(1, :)+j, face(2, :)+i
        inds = sub2ind(patternDim([2 1])+1, newFace(1, :), newFace(2, :));
        allFaces = cat(1, allFaces, inds);
        colors = cat(1, colors, xor(mod(i, 2), mod(j, 2)) );
        
    end
end

mesh.vertices = worldPoints;
mesh.faces = allFaces;
mesh.colors = colors;


% The ground truth points that are extracted from the created image 
% when used for analysis. The edge-most points are ignored by
% chessboard detection
mesh.worldPoints = worldPoints;
XX = X;
XX([1 end], :) = NaN;
XX(:, [1 end]) = NaN;
edgemask = isnan(XX(:));

mesh.worldPoints(edgemask, :) = [];

end

