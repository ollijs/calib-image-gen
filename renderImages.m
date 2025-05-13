function [camParam, images, allProjectedVertices] = renderImages(camParam, mesh, varargin)
%GENERATECHESSIMAGES Summary of this function goes here
%   imageSize: image dimensions as [width, height]
%   focalLength: focal length in pixels, scalar
%   patternDim: number of squares in the generated pattern [width height]
%   squareSize: edge length of the squares in the generated pattern, scalar
%   camPoses: requested camera positions, [x y z ang_x ang_y ang_z]
%   Optional text parameters
%   'drawAxis', bool: Plots the coordinate axis on the rendered image for debuffing/verification
%   'saveToDisk': bool: Saves the generated images to disk 
%   'folderName': Path to the results folder (Default:synthChess)
%   'imgePrefix': Prefix for the generated files (Default: calib)
%   'imageFormat': Format in which images are saved, as supported by imwrite (Default: png)

sensorTypes = {'rgb', 'grayscale', 'gbrg', 'grbg', 'bggr', 'rggb'};

p = inputParser;
p.addParameter('drawAxis', false, @islogical);
p.addParameter('validateCameraParameters', false, @islogical);
p.addParameter('showRenderCanvas', false, @islogical);
p.addParameter('showVisualization', false, @islogical);

p.addParameter('discardPartiallyOutsideView', true, @islogical);
p.addParameter('saveToDisk', false, @ischar);
p.addParameter('folderName', 'synthChess', @ischar);
p.addParameter('imagePrefix', 'calib', @ischar);
p.addParameter('imageFormat', '.png', @ischar);
p.addParameter('boardPose', zeros(6, 1), @isnumeric);
p.addParameter('sensorType', 'rgb', @ischar); %@(x)any(strcmp(x,sensorTypes))); %@(x)any(strcmp(x,sensorTypes)));
p.addParameter('backgroundColor', [0.3 0.3 0.3]);

p.parse(varargin{:});

% Only compute continuous vertices if output 'uv' is requested
outputProjectedVertices = (nargout == 3);


    
boardPose = p.Results.boardPose;
boardR = rotvec2mat3d( deg2rad(boardPose(4:6)) );
boardPos = boardPose(1:3);
mesh.vertices = (boardR*mesh.vertices'+boardPos)';

folderName = p.Results.folderName;
prefix = p.Results.imagePrefix;
format = p.Results.imageFormat;

numImages = camParam.NumPatterns;

images = uint8([]);
allProjectedVertices = [];


dists = (max(mesh.vertices)-min(mesh.vertices));
drawScale = min(dists(dists>0));

if p.Results.showVisualization
    f = figure;
    clf;
    subplot(1, 3, 1);
    scatter3(0, 0, 0); hold on;
    plotScene(mesh, drawScale);
    drawnow
end

if p.Results.saveToDisk
    mkdir(folderName);
end

for pInd = 1:numImages
    
    %%
    if numImages > 1
        display([ num2str(pInd) ' / ' num2str(numImages)]);
    end
    
    extPos = camParam.TranslationVectors(pInd, :);
    extRot = camParam.RotationMatrices(:, :, pInd);
    
    [R, pos] = extrinsicsToCameraPose(extRot, extPos);
    
    Rs(:, :, pInd) = R;
    angles(pInd, :) = rad2deg(rotationMatrixToVector(R));
    positions(pInd, :) = pos;
    
    
    if outputProjectedVertices
        [~, projectedVertices] = renderMesh(mesh, camParam, pos, R, p.Results.drawAxis, p.Results.showRenderCanvas, p.Results.backgroundColor);
        
        if p.Results.discardPartiallyOutsideView
            if size(projectedVertices, 2) ~= size(mesh.vertices, 1)
                warning(['Discarding image ' num2str(pInd) ', (partially) outside image'])
                continue;
            end
        end
        allProjectedVertices(:, :, pInd) = projectedVertices'; %#ok<*AGROW>
        %allProjectedVertices{pInd} = projectedVertices'; %#ok<*AGROW>
    end
    img = renderMesh(mesh, camParam, pos, R, p.Results.drawAxis, p.Results.showRenderCanvas, p.Results.backgroundColor);
    
    
    sensorType = p.Results.sensorType;
    if any(strcmp( sensorType, sensorTypes(3:6)))
        img  = bayerize(img, sensorType);
        images(:, :, pInd) = img;
    elseif strcmp(sensorType, 'grayscale')
        img = rgb2gray(img);
        images(:, :, pInd) = img;
    elseif strcmp(sensorType, 'rgb')
        % Already is
        images(:, :, :, pInd) = img;
    end
    
    % Only visualize results while rendering if requested
    if p.Results.showVisualization
        figure(f);
        subplot(1, 3, 1);
        %R = rotationVectorToMatrix(deg2rad(ang));
        plotCamera('Location', pos, 'Orientation', R, 'Size', drawScale*0.5);
        xlabel('x'); ylabel('y'); zlabel('z');
        axis equal;
        drawnow;
        
        
        
        subplot(1, 3, [2 3]);
        imshow(img);
        drawnow;
    end
    % Only save images to disk if requested
    if p.Results.saveToDisk 
        filename = [prefix '_' num2str(pInd, '%02d') format];    
        imwrite(img, fullfile(folderName, filename));
    end
    %images{pInd} = img;
    

end


if p.Results.validateCameraParameters
    
    for pInd = 1:numImages
        % This should be veeery small since synthetic data...
        reprojectionErrors(pInd) = validateCameraParameters(camParam, mesh, images, pInd);
    end
    disp(reprojectionErrors)
end

camPoses = [positions'; angles'];
% Only save images to disk if requested
if p.Results.saveToDisk
    save(fullfile(folderName, [prefix '_groundTruth.mat']), 'camPoses', 'camParam');
end




end

