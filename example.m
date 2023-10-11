clear all;


patternDim = [15 10];
squareSize = 0.030;

% Create the mesh of a chessboard based on given parameters
mesh = createChessMesh(patternDim, squareSize);

%%
% Determine focal length in pixels
f_m = 0.006; % Focal length in meters
pixelsize_m = 5.86*10^-6; % Pixel size in meters
fpix = f_m/pixelsize_m; % Focal length in pixels

imageSize = [1920 1080];


% Define camera poses turning around the x axis of the pattern
% from -60 to 60 in 5 degree increments
x_ang = -60:5:60;
y_ang = zeros(size(x_ang));
z_ang = zeros(size(x_ang));

% All positions the same, 1 meter away in z
x = zeros(size(x_ang));
y = zeros(size(x_ang));
z = ones(size(x_ang));

patternPositions = cat(1, x, y, z)
patternAngles = cat(1, x_ang, y_ang, z_ang)

% Populate the camera parameters object with requested pattern poses
camParam = createCameraParameters(imageSize, fpix, patternPositions, patternAngles,...
    'specifyTargetPoses', true);

disp("Rendering images")

% Render the images from mesh based on the pattern poses in camParam
[camParam, images, uvs] = createImages(camParam, mesh,...
    'drawAxis', false, 'validateCameraParameters', false, 'showRenderCanvas', false, 'showVisualization', true);



%% Detect the pattern and estimate the pose
% just to check correspondence with the requested poses
disp("Running detectCheckerboardPoints to make sure data is valid")
for i = 1:size(images, 4)
    display([ num2str(i) ' / ' num2str(size(images, 4))]);
    [R, t] = extrinsics( detectCheckerboardPoints(images(:, :, :, i)), generateCheckerboardPoints(patternDim([2 1]), squareSize), camParam);
    ang = rad2deg(rotationMatrixToVector(R));
    detectedPoses(:, i) = [t, ang]';
end

requestedPoses = cat(1, patternPositions, patternAngles)
detectedPoses

