function [img, projectedVertices] = renderMesh(mesh, cameraParam, cameraPosition, R, axisVisible, renderCanvasVisible, bgColor)
%RENDERMESH Summary of this function goes here
%   Detailed explanation goes here

exportPoints = (nargout == 2);

imageWidth = cameraParam.ImageSize(2);
imageHeight = cameraParam.ImageSize(1);


% Matlab applies the FOV along the shorter side of the image
% plane, for reasons unknown. Undocumented feature
[shortsideLength, sideInd] = min(cameraParam.ImageSize);
fp = cameraParam.FocalLength(sideInd);
fov = 2*atand(shortsideLength/(2*fp));


oldCanvases = findall(0, 'Type', 'figure', 'Name', 'RenderCanvas');
close(oldCanvases)
f = figure('Name', 'RenderCanvas', 'Visible', renderCanvasVisible); clf;


if size(cameraPosition, 2) == 3
    cameraPosition = cameraPosition';
end

up = [0 -1 0]';
direction = [ 0 0 1]';
% R transposed from Matlab convention to normal people convention,
% multiplied from the front
%R = rotationVectorToMatrix(deg2rad(cameraAngle))';
R = R';

up = R*up;
direction = R*direction;
target = cameraPosition + direction;


f.Position = [100 100 imageWidth imageHeight ];
f.Color = bgColor;

ax = gca;

if exportPoints
    % Scatter messes with axis properties, have to draw first and then set
    % the camera parameters
    scatter3(ax, mesh.vertices(:, 1), mesh.vertices(:, 2), mesh.vertices(:, 3), '.');  axis equal;
end



ax.Units = 'pixels';
% If this doesn't start from 1 1, the result image is of by 1 1 pixels
ax.Position = [1 1 imageWidth imageHeight ];

ax.Projection = 'perspective';
ax.CameraPosition = cameraPosition;
ax.CameraTarget = target;
ax.CameraUpVector = up;

ax.CameraViewAngle = fov;
ax.Visible = 'off';



f.PaperPositionMode = 'auto';
f.InvertHardcopy = 'off';

if exportPoints
    
    fname = fullfile(tempdir, ['synthPointsOnly' num2str(randi(intmax, 1)) '.svg']);
    if isfile(fname)
        delete(fname);
    end
    
    f.Renderer = 'painters';
    
    % Export scatterplot as SVG, parse the uv coordinates from the file
    print(f, fname, '-dsvg');
    %fileattrib(fname, '+h');
    [u, v] = parsePointsFromSVG(fname);
    projectedVertices = [u; v]+0.5;
    delete(fname);
    cla(ax);
else
    
    p = plotMesh(mesh, ax); %#ok<NASGU>
    colormap(ax, 'gray');
    
    dists = (max(mesh.vertices)-min(mesh.vertices));
    coordinateAxisScale = min(dists(dists>0));

    if axisVisible
        hold on;
        scatter3(0, 0, 0, 100, 'ro', 'filled');
        plotCoordinateAxis(coordinateAxisScale);
        hold off
    end
end
drawnow;

% Getframe doesn't work reliably over different versions, using print instead
%frame = getframe(f, double([-1 -1 imageWidth imageHeight ]));
%img = frame.cdata;
%f.GraphicsSmoothing = 'off';
f.Renderer = 'opengl';
dpiString = ['-r' num2str(get(groot,"ScreenPixelsPerInch"))];
img = print(f, '-RGBImage', dpiString);

if any(size(img(:, :, 1)) ~= cameraParam.ImageSize)
   error('Matlab did something strange with the rendering, result image has incorrect size');
end

if ~renderCanvasVisible 
    close(f);
end

end

