function [camParam] = createCameraParameters(imageSize, focalLength, camPositions, camRotations, varargin)
%CONSTRUCTCAMERAPARAMETERS Creates a cameraParameters object from inputs
%   Detailed explanation goes here


p = inputParser;
p.addParameter('specifyTargetPoses', false, @islogical);
p.parse(varargin{:});



% Check which format rotations are given in
if size(camRotations, 3) == 1
    % Given rotations are angles, convert to rotation matrices
    for pInd = 1:size(camRotations, 2)
        %Rs(:, :, pInd) = rotationVectorToMatrix( deg2rad(camRotations(:, pInd)) ); %#ok<AGROW>
        Rs(:, :, pInd) = eul2rotm( deg2rad(camRotations(:, pInd))', 'XYZ'); %#ok<AGROW>
    end
else
    % Given rotations are already rotation matrices
    Rs = camRotations;
end

camParam = cameraParameters;
camParam = camParam.toStruct;

% Ideal camera with centered principal point
cx = imageSize(1)/2+0.5;
cy = imageSize(2)/2+0.5;

camParam.ImageSize = imageSize([2 1]);
camParam.K = [focalLength 0 cx; 0 focalLength cy; 0 0 1];

% No distortions
camParam.RadialDistortion = [0 0 0];
camParam.TangentialDistortion = [0 0];



for pInd = 1:size(camPositions, 2)
    R = Rs(:, :, pInd);
    pos = camPositions(:, pInd);
    
    if p.Results.specifyTargetPoses
        % No need to do anything, poses were already given as extrinsics
        extR = R;
        extPos = pos;
    else
        % Convert camera positions to pattern poses
        %[extR, extPos] = cameraPoseToExtrinsics(R, pos);  
        extr = pose2extr(rigidtform3d(R, pos'));
        extR = extr.R;
        extPos = extr.Translation;
        
    end
    
    
    
    extrinsics.ang(pInd, :) = rotmat2vec3d(extR);
    %extrinsics.ang(pInd, :) = rotationMatrixToVector(extR);
    extrinsics.pos(pInd, :) = extPos;
        
    %camRotations(:, :, pInd) = R;
end


camParam.RotationVectors = extrinsics.ang;
camParam.TranslationVectors = extrinsics.pos;



% Create cameraParameters object from inputs
camParam = cameraParameters(camParam);




end

