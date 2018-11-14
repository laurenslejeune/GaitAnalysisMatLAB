function [dif, foreground] = removeBackgroundRGB(background, img, treshold)
    
    dif = abs(background - img);             %Calculate difference
    foreground = ones(size(img));            %Empty foreground matrix
    
    for rgb=1:1:3
        %Find binary representation of each color
        foreground_i = foreground(:,:,rgb);
        dif_i = dif(:,:,rgb);
        foreground_i (dif_i <= treshold) = 0;
        foreground(:,:,rgb) = foreground_i;
    end
end