function [fov] = computeFoV(sensorSize_pix, focalLength_pix)
%COMPUTEFOV Computes the horizontal and vertical Field of View in degrees 
fov = atand((sensorSize_pix./2)./focalLength_pix)*2;
end

