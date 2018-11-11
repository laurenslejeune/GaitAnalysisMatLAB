function [dif, foreground] = removeBackgroundRGB(background, img, treshold)
    
    dif = abs(background - img);             %Bereken verschil
    foreground = ones(size(img));            %Lege matrix voor voorgrond
    
    for rgb=1:1:3
        %Vind de binaire voorgrond-voorstelling van iedere kleur
        foreground_i = foreground(:,:,rgb);
        dif_i = dif(:,:,rgb);
        foreground_i (dif_i <= treshold) = 0;
        foreground(:,:,rgb) = foreground_i;
    end
end