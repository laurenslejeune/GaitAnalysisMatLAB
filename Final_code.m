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
massCenter = zeros(no_frames,2);
amountOfWhite = zeros(no_frames,1);

for i=1:no_frames-1
    
    frame = read(vid,i);   
    %% Frame processing here %%
    [dif,fRGB] = removeBackgroundRGB(im2double(background),...
                                  im2double(frame),0.15);
    
    f = rgb2bin(fRGB);
    
    %% Calculate structuring elements:
    se_disk=strel('disk',5,0);
    se_rec=strel('rectangle',[5 5]);
    se_disk2=strel('disk',7,0);
    se_rec2=strel('rectangle',[7 7]);
    
    %% Filtering
    %Perform a first opening to remove any noise caused by slight
    %differences
    f = imopen(f,se_rec);
    %Perform a first closing to then consolidate any mass belonging
    %together
    f = imclose(f,se_disk);
    
    %Perform a second opening to remove more shadown    
    f = imopen(f,se_rec2);
    
    %Perfor a second closing for more consolidation
    f = imclose(f,se_disk2);
    
    
    %Calculate all necessary info in the image:
    [L, number] = bwlabel(f,8);
    stats = regionprops(L,'basic');
    fprintf('\b\b\b\b\b\b\b\b\b\b');
    fprintf('Frame %d\r',i);
    
    [centerX, centerY] = centerOfMass(f);
    
    if isnan(centerY)
        if sum(f)==0   %The number of 1's in the f
            if i>1
                centerX = massCenter(i-1,1);
                centerY = massCenter(i-1,2);
            elseif i==1
                %Place center of mass in the bottom left corner
                centerX = vidHeight;
                centerY = 0;
            end
        else
            fprintf('Error at %d',i);
        end
    end
    centerX = round(centerX);
    centerY = round(centerY);
    
    
    %Calculate number of white pixels
    amountOfWhite(i) = sum(f,'all');
    %Store center of mass
    massCenter(i,:) = [centerX,centerY];
    
    imshow(f);
    
    drawnow;
    hold on
    for r=1:1:number
        rectangle('Position',stats(r).BoundingBox,'EdgeColor','y','LineWidth', 2);
        rectangle('Position',[stats(r).Centroid,1,1],'Curvature',[1 1],...
            'EdgeColor','g','FaceColor','g', 'LineWidth', 2);
        
    end
    rectangle('Position',[centerY, centerX,1,1],...
            'EdgeColor','r','FaceColor','r', 'LineWidth', 2);
    hold off
    drawnow;
end

%% Berekeningen

[wMax maxFrame] = max(amountOfWhite); %Maximum amount of white pixels on the screen

%Find first frame with more than 15% of the maximum amount of white pixels
firstFrame = 0;
for i=1:no_frames-1
    if amountOfWhite(i) >= 0.15*wMax
        firstFrame = i;
        break
    end
end

%Find final frame with more than 15% of the maximum amount of white pixels
%Since in the film 1b the lady walks back into the view at the end of
%filming, the final frame will be classified as the first time only 15% of
%the maximum amount of white pixels is found while the maxFrame has passed
finalFrame = 0;
for i=maxFrame:1:no_frames-1
    if amountOfWhite(i) <= 0.15*wMax
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


figure

heights = massCenter(firstFrame:finalFrame,1);
heights = vidHeight - heights;

%Implement moving average filter
a = 1;
b = 1;
%b = [1/2, 1/2];
%b = [1/4, 1/4, 1/4, 1/4];
%b = [1/5, 1/5, 1/5, 1/5, 1/5];
heightsFiltered = filter(b,a,heights);

%Find the required MinPeakHeight:
frameDist = finalFrame - firstFrame;
startFrame = round(0.1 * frameDist);
endFrame = round(frameDist - 0.1 * frameDist);

maxValue = max(heightsFiltered(startFrame:endFrame));
minValue = min(heightsFiltered(startFrame:endFrame));
minMax = maxValue - minValue;

[peakValues peakFrames] = findpeaks(heightsFiltered,'MinPeakDistance',13,...
                            'MinPeakHeight',minValue + 0.20*minMax);

%Find the correct frame point for each peak
peakFrames = peakFrames + firstFrame - 1;
                        
%Find the position relating to each height:
%First find the measured values
pos = massCenter(firstFrame:finalFrame,2);

%To calculate the real distance, first a distance_factor is calculated
distance = 3.15; %Distance is 3.15m
distance_factor = distance / vidWidth;
%While in reality, the center of mass travels the entire width (640px),
%the recorded range only lies between for example 32 and 616
%This is because of the decision on the first and final frames
%Since the range actually has to be [0,640], it will be normalized:
norm_pos = round(640*(pos - min(pos)) / (max(pos) - min(pos)));

%Plot those positions
plot(norm_pos*distance_factor,heightsFiltered);
xlabel('Position');
ylabel('Height in the frame');
title('Height of center of mass per position');

%Plot the peaks in function of time
figure
plot(firstFrame:finalFrame,heights,'--',...
     firstFrame:finalFrame,heightsFiltered,'-',...
     peakFrames,peakValues,'x');
legend('Unfiltered data','Data after MA','Maxima');
xlabel('Frame');
ylabel('Height in the frame');
title('Height of center of mass per frame');

%Matrix to store the found values:
information = zeros(size(peakValues,1)-1,3);
for p=1:size(peakValues)-1
   %First, find the time between two peaks:
   time_p = (peakFrames(p+1) - peakFrames(p)) / framerate;
   information(p,1) = time_p;
   
   %Next, find the distance between those 2 peaks:
   y1 =  norm_pos(peakFrames(p)-firstFrame + 1);
   y2 =  norm_pos(peakFrames(p+1)-firstFrame + 1);
   dis_p = (y2 - y1)*distance_factor;
   information(p,2) = dis_p;
   
   %Finally, the step speed can be found:
   speed_p = dis_p / time_p;
   information(p,3) = speed_p;
end

fprintf('The average step time is:  %f s\n',mean(information(:,1)));
fprintf('Total step time is:        %f s\n',sum(information(:,1)));
fprintf('The average step size is:  %f m\n',mean(information(:,2)));
fprintf('Total step distance is:    %f m\n',sum(information(:,2)));
fprintf('The average step speed is: %f m/s\n',mean(information(:,3)));
fprintf('The average step speed is: %f km/h\n',mean(information(:,3))*3.6);

walking_duration = (finalFrame-firstFrame)/framerate;
fprintf('Duration of walk:          %f s\n',walking_duration);
fprintf('Distance of walk:          %f m\n',distance);
fprintf('Avg speed of walk:         %f m/s\n',distance/walking_duration);

%Display the different peaks:
figure
for i=1:1:9
    if size(peakFrames,1) >= i
        subplot(3,3,i)
        imshow(read(vid,peakFrames(i)));
    end
end