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
f = read(vid,200);

subplot(1,2,1)
imshow(background);

subplot(1,2,2)
imshow(f);

figure

backgroundG = rgb2gray(background);
fG = rgb2gray(f);

subplot(1,2,1)
imshow(backgroundG);

subplot(1,2,2)
imshow(fG);

figure
[dif,fbG] = removeBackgroundGrayscale(backgroundG,fG,35);
imshow(fbG);
figure 
se1=strel('disk',5);
se2=strel('disk',3);
f1 = imopen(fbG,se2);
f1 = imopen(f1,se2);
%f1 = imdilate(f1,se1);
f1 = imclose(f1,se1);
imshow(f1);