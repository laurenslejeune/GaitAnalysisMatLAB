function [x,y] = centerOfMassCorrected(img,n)
    %This function aims to give a realistic representation of the walking
    %of the individual. This means that it will NOT calculate the actual
    %center of mass of this individual. Because most of the noise is caused
    %by the shadow around the legs, the bottom (the last (n-1)*100%) part of the 
    %white pixels is ignored while calculating the center of mass.
    
    [xRange, yRange] = size(img);
    %Only the top n% of the pixels are used:
    xLimit = n*xRange;
    
    [wX, wY] = find(img); %Finds the x-and y coordinates of all white pixels
    wX (wX > xLimit) = 0; %Set all x-values larger than the limit to 0
    
    number = (size(find(wX),1)); %Find the number of relevant x-values
    
    x = mean(wX(1:number)); %Average x-coordinate of all white pixels
    y = mean(wY(1:number)); %Average y-coordinate of all white pixels
end