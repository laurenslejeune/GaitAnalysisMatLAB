function [height, width] = findBoudingBox(binImg, centerOfMass)

    [height, width] = regionprops(binImg,'BoundingBox');
    
end