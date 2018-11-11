function [dif,foreground] = removeBackgroundGrayscale(background, img, treshold)
    
%% If double input
    dif = abs(background - img);
    foreground = ones(size(img));
    foreground (abs(dif) <= treshold) = 0;
    
    %{
    dif = background - img;
    foreground = 255*ones(size(img));
    foreground (dif <= treshold) = 0;
    %}
end