close all
clear;
clc;

% create video  object
vid = VideoReader('Wandeling_1c.mp4');

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
    %imshow(grayframe);
    [dif,fRGB] = removeBackgroundRGB(im2double(background),...
                                  im2double(frame),0.15);
    
    %% Deze werken:
    
    se_disk=strel('disk',5,0);
    se_rec=strel('rectangle',[5 5]);
    se_disk2=strel('disk',7,0);
    se_rec2=strel('rectangle',[7 7]);
    
    %{
    se_disk=strel('disk',5,0);
    se_rec=strel('rectangle',[5 5]);
    se_disk2=strel('disk',7,0);
    se_rec2=strel('rectangle',[12 12]);
    %}
    f = double(rgb2bin(fRGB));
    %Perform a first opening to remove any noise caused by slight
    %differences
    f = imopen(f,se_rec);
    %Perform a first closing to then consolidate any mass belonging
    %together
    f = imclose(f,se_disk);
    %Perform a second opening to remove more shadown
    %f1 = imopen(f1,se1);
    
    f = imopen(f,se_rec2);
    f = imclose(f,se_disk2);
    
    %{
    Volgende stap:
        probeer enkel de grootste bouding box over te houden,
        en pas de berekeningen dan allemaal op die bounding box toe
    %}
    
    %Calculate all necessary info in the image:
    [L, number] = bwlabel(f,8);
    stats = regionprops(L,'basic');
    areas = zeros(number);
    
    for r=1:1:number
        areas(r) = stats(r).Area;
    end
    
    
    fprintf('Frame %d: Area=%d\n',i,sum(areas));
    
    [centerX, centerY] = centerOfMass(f);
    %[centerX, centerY] = centerOfMassCorrected(f1,0.5);
    centerX = round(centerX);
    centerY = round(centerY);
    
    
    %Calculate number of white pixels
    amountOfWhite(i) = size(find(f),1);
    %Calculate center of mass
    massCenter(i,:) = [centerX,centerY];
        
    for x=-3:1:3
       for y= -3:1:3
          try
              f(centerX+x,centerY+y) = 0.5;
          catch
          end
       end
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
wMax = max(amountOfWhite); %Maximum amount of white pixels on the screen

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
for i=half_no_frames:1:no_frames-1
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

heights = massCenter(firstFrame:finalFrame,1);
heights = vidHeight - heights;
%Implement moving average filter
a = 1;
b = [1/4, 1/4, 1/4, 1/4];
%b = [1/5, 1/5, 1/5, 1/5, 1/5];
heightsFiltered = filter(b,a,heights);

[peaks time] = findpeaks(heightsFiltered,'MinPeakDistance',10);

%Find the correct time point for each peak
time = time + firstFrame - 1;

%Find step time, step size and step speed:
%To begin, translate the y-distance to metres:
distance_factor = 3.15 / vidWidth;

%Make sure to also translate a certain frame to a certain time:
time_factor = duration / no_frames;

%Matrix to store the found values:
information = zeros(size(peaks,1)-1,3);
for p=1:size(peaks)-1
   %First, find the time between two peaks:
   time_p = time_factor*(time(p+1) - time(p));
   information(p,1) = time_p;
   
   %Next, find the distance between those 2 peaks:
   y1 =  massCenter(time(p),2);
   y2 =  massCenter(time(p+1),2);
   dis_p = (y2 - y1)*distance_factor;
   information(p,2) = dis_p;
   
   %Finally, the step speed can be found:
   speed_p = dis_p / time_p;
   information(p,3) = speed_p;
end

fprintf('The average step time is:  %f s\n',mean(information(:,1)));
fprintf('The average step size is:  %f m\n',mean(information(:,2)));
fprintf('The average step speed is: %f m/s\n',mean(information(:,3)));

plot(firstFrame:finalFrame,heights,'--',...
     firstFrame:finalFrame,heightsFiltered,'-',...
     time,peaks,'x');
legend('Unfiltered data','Data after MA','Maxima');

figure

%Display the different peaks:
for i=1:1:9
    if size(time,1) >= i
        subplot(3,3,i)
        imshow(read(vid,time(i)));
    end
end