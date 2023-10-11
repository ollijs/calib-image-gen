function [meshHandle] = plotMesh(mesh, ax)
%PLOTMESH Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    p = patch(ax, 'Faces', mesh.faces, 'Vertices', mesh.vertices, 'FaceVertexCData', mesh.colors );
else
    p = patch('Faces', mesh.faces, 'Vertices', mesh.vertices, 'FaceVertexCData', mesh.colors ); 
end

axis equal;

p.FaceColor = 'flat';
p.EdgeColor = 'none';

meshHandle = p;
end

