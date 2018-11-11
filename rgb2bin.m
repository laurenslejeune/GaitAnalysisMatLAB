function binImg = rgb2bin(rgbImg)
    binImg = rgbImg(:,:,1) | rgbImg(:,:,2) | rgbImg(:,:,3);
end