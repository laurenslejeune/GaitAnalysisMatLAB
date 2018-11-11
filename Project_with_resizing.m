close all
clear;
clc;

% create video  object
vid = VideoReader('Wandeling_2a.mp4');

%Get properties from video
framerate = vid.framerate;
duration = vid.duration;
no_frames = vid.NumberOfFrames;
vidHeight = vid.Height;
vidWidth = vid.Width;

%get video frames
background = read(vid,1);
backgroundG = rgb2gray(background);
background = background(:,111:575,:);
vidWidth = 465;
massCenter = zeros(no_frames,2);
amountOfWhite = zeros(no_frames,1);

for i=1:no_frames-1
    fprintf('Frame %f\n',i);
    fullFrame = read(vid,i);
    %% Frame processing here %%
    frame= fullFrame(:,111:575,:);
    frameG = rgb2gray(frame);
    %imshow(grayframe);
    [dif,fRGB] = removeBackgroundRGB(im2double(background),...
                                  im2double(frame),0.15);
    
    f = double(rgb2bin(fRGB));
    %median = medfilt2(f,'symmetric',[5 5]);
    se1=strel('disk',5);
    se2=strel('disk',5);
    f1 = imopen(f,se2);
    %f1 = imdilate(f1,se1);
    f1 = imclose(f1,se1);
    %se=strel('disk',5);
    %f1 = imopen(fbG,se);
    %f1 = imclose(f1,se);
    
    [centerX, centerY] = centerOfMass(f1);
    %[centerX, centerY] = centerOfMassCorrected(f1,0.5);
    centerX = round(centerX);
    centerY = round(centerY);
    
    %Calculate number of white pixels
    amountOfWhite(i) = size(find(f1),1);
    %Calculate center of mass
    massCenter(i,:) = [centerX,centerY];
    for x=-3:1:3
       for y= -3:1:3
          try
              f1(centerX+x,centerY+y) = 0.5;
          catch
          end
       end
    end
    
    [m,n,~] = size(fullFrame);
    
    midPiece = cat(3, f1*255, f1*255, f1*255);
    leftPiece = fullFrame(:,1:110,:);
    rightPiece = fullFrame(:,576:n,:);
    
    total = cat(2,leftPiece,midPiece,rightPiece);
    
    imshow(total);
    
end
wMax = max(amountOfWhite); %Maximum amount of white pixels on the screen

%Find first frame with more than 10% of the maximum amount of white pixels
firstFrame = 0;
for i=1:no_frames-1
    if amountOfWhite(i) >= 0.1*wMax
        firstFrame = i;
        break
    end
end

%Find final frame with more than 10% of the maximum amount of white pixels
finalFrame = 0;
for i=no_frames-1:-1:1
    if amountOfWhite(i) >= 0.1*wMax
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
%b = [1/4, 1/4, 1/4, 1/4];
b = [1/5, 1/5, 1/5, 1/5, 1/5];
heightsFiltered = filter(b,a,heights);

[peaks time] = findpeaks(heightsFiltered,'MinPeakDistance',5);

%Find the correct time point for each peak
time = time + firstFrame - 1;

plot(firstFrame:finalFrame,heights,'--',...
     firstFrame:finalFrame,heightsFiltered,'-',...
     time,peaks,'x');
legend('Unfiltered data','Data after MAF','Maxima');

figure

%Display the different peaks:
for i=1:1:9
    subplot(3,3,i)
    if size(time,1) >= i
        imshow(read(vid,time(i)));
    end
end