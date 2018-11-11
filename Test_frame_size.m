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

background = read(vid,1);
f = read(vid,225);

f= f(:,111:575,:);
background = background(:,111:575,:);
subplot(1,2,1)
imshow(background);

subplot(1,2,2)
imshow(f);

figure

%backgroundG = rgb2gray(background);
%fG = rgb2gray(f);

subplot(1,2,1)
imshow(background);

subplot(1,2,2)
imshow(f);

figure

background = im2double(background);
f = im2double(f);

[dif,fb] = removeBackgroundRGB(background,f,0.15);
subplot(1,2,1)
imshow(dif);
subplot(1,2,2)
imshow(fb);

figure

fG = rgb2bin(fb);
imshow(fG);
figure 
se1=strel('disk',5);
se2=strel('disk',5);
f1 = imopen(fG,se2);
f1 = imopen(f1,se2);
%f1 = imdilate(f1,se1);
f1 = imclose(f1,se1);
imshow(f1);