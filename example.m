clear all; %#ok<*SAGROW>

patternDim = [15 10];
squareSize = 0.030;

% Create the mesh of a chessboard based on given parameters
mesh = createChessMesh(patternDim, squareSize);

%%
% Determine focal length in pixels
f_m = 0.006; % Focal length in meters
% Example specs from Sony IMX174/IMX249
pixelsize_m = 5.86*10^-6; % Pixel size in meters 
sensorSize = [1920 1200]; % Sensor size in pixels

fpix = f_m/pixelsize_m; % Focal length in pixels

disp(['Field of View is ' num2str(computeFoV(sensorSize, fpix)) ...
    ' degrees (hor ver)'])


% Define camera poses turning around the x axis of the pattern
% from -30 to 30 in 5 degree increments
x_ang = -30:5:30;
y_ang = zeros(size(x_ang));
z_ang = zeros(size(x_ang));

% All positions the same, 1 meter away in z
x = zeros(size(x_ang))-0.175;
y = zeros(size(x_ang))-0.1;
z = ones(size(x_ang));

patternPositions = cat(1, x, y, z)
patternAngles = cat(1, x_ang, y_ang, z_ang)

% Populate the camera parameters object with requested pattern poses
camParam = createCameraParameters(sensorSize, fpix, patternPositions, patternAngles,...
    'specifyTargetPoses', true);
%%
disp("Rendering images")

% Render the images from mesh based on the pattern poses in camParam
[camParam, images, uvs] = renderImages(camParam, mesh,...
    'drawAxis', false, 'validateCameraParameters', false, 'showRenderCanvas', false, 'showVisualization', true);


%% Detect the pattern and estimate the pose
% just to check correspondence with the requested poses
disp("Running detectCheckerboardPoints to make sure data is valid")
worldPoints = generateCheckerboardPoints(patternDim([2 1]), squareSize);
for i = 1:size(images, 4)
    display([ num2str(i) ' / ' num2str(size(images, 4))]);
    points2d = detectCheckerboardPoints(images(:, :, :, i));
    [R, t] = extrinsics(points2d, worldPoints, camParam);
    ang = rad2deg(rotationMatrixToVector(R));
    detectedPoses(:, i) = [t, ang]'; 
end

requestedPoses = cat(1, patternPositions, patternAngles);

display(requestedPoses)
display(detectedPoses)


%% Create a custom pattern of circular markers (aka constellation)

constellationPoints = ...
    [0., 0, 0;
    0.2, -0.1, 0;
    0.2, 0.2, 0;
    0.0, 0.2, 0;
    0.4, 0.125, 0]';

cmesh = createCircularPatternMesh(constellationPoints, 0.01);
% Render the images from mesh based on the pattern poses in camParam
[camParam, images, uvs] = renderImages(camParam, cmesh,...
    'drawAxis', true, 'validateCameraParameters', false, ...
    'showRenderCanvas', false, 'showVisualization', true);
