function plotCoordinateAxis(scale)
%PLOTCOORDINATEAXIS Plots the x,y and z axis at (0,0,0)

if nargin == 0
    scale = 1;
end

% Coordinate system
cs = eye(3);

quiver3([0 0 0], [0 0 0], [0 0 0], cs(1, :), cs(2, :), cs(3, :),...
    scale, 'red', 'LineWidth', 2);

end

