function [bayerImg, debayered, mse] = bayerize(img, sensorAlignment)
%UNTITLED2 [bayerImg, debayered, mse] = bayerize(img, sensorAlignment)
%   Detailed explanation goes here


%sensorAlignment = 'bggr';


r = 1; g = 2; b = 3;

switch sensorAlignment
    case 'gbrg'
        mask = [g b; r g];
    case 'grbg'
        mask = [g r; b g];
    case 'bggr'
        mask = [b g; g r];
    case 'rggb'
        mask = [r g; g b];
    otherwise
        error('Unknown sensor alignment');
end

repetitions = size(img(:, :, 1))./size(mask);

fullMask = repmat(mask, repetitions);

[X, Y] = meshgrid(1:size(img, 2), 1:size(img,1));

inds = sub2ind(size(img), Y, X, fullMask);

bayerImg = img(inds);

debayered = demosaic(bayerImg, sensorAlignment);


mse = mean((debayered(:)-img(:)).^2);

end

