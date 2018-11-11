function foreground = removeBackgroundGrayscale(background, img, treshold)

    dif = img - background;
    foreground = zeros(size(img));
    if(colorScheme == 'grayscale')
        foreground (dif <= treshold) = 255;
    else
        [x,y,~] = size(img);
        for i=1:1:x
           for j=1:1:y
              if (sum(dif(i,j,:)) <= 3*treshold)
                 dif(i,j,:) = 255;
              else
                  dif(i,j,:) = 0;
              end
           end
        end
    end
     

end