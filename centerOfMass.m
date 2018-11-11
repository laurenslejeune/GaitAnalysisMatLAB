function [x,y] = centerOfMass(img)

    [wX, wY] = find(img); %Finds the x-and y coordinates of all white pixels

    x = mean(wX); %Average x-coordinate of all white pixels
    y = mean(wY); %Average y-coordinate of all white pixels
end