%Deze code poogt met behulpt van regionprops het massamiddelpunt 
%te berekenen en te gebruiken van berekeningen. De code is niet 
%volledig afgewerkt zoals Final_code.m, omdat ze niet meer gebruikt
%wordt.

close all
clear;
clc;

% create video  object
vid = VideoReader('Wandeling_1b.mp4');

%Get properties from video
framerate = vid.framerate;
duration = vid.duration;
no_frames = vid.NumberOfFrames;
vidHeight = vid.Height;
vidWidth = vid.Width;

%Find half the number of frames:
if mod(no_frames,2) ~= 0
    half_no_frames = (no_frames+1) / 2;
else
    half_no_frames = (no_frames) / 2;
end

%get video frames
background = read(vid,1);
backgroundG = rgb2gray(background);
massCenter = zeros(no_frames,2);
amountOfWhite = zeros(no_frames,1);

for i=1:no_frames-1
    
    frame = read(vid,i);   
    %% Frame processing here %%
    [dif,fRGB] = removeBackgroundRGB(im2double(background),...
                                  im2double(frame),0.15);
    
    se_disk=strel('disk',5,0);
    se_rec=strel('rectangle',[5 5]);
    se_disk2=strel('disk',7,0);
    se_rec2=strel('rectangle',[7 7]);
    
    f = rgb2bin(fRGB);
    %Perform a first opening to remove any noise caused by slight
    %differences
    f = imopen(f,se_rec);
    %Perform a first closing to then consolidate any mass belonging
    %together
    f = imclose(f,se_disk);
    %Perform a second opening to remove more shadown
    f = imopen(f,se_rec2);
    %One more closing for consolidation
    f = imclose(f,se_disk2);
 
    
    %Calculate all necessary info in the image:
    [L, number] = bwlabel(f,8);
    stats = regionprops(L,'basic');
    areas = zeros(number);           %Store area data
    centroids = zeros(number,2);     %Store center of mass data
    boxes = zeros(number,4);         %Store bounding box data
    for r=1:1:number                 %Store data for each region
        areas(r) = stats(r).Area;
        box = stats(r).BoundingBox;
        centroids(r,1) = stats(r).Centroid(1);
        centroids(r,2) = stats(r).Centroid(2);
        boxes(r,1:4) = [box(1), box(2), box(3), box(4)];
    end
    if number >=1
       [area idx] = max(areas);
    else
        area = 0;
        idx = 0;
    end
    
    
    fprintf('\b\b\b\b\b\b\b\b\b\b');
    fprintf('Frame %d\r',i);
    
    %Calculate number of white pixels on the image
    amountOfWhite(i) = sum(f,'all');
    %Calculate center of mass
    if  i > 1
        if area ~=0
            massCenter(i,:) = [centroids(idx,1),centroids(idx,2)];
        else
            massCenter(i,:) = massCenter(i-1,:);
        end
    elseif area ~=0
        massCenter(i,:) = [480, 0];
    end
    
    imshow(f);
    drawnow;
    hold on
    for r=1:1:number
        rectangle('Position',stats(r).BoundingBox,'EdgeColor','y','LineWidth', 2);
        rectangle('Position',[stats(r).Centroid,1,1],'Curvature',[1 1],...
            'EdgeColor','g','FaceColor','g', 'LineWidth', 2);
    end
    hold off
    drawnow;
    
end
[wMax maxFrame] = max(amountOfWhite); %Maximum amount of white pixels on the screen

%Find first frame with more than 10% of the maximum amount of white pixels
firstFrame = 0;
for i=1:no_frames-1
    if amountOfWhite(i) >= 0.10*wMax
        firstFrame = i;
        break
    end
end

%Find final frame with more than 10% of the maximum amount of white pixels
%Since in the film 1b the lady walks back into the view at the end of
%filming, the final frame will be classified as the first time only 10% of
%the maximum amount of white pixels is found while the half of the film has
%passed.
finalFrame = 0;
for i=maxFrame:1:no_frames-1
    if amountOfWhite(i) <= 0.10*wMax
        finalFrame = i;
        break
    end
end
%Display the first frame and the final frame:
figure
subplot(1,2,1)
imshow(read(vid,firstFrame));
subplot(1,2,2)
imshow(read(vid,finalFrame));

%Calculate walking speed:
%Duration of walking:
walking_duration = (finalFrame - firstFrame)/framerate;
distance = 3.15; %Distance is 3.15m
speed = 3.15 / walking_duration;
fprintf('Walking speed is: %f m/s\n',speed);

figure

heights = massCenter(firstFrame:finalFrame,2);
heights = vidHeight - heights;
%Implement moving average filter
a = 1;
%b = [1/4, 1/4, 1/4, 1/4];
b = [1/5, 1/5, 1/5, 1/5, 1/5];
heightsFiltered = filter(b,a,heights);

[peaks time] = findpeaks(heightsFiltered,'MinPeakDistance',10);

%Find the correct time point for each peak
time = time + firstFrame - 1;

plot(firstFrame:finalFrame,heights,'--',...
     firstFrame:finalFrame,heightsFiltered,'-',...
     time,peaks,'x');

legend('Unfiltered data','Data after MA','Maxima');
xlabel('Frame');
ylabel('Height in the frame');
title('Height of center of mass per frame');

figure

%Display the different peaks:
for i=1:1:9
    if size(time,1) >= i
        subplot(3,3,i)
        imshow(read(vid,time(i)));
    end
end